import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// SharedPreferencesを一元管理
///
/// 参考：https://blog.dalt.me/2356
/// TODO: ここのkeyをPreference以外の用途でも使っちゃってるけどどうしようかなぁ
/// TODO: あと日本語とも連携させたいけど、ここで良いのか？？
/// 時間と通知の有無しか保存してないから、その二つに分けておけば十分か？
enum PreferenceKey {
  OriginalResinCount, // 天然樹脂（使ってない）
  Windwail,    // 蒼風の高地
  Stormbearer, // 望風山地
  Stormterror, // 風龍廃墟
  Qingce,      // 軽策荘
  Lisha,       // 璃沙郊
  Guyun,       // 孤雲閣
  Qingyun,     // 慶雲頂
  Aocang,      // 奥蔵山
  Narukami,    // 鳴神島
  Kannazuka,   // 神無塚
  Yashiori,    // ヤシオリ島
  Watatsumi,   // 海祇島
  Seirai,      // セイライ島
  Tsurumi,     // 鶴観
  Transformer, // 参量物質変化器
  NotionTransformer // 変化器の通知 別のとこに分けたい
}

extension PreferenceKeyEx on PreferenceKey {
  String get keyString {
    PreferenceKey key = this;
    return key.toString().split('.')[1];
  }

  Future<String> name() async {
    return keyString;
  }

  Future<bool> setInt(int value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setInt(keyString, value);
  }

  Future<int> getInt(int defaultValue) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getInt(keyString)!;
    } else {
      return defaultValue;
    }
  }

  Future<bool> setString(String value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(keyString, value);
  }

  Future<String> getString(String defaultValue) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getString(keyString)!;
    } else {
      return defaultValue;
    }
  }

  Future<bool> setBoolean(bool value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool(keyString, value);
  }

  Future<bool> getBoolean(bool defaultValue) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getBool(keyString)!;
    } else {
      return defaultValue;
    }
  }

  // TODO: DateTimeとTZDateTime使ってるの無駄だから統一したい
  // TODO: 多言語対応の時にタイムゾーン付きにしたり、UTCで保存したり
  Future<bool> setDateTime(DateTime value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(keyString, value.toString());
  }

  Future<DateTime> getDateTime() async {
    return DateTime
        .parse(await getString('1970-01-01'));
  }

  Future<tz.TZDateTime> getTZDateTime() async {
    return tz.TZDateTime
        .parse(tz.UTC, await getString('1970-01-01'))
        .add(Duration(hours: 9)); // 日本時間に変換
  }

}