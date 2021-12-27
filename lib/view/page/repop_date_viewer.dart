import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../model/sharedPreference/preference_key.dart';
import '../widget/accordion.dart';
import '../widget/drawable_text.dart';


class RepopViewerPage extends StatefulWidget {
  RepopViewerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _RepopViewerPageState createState() => _RepopViewerPageState();
}

class _RepopViewerPageState extends State<RepopViewerPage> with WidgetsBindingObserver {
  // 変数定義 //
  // int _originalResin = 0;
  // int _condensedResin = 0;

  List<int> listRepopDay = List.filled(PreferenceKey.values.length, 0);

  // 鉱石分けたし、ここも整理しないと
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

  String transformTime = "";

  // lifecycle //
  @override
  void initState() {
    super.initState();
    readSharedPreference();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // LifeCycle
  // https://gaprot.jp/2021/09/14/flutter-lifecycle/
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      readSharedPreference();
      // } else if (state == AppLifecycleState.paused) {
      // } else if (state == AppLifecycleState.detached) {
      // } else if (state == AppLifecycleState.inactive) {
    }
  }

  // 共通関数 //
  void readSharedPreference() async {
    // _originalResin = await PreferenceKey.OriginalResinCount.getInt(0);

    // 通知設定
    notificationSetting['transformer'] = await PreferenceKey.NotionTransformer.getBoolean(false);

    // 再出現日
    for (var i = 0; i < 13; i++) { // 鉱石上詰め
      listRepopDay[i] = repopDay(await PreferenceKey.values[i].getDateTime(), 3, 7);
    }

    pickedDateTime['transformer'] = await PreferenceKey.Transformer.getTZDateTime();
    transformTime = repopTime(await PreferenceKey.Transformer.getDateTime(), 166);

    setState(() {});
  }

  /// 再出現日
  /// @param
  /// pickedDate: 掘った日時
  /// interval:   再出現までの日数
  /// popTime:    再出現する時間
  /// @return:    再出現までの残り時間
  int repopDay(DateTime pickedDate, int interval, int popTime) {
    DateTime popDateTime = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day+interval, pickedDate.hour-popTime);
    DateTime popDate = new DateTime(popDateTime.year, popDateTime.month, popDateTime.day);
    final Duration difference = popDate.difference(DateTime.now().add(Duration(hours: popTime) * -1));
    int day = difference.inDays + 1;
    if (popDate.isBefore(DateTime.now())) day = 0;
    return day;
  }

  String repopTime(DateTime pickedDate, int interval) {
    DateTime popDateTime = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedDate.hour+interval);
    final Duration difference = popDateTime.difference(DateTime.now());
    int hour = difference.inHours;
    int minute = difference.inMinutes;
    // if (popDateTime.isBefore(DateTime.now())) hour = 0;
    String remainTime = "0分";
    if (hour > 0) {
      remainTime = "$hour時間";
    } else if (minute > 0){
      remainTime = "$minute分";
    }
    return remainTime;
  }

  /// 現状鉱石専用
  Future<void> editPickDate(BuildContext context, int areaIndex) async {
    // TODO: showDateTimePicker作ろっかなぁ
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().add(new Duration(days: -3)),
        lastDate: DateTime.now()
    ) ?? DateTime.now();
    // TimeOfDay? time = await showTimePicker(
    //   context: context,
    //   initialTime: TimeOfDay.now()
    // );
    picked = picked.add(new Duration(hours: 12)); // 0時だと前日扱いなので適当に12時にでもしとく
    setState(() {
      // Fluttertoast.showToast(msg: "$picked");
      PreferenceKey.values[areaIndex].setDateTime(picked);
      listRepopDay[areaIndex] = repopDay(picked, 3, 7);
    });
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

  // 画面レイアウト //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(5),
        children: <Widget>[
          _genreCard(
              'images/Item_Magical_Crystal_Chunk.png',
              '鉱石', // 3日後の7時
              false,
              Colors.indigo[100]!,
              _stornRow()
          ),
          _genreCard(
              'images/Item_Artifact.png',
              '聖遺物', // 24h
              false,
              Colors.deepPurple[100]!,
              null
          ),
          _genreCard(
              'images/Item_Wilderness_Rod.png',
              '釣り', // 3日後の5時
              false,
              Colors.lightBlue[100]!,
              null
          ),
          _genreCard(
              'images/Item_Parametric_Transformer.png',
              '参量物質変化器', // 166h
              true,
              Colors.green[100]!,
              _transformerRow()
          ),
          _genreCard(
            'images/Item_Serenitea_Pot.png',
            '栽培', // 70h
            false,
            Colors.lightGreen[100]!,
            null
          )
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

  // レイアウトコンポーネント //
  /// 鉱石とかの大分類
  Card _genreCard(String iconPath, String title, bool notification, Color color, Widget? child) {
    return Card(
      margin: EdgeInsets.all(5),
      color: color,
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
                      Image.asset(iconPath, height: 32),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  if (notification) Row( // TODO: 何の通知を出すかを切り分ける
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
                          PreferenceKey.NotionTransformer.setBoolean(newValue);
                          changeNotification(newValue, notionIdResource['transformer']!, pickedDateTime['transformer']!.add(Duration(hours: 166)) ,'参量物質変化器が再使用可能になりました');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (child != null) child // TODO: 全部実装したらnull判定を消す
            ]
        ),
      ),
    );
  }

  /// 鉱石
  Column _stornRow() {
    return Column(
        children: [
          _stoneRegionCard(
              'images/Element_Anemo.png',
              'モンド',
              Colors.green[100]!,
              Column(
                children: [
                  _stoneAreaRow('蒼風の高地', PreferenceKey.Windwail.index, 'Item_Crystal_Chunk'),
                  _stoneAreaRow('望風山地', PreferenceKey.Stormbearer.index, 'Item_Crystal_Chunk'),
                  _stoneAreaRow('風龍廃墟', PreferenceKey.Stormterror.index, 'Item_Crystal_Chunk'),
                  _stoneAreaRow('軽策荘', PreferenceKey.Qingce.index, 'Item_Crystal_Chunk'),
                ],
              )
          ),
          _stoneRegionCard(
              'images/Element_Geo.png',
              '璃月',
              Colors.orange[100]!,
              Column(
                children: [
                  _stoneAreaRow('璃沙郊', PreferenceKey.Lisha.index, 'Item_Crystal_Chunk'),
                  _stoneAreaRow('孤雲閣', PreferenceKey.Guyun.index, 'Item_Crystal_Chunk'),
                  _stoneAreaRow('慶雲頂', PreferenceKey.Qingyun.index, 'Item_Crystal_Chunk'),
                  _stoneAreaRow('奥蔵山', PreferenceKey.Aocang.index, 'Item_Crystal_Chunk'),
                ],
              )
          ),
          _stoneRegionCard(
              'images/Element_Electro.png',
              '稲妻',
              Colors.purple[100]!,
              Column(
                children: [
                  _stoneAreaRow('鳴神島', PreferenceKey.Narukami.index, 'Item_Amethyst_Lump'),
                  _stoneAreaRow('神無塚', PreferenceKey.Kannazuka.index, 'Item_Amethyst_Lump'),
                  _stoneAreaRow('ヤシオリ島', PreferenceKey.Yashiori.index, 'Item_Amethyst_Lump'),
                  _stoneAreaRow('海祇島', PreferenceKey.Watatsumi.index, 'Item_Amethyst_Lump'),
                  _stoneAreaRow('セイライ島', PreferenceKey.Seirai.index, 'Item_Amethyst_Lump'),
                  _stoneAreaRow('鶴観', PreferenceKey.Tsurumi.index, 'Item_Amethyst_Lump'),
                ],
              )
          ),
        ]
    );
  }

  /// 鉱石 国ごと
  Card _stoneRegionCard(String iconPath, String title, Color color, Column child) {
    return Card(
      margin: EdgeInsets.all(5),
      color: color,
      // child: Text('a'),
      child: Padding(
          padding: EdgeInsets.only(left: 5, right: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
            children: <Widget>[
              Row(
                children: [
                  Image.asset(iconPath, height: 32),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              child
            ],
          )
      ),
    );
  }

  /// 鉱石の中の一行
  Row _stoneAreaRow(String areaName, int areaIndex, String icon) {
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
              if (listRepopDay[areaIndex] == 0) Image.asset('images/$icon.png', height: 32),
              GestureDetector(
                onTap: () {
                  editPickDate(context, areaIndex);
                },
                child: Text(
                  'あと${listRepopDay[areaIndex]}日',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(3),),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    PreferenceKey.values[areaIndex].setDateTime(DateTime.now());
                    listRepopDay[areaIndex] = repopDay(DateTime.now(), 3, 7);
                  });
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

  /// 変化器
  Row _transformerRow() {
    return Row(
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
              // remainingTime(),
              'あと$transformTime',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Padding(padding: EdgeInsets.all(3),),
            ElevatedButton(
              onPressed: () {
                pickedDateTime['transformer'] = tz.TZDateTime.from(DateTime.now(), tz.UTC); // これ要らなくね
                PreferenceKey.Transformer.setDateTime(DateTime.now());
                createNotification(notionIdResource['transformer']!, tz.TZDateTime.now(tz.UTC).add(Duration(hours: 166)), '参量物質変化器が再使用可能になりました');
                setState(() { transformTime = repopTime(DateTime.now(), 166); });
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
    );
  }
  //
  // Widget setIcon(String icon) {
  //   return Image.asset('images/$icon.png', height: 32);
  // }

}