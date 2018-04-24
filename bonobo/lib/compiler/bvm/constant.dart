import 'dart:typed_data';

abstract class BVMConstant {
  int get size;

  int write(ByteData buf, int index, Endian endian);
}

class BVMStringConstant implements BVMConstant {
  final String value;

  const BVMStringConstant(this.value);

  @override
  int get size => value.length + 1;

  @override
  int write(ByteData buf, int index, Endian endian) {
    for (int i = 0; i < value.length; i++)
      buf.setUint8(index + i, value.codeUnitAt(i));
    buf.setUint8(index + value.length, 0);
    return index + value.length + 1;
  }
}

class BVMIntegralConstant implements BVMConstant {
  final int value;
  final int size;

  const BVMIntegralConstant(this.value, [this.size]);

  @override
  int write(ByteData buf, int index, Endian endian) {
    switch (size) {
      case 1:
        buf.setUint8(index, value);
        break;
      case 2:
        buf.setUint16(index, value, endian);
        break;
      case 4:
        buf.setUint32(index, value, endian);
        break;
      case 8:
        buf.setUint64(index, value, endian);
        break;
      default:
        throw new ArgumentError('Invalid size $size');
    }

    return index + size;
  }
}
