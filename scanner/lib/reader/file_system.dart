/// This library contains source file and logic to read the source file.

import 'dart:async';
import 'package:file/file.dart';

/// Encapsulates a source file
///
/// [contents] contain the content of the source file.
/// [uri] is the location from which the source file is read.
class Source {
  /// Location from which the source file is read
  final Uri uri;

  /// Content of the source file
  final String contents;

  const Source(this.uri, this.contents);

  /// Creates [Source] by reading the contents of file at [path] on hard disk.
  static Future<Source> fromPath(FileSystem fileSystem, String path) async {
    var file = fileSystem.file(path);

    if (!await file.exists()) {
      throw new Exception('Source file not found: $path');
    }

    String contents = await file.readAsString();
    Uri sourceUrl = file.absolute.uri;

    return new Source(sourceUrl, contents);
  }
}
