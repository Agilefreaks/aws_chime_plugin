
import 'dart:async';

import 'package:flutter/services.dart';

class AwsChimePlugin {
  static const MethodChannel _channel = MethodChannel('aws_chime_plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
