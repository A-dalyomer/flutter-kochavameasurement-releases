///
///  KochavaMeasurement (Flutter)
///
///  Copyright (c) 2020 - 2024 Kochava, Inc. All rights reserved.
///

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kochava_measurement/kochava_measurement.dart';

void main() {
  const MethodChannel channel = MethodChannel('kochava_measurement');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('retrieveInstallId', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, "retrieveInstallId");
      return 'KA1234';
    });

    expect(await KochavaMeasurement.instance.retrieveInstallId(), 'KA1234');
  });
}
