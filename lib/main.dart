import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'widget/accordion.dart';
import 'widget/drawable_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const locale = Locale("ja", "JP");
    return MaterialApp(
      title: 'Genshin Repop Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        locale,
      ],
      home: TopPage(title: 'Genshin Repop Timer'),
    );
  }
}

class TopPage extends StatefulWidget {
  TopPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> with WidgetsBindingObserver {
  int _originalResin = 0;
  int _condensedResin = 0;

  Map<String, int> listRepopDay = {
    'Windwail' : 0, // 蒼風の高地
    'Stormbearer': 0, // 望風山地
    'Stormterror' : 0, // 風龍廃墟
    'Qingce': 0, // 軽策荘
    'Lisha': 0, // 璃沙郊
    'Guyun': 0, // 孤雲閣
    'Qingyun': 0, // 慶雲頂
    'Aocang': 0, // 奥蔵山
    'Narukami': 0, // 鳴神島
    'Kannazuka': 0, // 神無塚
    'Yashiori': 0, // ヤシオリ島
    'Watatsumi': 0, // 海祇島
    'Seirai': 0, // セイライ島
  };

  Map<String, tz.TZDateTime> pickedDateTime = {
    'resin': tz.TZDateTime.now(tz.UTC),
    'stone': tz.TZDateTime.now(tz.UTC),
    'artifact': tz.TZDateTime.now(tz.UTC),
    'fishing': tz.TZDateTime.now(tz.UTC),
    'transformer': tz.TZDateTime.now(tz.UTC),
    'cultivation': tz.TZDateTime.now(tz.UTC),
  };

  // TODO: DataClass作成
  Map<String, bool> notificationSetting = {
    'resin': false,
    'stone': false,
    'artifact': false,
    'fishing': false,
    'transformer': false,
    'cultivation': false,
  };

  // TODO: リソースに移動
  final Map<String, int> notionIdResource = {
    'resin': 1,
    'stone': 2,
    'artifact': 3,
    'fishing': 4,
    'transformer': 5,
    'cultivation': 6
  };

  int transformHour = 0;

  @override
  void initState() {
    super.initState();
    readSharedPreference();
  }

  void readSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pickedDateTime['transformer'] = await getTZDateTime('transformer');
    setState(() {
      _originalResin = prefs.getInt('originalResinCount') ?? 0;
      // 通知設定
      notificationSetting['transformer'] = prefs.getBool('notionTransformer') ?? false;

      // 再出現日
      // for () { // TODO: ループさせる
      //   listRepopDay[key] = repopDay(DateTime.parse(prefs.getString(key) ?? ''), 3);
      // }
      listRepopDay['Windwail'] = repopDay(DateTime.parse(prefs.getString('Windwail') ?? '2021-01-01'), 3); // TODO: デフォルト値を検討
      listRepopDay['Stormbearer'] = repopDay(DateTime.parse(prefs.getString('Stormbearer') ?? '2021-01-01'), 3);
      listRepopDay['Stormterror'] = repopDay(DateTime.parse(prefs.getString('Stormterror') ?? '2021-01-01'), 3);
      listRepopDay['Qingce'] = repopDay(DateTime.parse(prefs.getString('Qingce') ?? '2021-01-01'), 3);
      listRepopDay['Lisha'] = repopDay(DateTime.parse(prefs.getString('Lisha') ?? '2021-01-01'), 3);
      listRepopDay['Guyun'] = repopDay(DateTime.parse(prefs.getString('Guyun') ?? '2021-01-01'), 3);
      listRepopDay['Qingyun'] = repopDay(DateTime.parse(prefs.getString('Qingyun') ?? '2021-01-01'), 3);
      listRepopDay['Aocang'] = repopDay(DateTime.parse(prefs.getString('Aocang') ?? '2021-01-01'), 3);
      listRepopDay['Narukami'] = repopDay(DateTime.parse(prefs.getString('Narukami') ?? '2021-01-01'), 3);
      listRepopDay['Kannazuka'] = repopDay(DateTime.parse(prefs.getString('Kannazuka') ?? '2021-01-01'), 3);
      listRepopDay['Yashiori'] = repopDay(DateTime.parse(prefs.getString('Yashiori') ?? '2021-01-01'), 3);
      listRepopDay['Watatsumi'] = repopDay(DateTime.parse(prefs.getString('Watatsumi') ?? '2021-01-01'), 3);
      listRepopDay['Seirai'] = repopDay(DateTime.parse(prefs.getString('Seirai') ?? '2021-01-01'), 3);
      transformHour = repopHour(DateTime.parse(prefs.getString('transformer') ?? '2021-01-01'), 166);
    });
  }

