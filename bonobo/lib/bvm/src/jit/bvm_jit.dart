import 'dart:isolate';
import 'dart-ext:bvm_jit';

class BVMJit {
  final RawReceivePort rawReceivePort = new RawReceivePort();

  BVMJit() {
    rawReceivePort.handler = (value) {

    };
  }
}