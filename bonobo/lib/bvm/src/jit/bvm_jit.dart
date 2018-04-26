import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart-ext:bvm_jit';
import 'package:async/async.dart';
import 'package:source_span/source_span.dart';

class BVM {
  static BVM _instance;

  static SendPort _newJIT(SendPort sendPort) native 'NewJIT';

  final RawReceivePort rawReceivePort = new RawReceivePort();

  StreamController _ctrl;
  final StreamController<String> _onMissingFunction = new StreamController();
  StreamQueue _queue;
  SendPort _jit;

  factory BVM() => _instance ??= new BVM._();

  BVM._() {
    _ctrl = new StreamController();
    rawReceivePort.handler = _ctrl.add;
    _queue = new StreamQueue(_ctrl.stream);
    _jit = _newJIT(rawReceivePort.sendPort);

    scheduleMicrotask(() async {
      while (await _queue.hasNext) {
        await _receivePortHandler(await _queue.next);
      }
    });
  }

  Stream<String> get onMissingFunction => _onMissingFunction.stream;

  _handleNext(bool v) => !v ? true : _queue.next.then(_receivePortHandler);

  void startLoop() => _jit.send(['LOOP', 'LOOP']);

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
    if (value == 'FN') {
      print('Waiting for FN');
      var name = await _queue.next;
      _onMissingFunction.add(name);
    } else if (value == 'THROW') {
      print('Waiting for THROW');
      // TODO: Get stack
      throw await _queue.next;
    } else if (value is List && value.isNotEmpty) {
      var command = value[0].toString();
      print('Command: $command');
      print('Data: $value');
    } else {
      print('Extraneous data from BVM: $value');
      print(value.runtimeType);
    }
  }
}