  void _changeOriginalResin(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int changedOriginalResin = _originalResin + value;
    if (changedOriginalResin >= 0) {
      await prefs.setInt('originalResinCount', changedOriginalResin);
      setState(() {
        _originalResin = changedOriginalResin;
      });
    } else {
      Fluttertoast.showToast(msg: "樹脂が足りません");
    }
  }

  void setBoolean(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<tz.TZDateTime> getTZDateTime(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String timeString = prefs.getString(key) ?? '2021-01-01';
    // DateTime dateTime = DateTime.parse(prefs.getString(key) ?? '2021-01-01');
    return tz.TZDateTime.parse(tz.UTC, timeString).add(Duration(hours: 9)); // 日本時間に変換
    // return tz.TZDateTime.from(dateTime, tz.UTC);
  }

  void _createCondensedResin() {
    setState(() {
      if (_condensedResin < 5 && _originalResin >= 40) {
        _originalResin = _originalResin - 40;
        _condensedResin++;
      }
    });
  }

  void _useCondensedResin() {
    setState(() {
      if (_condensedResin > 0) {
        _condensedResin--;
      }
    });
  }

  void savePickDate(DateTime dateTime, String key) async {
    // TODO: DateTimeとTZDateTime使ってるの無駄だから統一したい
    // TODO: 多言語対応の時にタイムゾーン付きにしたり、UTCで保存したり
    pickedDateTime[key] = tz.TZDateTime.from(dateTime, tz.UTC);
    initializeDateFormatting("ja_JP");
    DateFormat formatter = new DateFormat('M/d(E)', "ja_JP");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, dateTime.toString());
  }

