import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_worker/pdf_worker_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPdfWorker platform = MethodChannelPdfWorker();
  const MethodChannel channel = MethodChannel('pdf_worker');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformVersion':
            return '42';
          case 'isEncrypted':
            return true;
          case 'isEncryptedByTail':
            return true;
          case 'lock':
            return true;
          case 'unlock':
            return true;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('isEncryptedByTail', () async {
    expect(await platform.isEncryptedByTail(filePath: 'test.pdf'), true);
  });

  test('isEncrypted', () async {
    expect(await platform.isEncrypted(filePath: 'test.pdf'), true);
  });

  test('lock', () async {
    await platform.lock(filePath: 'test.pdf', userPassword: '123456', ownerPassword: '123456');
  });

  test('unlock', () async {
    expect(await platform.unlock(filePath: 'test.pdf', password: '123456'), true);
  });
}
