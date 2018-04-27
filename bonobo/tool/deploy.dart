import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dart2_constant/io.dart';
import 'package:path/path.dart' as pp;
import 'package:system_info/system_info.dart';
import 'package:yaml/yaml.dart' as yaml;

main() async {
  // Find the pubspec.
  var baseDir = new File.fromUri(Platform.script).parent.parent.absolute;
  var pubspecFile = new File.fromUri(baseDir.uri.resolve('pubspec.yaml'));
  print('Pubspec found: ${pubspecFile.uri}');
  var pubspecYaml =
      yaml.loadYamlNode(await pubspecFile.readAsString()).value as Map;
  var version = pubspecYaml['version'];

  // Find the SDK root.
  var sdkRoot = new File(Platform.resolvedExecutable).parent.parent.absolute;
  print('SDK root: ${sdkRoot.uri}');

  var targetBuf = new StringBuffer();

  if (Platform.isMacOS)
    targetBuf.write('macos');
  else if (Platform.isWindows)
    targetBuf.write('win');
  else if (Platform.isLinux)
    targetBuf.write('linux');
  else
    targetBuf.write(SysInfo.operatingSystemName.toLowerCase());

  targetBuf.write('-${SysInfo.kernelArchitecture}');
  var targetName = targetBuf.toString();
  var triplet = 'bonobo-$version-$targetName';
  print('Building Bonobo v$version for $targetName...');

  var archive = new Archive();

  Future addFile(String path, String relativeTo, String parent) async {
    var ioFile = new File(path);
    var relative = pp.relative(path.toString(), from: relativeTo);
    relative = pp.join(parent, relative);
    print('$path -> $relative');

    var stat = await ioFile.stat();
    var file = new ArchiveFile(
        relative, await ioFile.length(), await ioFile.readAsBytes())
      ..mode = stat.mode
      ..lastModTime = stat.modified.millisecondsSinceEpoch;
    archive.addFile(file);
  }

  // First, we want to copy everything from `package/`.
  var packageDir = new Directory.fromUri(baseDir.uri.resolve('package'));

  // Next, copy any `.dll`, `.dylib`, `.a`, or `.so` into the `bin/` directory.
  var libExt = ['.dll', '.dylib', '.so', '.a'];

  var bonoboDir = baseDir.parent.absolute;
  var cmakeDir = baseDir;

  // Run CMake.
  print('Running CMake in ${cmakeDir.absolute.path}');
  var cmake = await Process.start('cmake', ['.'],
      workingDirectory: cmakeDir.absolute.path);
  await stdout.addStream(cmake.stdout);
  await stderr.addStream(cmake.stderr);
  var code = await cmake.exitCode;

  if (code != 0) {
    throw 'CMake failed.';
  }

  cmake = await Process.start(
      'cmake',
      [
        '--build',
        '.',
        '--target',
        'all',
        '--',
        //'-j',
        //Platform.numberOfProcessors.toString()
      ],
      workingDirectory: cmakeDir.absolute.path);
  await stdout.addStream(cmake.stdout);
  await stderr.addStream(cmake.stderr);
  code = await cmake.exitCode;

  if (code != 0) {
    throw 'CMake failed.';
  }

  // Generate a `bonobo.dart.snapshot` in the `bin/` directory.
  var snapshot =
      new File.fromUri(packageDir.uri.resolve('bin/bonobo.dart.snapshot'));
  if (await snapshot.exists()) await snapshot.delete(recursive: true);
  var bonoboExecutable =
      new File.fromUri(baseDir.uri.resolve('bin/bonobo.dart')).absolute;

  var args = [
    '--snapshot=${snapshot.absolute.path}',
    '--snapshot-kind=app-jit',
    bonoboExecutable.path,
  ];

  print('Running ${Platform.executable} with $args...');
  var proc = await Process.start(Platform.executable, args);
  stdout.addStream(proc.stdout);
  stderr.addStream(proc.stderr);

  if (await proc.exitCode != 0) throw 'Snapshot generation failed.';

  // Copy generated executables
  var binDir = new Directory.fromUri(bonoboDir.uri.resolve('bin'));

  await for (var entity in binDir.list(recursive: true)) {
    if (entity is File && pp.basenameWithoutExtension(entity.path) == 'bvm') {
      await addFile(entity.absolute.path, binDir.absolute.path, 'bin');
    }
  }

  await for (var entity in bonoboDir.list(recursive: true)) {
    if (entity is File &&
        !entity.absolute.path.contains('cmake-build-debug') &&
        libExt.contains(pp.extension(entity.path))) {
      // The libraries are necessary in bin/ and lib/.
      await addFile(
          entity.absolute.path, pp.dirname(entity.absolute.path), 'bin');
      await addFile(
          entity.absolute.path, pp.dirname(entity.absolute.path), 'lib');
    }
  }

  // Next, copy the libbvm headers to `include`.
  var bvmHeaderDir = new Directory.fromUri(
      bonoboDir.absolute.uri.resolve('bonobo/lib/bvm/src/bvm'));

  await for (var entity in bvmHeaderDir.list(recursive: true)) {
    if (entity is File && pp.extension(entity.path) == '.h') {
      await addFile(entity.absolute.path, bvmHeaderDir.absolute.path,
          pp.join('include', 'bvm'));
    }
  }

  await for (var entity in packageDir.list(recursive: true)) {
    if (entity is File) {
      await addFile(entity.absolute.path, packageDir.absolute.path, '');
    }
  }

  // Copy the Dart executable.
  await addFile(
      new File.fromUri(sdkRoot.uri
              .resolve('bin/' + (Platform.isWindows ? 'dart.exe' : 'dart')))
          .absolute
          .path,
      sdkRoot.absolute.path,
      'dart-sdk');

  // Copy specific parts of SDK/lib.
  var libraries = [
    '_http',
    '_internal',
    'async',
    'collection',
    'convert',
    'core',
    'internal',
    'io',
    'isolate',
    'math',
    'typed_data'
  ];

  for (var library in libraries) {
    var dir =
        new Directory.fromUri(sdkRoot.uri.resolve('lib/$library')).absolute;

    await for (var entity in dir.list(recursive: true)) {
      if (entity is File &&
          (pp.extension(entity.path) == '.dart' ||
              pp.extension(entity.path) == '.dill')) {
        await addFile(entity.absolute.path, sdkRoot.absolute.path, 'dart-sdk');
      }
    }
  }

  // Create a tarball.
  var tarball = new TarEncoder().encode(archive);
  var gzipped = gzip.encode(tarball);

  // Write to release/bonobo-a.b.c-x-y-z.tar.gz.
  var releaseDir =
      new Directory.fromUri(baseDir.parent.uri.resolve('release')).absolute;
  var outputFile = new File.fromUri(releaseDir.uri.resolve('$triplet.tar.gz'));
  await outputFile.create(recursive: true);
  await outputFile.writeAsBytes(gzipped);

  // Delete the snapshot file.
  await snapshot.delete();

  print('Output: ${outputFile.absolute.path}');
}