  int repopDay(DateTime pickedDate, int interval) {
    DateTime popDateTime = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day+interval, pickedDate.hour-5); // 水晶は7時らしいから別枠かな
    DateTime popDate = new DateTime(popDateTime.year, popDateTime.month, popDateTime.day);
    final Duration difference = popDate.difference(DateTime.now());
    int day = difference.inDays + 1;
    if (popDate.isBefore(DateTime.now())) day = 0;
    return day;
  }

  int repopHour(DateTime pickedDate, int interval) {
    DateTime popDateTime = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedDate.hour+interval);
    final Duration difference = popDateTime.difference(DateTime.now());
    int hour = difference.inHours;
    if (popDateTime.isBefore(DateTime.now())) hour = 0;
    return hour;
  }

  // 通知予約
  // TODO: この関数の中で石とか変化機とかごとに分岐させて各々時間を作りたい
  Future<void> createNotification(int notionId, tz.TZDateTime dateTime, String text) {
    final flnp = FlutterLocalNotificationsPlugin();
    return flnp.initialize(
      InitializationSettings(
        iOS: IOSInitializationSettings(),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    ).then((_) => flnp.zonedSchedule(
      notionId,
      '原神タイマー',
      text,
      dateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'genshin_repop_timer',
          '再出現通知',
          '復活したときの通知',
        ),
        iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    ));
  }

  // 通知on/off
  changeNotification(bool notionValue, int notionId, tz.TZDateTime dateTime, String text) async {
    if (notionValue) {
     createNotification(notionId, dateTime, text);
    } else {
      final flnp = FlutterLocalNotificationsPlugin();
      await flnp.cancel(notionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(5),
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.blue[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                children: <Widget>[
                  Row(
                    children: [
                      Image.asset('images/Item_Fragile_Resin.png', height: 32),
                      Text(
                        '樹脂',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          // Image.asset('images/Item_.png', height: 32),
                          Text(
                            '天然樹脂', // 8m
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            _originalResin.toString(),
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '/160',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _changeResinButton(-60),
                      Padding(padding: EdgeInsets.all(3),),
                      _changeResinButton(-40),
                      Padding(padding: EdgeInsets.all(3),),
                      _changeResinButton(-30),
                      Padding(padding: EdgeInsets.all(3),),
                      _changeResinButton(-20),
                      Padding(padding: EdgeInsets.all(3),),
                      _changeResinButton(60),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.indigo[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                children: <Widget>[
                  Row(
                    children: [
                      Image.asset('images/Item_Magical_Crystal_Chunk.png', height: 32),
                      Text(
                        '鉱石',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Colors.green[100],
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                        children: <Widget>[
                          Row(
                            children: [
                              Image.asset('images/Element_Anemo.png', height: 32),
                              Text(
                                'モンド',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          _stoneRow('蒼風の高地', 'Windwail', 'Item_Crystal_Chunk'),
                          _stoneRow('望風山地', 'Stormbearer', 'Item_Crystal_Chunk'),
                          _stoneRow('風龍廃墟', 'Stormterror', 'Item_Crystal_Chunk'),
                          _stoneRow('軽策荘', 'Qingce', 'Item_Crystal_Chunk'),
                        ],
                      )
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Colors.orange[100],
                    child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                          children: <Widget>[
                            Row(
                              children: [
                                Image.asset('images/Element_Geo.png', height: 32),
                                Text(
                                  '璃月',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            _stoneRow('璃沙郊', 'Lisha', 'Item_Crystal_Chunk'),
                            _stoneRow('孤雲閣', 'Guyun', 'Item_Crystal_Chunk'),
                            _stoneRow('慶雲頂', 'Qingyun', 'Item_Crystal_Chunk'),
                            _stoneRow('奥蔵山', 'Aocang', 'Item_Crystal_Chunk'),
                          ],
                        )
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Colors.purple[100],
                    child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                          children: <Widget>[
                            Row(
                              children: [
                                Image.asset('images/Element_Electro.png', height: 32),
                                Text(
                                  '稲妻',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            _stoneRow('鳴神島', 'Narukami', 'Item_Amethyst_Lump'),
                            _stoneRow('神無塚', 'Kannazuka', 'Item_Amethyst_Lump'),
                            _stoneRow('ヤシオリ島', 'Yashiori', 'Item_Amethyst_Lump'),
                            _stoneRow('海祇島', 'Watatsumi', 'Item_Amethyst_Lump'),
                            _stoneRow('セイライ島', 'Seirai', 'Item_Amethyst_Lump'),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.deepPurple[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: [
                  Image.asset('images/Item_Artifact.png', height: 32),
                  Text(
                    '聖遺物', // 24h
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.lightBlue[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: [
                  Image.asset('images/Item_Wilderness_Rod.png', height: 32),
                  Text(
                    '釣り', // 3日後の5時
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.green[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 均等に配置する
                    children: [
                      Row(
                        children: [
                          Image.asset('images/Item_Parametric_Transformer.png', height: 32),
                          Text(
                            '参量物質変化器', // 166h
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.grey,
                            size: 28.0,
                          ),
                          Switch(
                            value: notificationSetting['transformer']!,
                            onChanged: (bool newValue) {
                              setState(() { notificationSetting['transformer'] = newValue;});
                              setBoolean('notionTransformer', newValue);
                              changeNotification(newValue, notionIdResource['transformer']!, pickedDateTime['transformer']!.add(Duration(hours: 166)) ,'参量物質変化器が再使用可能になりました');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '変換', // 166h
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Row(
                        children: [
                          // if (listRepopDay[areaKey] == 0) Image.asset('images/$icon.png', height: 32),
                          Text(
                            'あと$transformHour時間',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(3),),
                          ElevatedButton(
                            onPressed: () {
                              savePickDate(DateTime.now(), 'transformer');
                              createNotification(notionIdResource['transformer']!, tz.TZDateTime.now(tz.UTC).add(Duration(hours: 166)), '参量物質変化器が再使用可能になりました');
                              setState(() { transformHour = repopHour(DateTime.now(), 166); });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey,
                              elevation: 8,
                            ),
                            child: Text('変換'),
                          ),
                        ],
                      ),
                    ],
                  )
                ]
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.lightGreen[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Row(
                children: [
                  Image.asset('images/Item_Serenitea_Pot.png', height: 32),
                  Text(
                    '栽培', // 70h
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
    //           Column(children: [
    // Accordion('Section #1',
    // 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam bibendum ornare vulputate. Curabitur faucibus condimentum purus quis tristique.'),
    // Accordion('Section #2',
    // 'Fusce ex mi, commodo ut bibendum sit amet, faucibus ac felis. Nullam vel accumsan turpis, quis pretium ipsum. Pellentesque tristique, diam at congue viverra, neque dolor suscipit justo, vitae elementum leo sem vel ipsum'),
    // Accordion('Section #3',
    // 'Nulla facilisi. Donec a bibendum metus. Fusce tristique ex lacus, ac finibus quam semper eu. Ut maximus, enim eu ornare fringilla, metus neque luctus est, rutrum accumsan nibh ipsum in erat. Morbi tristique accumsan odio quis luctus.'),
    // ]),
    //       ElevatedButton(
    //         onPressed: () {
    //           createNotification(0, tz.TZDateTime.now(tz.UTC).add(Duration(seconds: 3)), 'テスト');
    //         },
    //         style: ElevatedButton.styleFrom(
    //           primary: Colors.grey,
    //           elevation: 8,
    //         ),
    //         child: Text('通知テスト'),
    //       )
        ],
      ),
    );
  }

  // Layout Components
  // 天然樹脂の±ボタン
  Widget _changeResinButton(int increase) {
    String text = '';
    if (increase > 0) { text = '+$increase';}
    else {text = '$increase';}
    return Expanded(
      flex: 1,
      child: ElevatedButton(
        onPressed: () {
          _changeOriginalResin(increase);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.grey,
          elevation: 8,
        ),
        child: Text(text),
      ),
    );
  }

  // 鉱石の中の一行
  Widget _stoneRow(String areaName, String areaKey, String icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          ' $areaName',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        Row(
            children: <Widget>[
              if (listRepopDay[areaKey] == 0) Image.asset('images/$icon.png', height: 32),
              Text(
                'あと${listRepopDay[areaKey]}日',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Padding(padding: EdgeInsets.all(3),),
              ElevatedButton(
                onPressed: () {
                  savePickDate(DateTime.now(), areaKey);
                  setState(() { listRepopDay[areaKey] = repopDay(DateTime.now(), 3); });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                  elevation: 8,
                ),
                child: Text('掘る'),
              ),
            ]
        ),
      ],
    );
  }

  Widget setIcon(String icon) {
    return Image.asset('images/$icon.png', height: 32);
  }

}

// TODO: リファクタリング
// modelを別ファイルにする
// stringファイル作る

// TODO: 天然樹脂、濃縮樹脂
// TODO: 聖遺物（国ごと）
// TODO: 釣り
// TODO: 変転機
// TODO: 栽培

// TODO: 通知
// TODO: アコーディオン
// TODO: アイコン、画像
// TODO: 広告

// TODO: 多言語対応
// TODO: 日本時間以外への対応