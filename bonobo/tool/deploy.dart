import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dart2_constant/io.dart';
import 'package:path/path.dart' as p;
import 'package:system_info/system_info.dart';
import 'package:yaml/yaml.dart' as yaml;

main() async {
  // Find the pubspec.
  var pubspecPath = p.join(
      p.canonicalize(p.dirname(Platform.script.path)), '..', 'pubspec.yaml');
  var pubspecYaml = yaml
      .loadYamlNode(await new File(pubspecPath).readAsString())
      .value as Map;
  var version = pubspecYaml['version'];

  // Find the SDK root.
  var sdkRoot =
      p.dirname(p.dirname(p.canonicalize(Platform.resolvedExecutable)));
  print('SDK root: $sdkRoot');

  var targetName = '${Platform.operatingSystem}-${SysInfo.kernelArchitecture}';
  var triplet = 'bonobo-$version-$targetName';
  print('Building Bonobo v$version for $targetName...');

  var archive = new Archive();

  Future addFile(String path, String relativeTo, String parent) async {
    var ioFile = new File(p.canonicalize(path));
    var relative = p.relative(path, from: relativeTo);
    relative = p.join(parent, relative);
    print('$path -> $relative');

    var stat = await ioFile.stat();
    var file = new ArchiveFile(
        relative, await ioFile.length(), await ioFile.readAsBytes())
      ..mode = stat.mode
      ..lastModTime = stat.modified.millisecondsSinceEpoch;
    archive.addFile(file);
  }

  // First, we want to copy everything from `package/`.
  var packageDirPath =
      p.canonicalize(p.join(p.dirname(Platform.script.path), '..', 'package'));
  var packageDir = new Directory(packageDirPath);

  // Next, copy any `.dll`, `.dylib`, `.a`, or `.so` into the `bin/` directory.
  var libExt = ['.dll', '.dylib', '.so', '.a'];

  var bonoboDir = new Directory(
      p.canonicalize(p.join(p.dirname(Platform.script.path), '..')));

  // Run CMake.
  var cmake = await Process.start('cmake', ['.'],
      workingDirectory: bonoboDir.absolute.path);
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
        '-j',
        Platform.numberOfProcessors.toString()
      ],
      workingDirectory: bonoboDir.absolute.path);
  await stdout.addStream(cmake.stdout);
  await stderr.addStream(cmake.stderr);
  code = await cmake.exitCode;

  if (code != 0) {
    throw 'CMake failed.';
  }

  // Generate a `bonobo.dart.snapshot` in the `bin/` directory.
  var snapshot = p.join(packageDirPath, 'bin', 'bonobo.dart.snapshot');
  var bonoboExecutable = p.canonicalize(
      p.join(p.dirname(Platform.script.path), '..', 'bin', 'bonobo.dart'));
  var result = await Process.run(Platform.executable,
      ['--snapshot=$snapshot', '--snapshot-kind=app-jit', bonoboExecutable]);

  if (result.exitCode != 0) {
    print(result.stderr);
    throw 'Snapshot generation failed.';
  }

  // Copy generated executables
  var binDir = new Directory.fromUri(bonoboDir.uri.resolve('bin'));

  await for (var entity in binDir.list(recursive: true)) {
    if (entity is File && p.basenameWithoutExtension(entity.path) == 'bvm') {
      await addFile(entity.absolute.path, binDir.absolute.path, 'bin');
    }
  }

  await for (var entity in bonoboDir.list(recursive: true)) {
    if (entity is File &&
        !entity.absolute.path.contains('cmake-build-debug') &&
        libExt.contains(p.extension(entity.path))) {
      // The libraries are necessary in bin/ and lib/.
      await addFile(
          entity.absolute.path, p.dirname(entity.absolute.path), 'bin');
      await addFile(
          entity.absolute.path, p.dirname(entity.absolute.path), 'lib');
    }
  }

  // Next, copy the libbvm headers to `include`.
  var bvmHeaderPath =
      p.join(bonoboDir.absolute.path, 'lib', 'bvm', 'src', 'bvm');
  var bvmHeaderDir = new Directory(bvmHeaderPath);

  await for (var entity in bvmHeaderDir.list(recursive: true)) {
    if (entity is File && p.extension(entity.path) == '.h') {
      await addFile(
          entity.absolute.path, bvmHeaderPath, p.join('include', 'bvm'));
    }
  }

  await for (var entity in packageDir.list(recursive: true)) {
    if (entity is File) {
      await addFile(entity.absolute.path, packageDirPath, '');
    }
  }

  // Copy the Dart executable.
  await addFile(
      p.join(sdkRoot, 'bin', Platform.isWindows ? 'dart.exe' : 'dart'),
      sdkRoot,
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
    var libPath = p.join(sdkRoot, 'lib', library);
    var dir = new Directory(libPath);

    await for (var entity in dir.list(recursive: true)) {
      if (entity is File &&
          (p.extension(entity.path) == '.dart' ||
              p.extension(entity.path) == '.dill')) {
        await addFile(entity.absolute.path, sdkRoot, 'dart-sdk');
      }
    }
  }

  // Create a tarball.
  var tarball = new TarEncoder().encode(archive);
  var gzipped = gzip.encode(tarball);

  // Write to release/bonobo-a.b.c-x-y-z.tar.gz.
  var releaseDir = p.canonicalize(
      p.join(p.dirname(Platform.script.path), '..', '..', 'release'));
  var outputPath = p.absolute(p.join(releaseDir, '$triplet.tar.gz'));
  var outputFile = new File(outputPath);
  await outputFile.create(recursive: true);
  await outputFile.writeAsBytes(gzipped);

  // Delete the snapshot file.
  await new File(snapshot).delete();

  print('Output: $outputPath');
}
