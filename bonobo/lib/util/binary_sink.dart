import 'dart:convert';
import 'dart:typed_data';
import 'package:charcode/ascii.dart';

/// A special [StringSink] that can write binary data.
class BinarySink extends StringSink {
  final Encoding encoding;
  ByteData _byteData;
  Uint8List _list;
  int _index = 0;

  BinarySink({int size: 0, this.encoding: utf8}) {
    _list = new Uint8List(size ?? 0);
  }

  BinarySink.fromUint8List(this._list, {this.encoding: utf8});

  factory BinarySink.fromList(List<int> elements, {Encoding encoding: utf8}) =>
      new BinarySink.fromList(new Uint8List.fromList(elements),
          encoding: encoding);

  ByteData get byteData => _byteData ??= new ByteData.view(_list.buffer);

  int get index => _index;

  @override
  void writeCharCode(int charCode) => addUint8(charCode);

  @override
  void writeln([Object obj = ""]) {
    write(obj);
    addInt8($lf);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) =>
      write(objects.join(separator));

  @override
  void write(Object obj) {
    encoding.encode(obj.toString()).forEach(addUint8);
    addInt8(0);
  }

  Uint8List copyBytes() => new Uint8List.fromList(_list);

  Uint8List toBytes() => _list;

  void seek(int index) => _index = index;

  void copy(Uint8List bytes) {
    if (bytes.isEmpty) return;
    allocate(bytes.length);
    bytes.forEach(addUint8);
  }

  void allocate(int bytes) {
    var remaining = _list.length - _index;
    if (remaining < bytes) {
      var diff = bytes - remaining;
      resize(_list.length + diff);
    }
  }

  void resize(int size) {
    if (_list.length < size) {
      var newList = new Uint8List(size);
      for (int i = 0; i < _list.length; i++) newList[i] = _list[i];
      _list = newList;
      _byteData = null;
    }
  }

  void addUint8(int value) {
    allocate(1);
    byteData.setUint8(_index, value);
    _index++;
  }

  void addUint16(int value) {
    allocate(2);
    byteData.setUint16(_index, value);
    _index += 2;
  }

  void addUint32(int value) {
    allocate(4);
    byteData.setUint32(_index, value);
    _index += 4;
  }

  void addUint64(int value) {
    allocate(8);
    byteData.setUint64(_index, value);
    _index += 8;
  }

  void addInt8(int value) {
    allocate(1);
    byteData.setInt8(_index, value);
    _index++;
  }

  void addInt16(int value) {
    allocate(2);
    byteData.setInt16(_index, value);
    _index += 2;
  }

  void addInt32(int value) {
    allocate(4);
    byteData.setInt32(_index, value);
    _index += 4;
  }

  void addInt64(int value) {
    allocate(8);
    byteData.setInt64(_index, value);
    _index += 8;
  }
}
