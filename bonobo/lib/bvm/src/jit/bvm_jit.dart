import 'dart:isolate';
import 'dart-ext:bvm_jit';

class BVM {
  static SendPort _newJIT(SendPort sendPort) native 'NewJIT';

  final RawReceivePort rawReceivePort = new RawReceivePort();
  SendPort _jit;

  BVM() {
    rawReceivePort.handler = (value) {
      print('Got: $value');
    };

    _jit = _newJIT(rawReceivePort.sendPort);
  }

  void exec(String function, List arguments) {
    _jit.send(<dynamic>['EXEC', function]..addAll(arguments));
  }
}
