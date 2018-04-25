import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart-ext:bvm_jit';
import 'package:source_span/source_span.dart';

class BVM {
  static BVM _instance;
  static SendPort _newJIT(SendPort sendPort) native 'NewJIT';

  final RawReceivePort rawReceivePort = new RawReceivePort();

  final StreamController<String> _onMissingFunction = new StreamController();
  SendPort _jit;

  factory BVM() => _instance ??= new BVM._();

  BVM._() {
    rawReceivePort.handler = _receivePortHandler;

    _jit = _newJIT(rawReceivePort.sendPort);
  }

  Stream<String> get onMissingFunction => _onMissingFunction.stream;

  void startLoop() => _jit.send(['LOOP']);

  void exec(String function, List arguments) {
    _jit.send(<dynamic>['EXEC', function, arguments]);
  }

  void loadFunction(String name, Uint8List bytecode) {
    _jit.send(['FN', name, bytecode]);
  }

  void pushSpan(FileSpan span) {
    _jit.send([
      'SPAN',
      [span.sourceUrl.toString(), span.start.line, span.start.column]
    ]);
  }

  _receivePortHandler(value) async {

  }
}
