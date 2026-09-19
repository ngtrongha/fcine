// Script chụp screenshot tự động cho F-Cine
// Chạy: dart run tool/screenshot.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  // Khởi tạo integration test
  await integrationDriver();

  // TODO: Implement screenshot logic
  // Cần app đang chạy trên device/emulator
}