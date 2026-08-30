import 'dart:convert';
import 'package:flutter/services.dart';
import 'master_config.dart';

class ConfigLoader {
  static Future<MasterConfig> loadFromAssets() async {
    final jsonStr = await rootBundle.loadString('assets/config/master_config.sample.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return MasterConfig.fromJson(map);
  }

  static Future<MasterConfig> loadFromJsonString(String jsonStr) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return MasterConfig.fromJson(map);
  }
}
