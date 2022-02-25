import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import '../../model/sharedPreference/preference_key.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widget/accordion.dart';
import '../widget/drawable_text.dart';


class RepopViewerPage extends StatefulWidget {
  RepopViewerPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _RepopViewerPageState createState() => _RepopViewerPageState();
}

class _RepopViewerPageState extends State<RepopViewerPage> with WidgetsBindingObserver {
  // 表示する値 //
  List<int> listRepopDay = List.filled(PreferenceKey.values.length, 0);
  List<String> listRepopTime = List.filled(PreferenceKey.values.length, ""); // 分表示と時間表示を切り分ける為、仕方なくStringに

  // 鉱石分けたし、ここも整理しないと
  Map<String, tz.TZDateTime> pickedDateTime = {
    'resin': tz.TZDateTime.now(tz.local),
    'stone': tz.TZDateTime.now(tz.local),
    'artifact': tz.TZDateTime.now(tz.local),
    'fishing': tz.TZDateTime.now(tz.local),
    'transformer': tz.TZDateTime.now(tz.local),
    'gardening': tz.TZDateTime.now(tz.local),
  };
  // TODO: DataClass作成
  Map<String, bool> notificationSetting = {
    'resin': false,
    'stone': false,
    'artifact': false,
    'fishing': false,
    'transformer': false,
    'gardening': false,
  };

  // TODO: リソースに移動
  final Map<String, int> notionIdResource = {
    'resin': 1,
    'stone': 2,
    'artifact': 3,
    'fishing': 4,
    'transformer': 5,
    'gardening': 6
  };

  late BannerAd myBanner;

  // lifecycle //
  @override
  void initState() {
    super.initState();
    readSharedPreference();
    WidgetsBinding.instance?.addObserver(this);
    loadAdMob();
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
  void loadAdMob() {
    String adId = Platform.isAndroid ? "ca-app-pub-1271858702999591/3523686779" : "ca-app-pub-1271858702999591/9865733844";
    String testAdId = Platform.isAndroid ? "ca-app-pub-3940256099942544/6300978111" : "ca-app-pub-3940256099942544/2934735716";
    myBanner = BannerAd(
      // adUnitId: adId, // 本番用
      adUnitId: testAdId, // テスト用ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    );
    myBanner.load();
  }

  // 初期化
  void readSharedPreference() async {
    // 通知設定
    notificationSetting['transformer'] = await PreferenceKey.NotionTransformer.getBoolean(false);

    // 再出現日
    // TODO: 追加したら手動でここにも追加
    // 鉱石
    for (var i = 0; i <= PreferenceKey.Tsurumi.index; i++) {
      listRepopDay[i] = repopDay(await PreferenceKey.values[i].getDateTime(), 3, 7);
    }
    // 聖遺物
    for (var i = PreferenceKey.ArtifactMond.index; i <= PreferenceKey.ArtifactInazuma.index; i++) {
      listRepopTime[i] = repopTime(await PreferenceKey.values[i].getDateTime(), 24);
    }
    // // 釣り
    // for (var i = PreferenceKey.ArtifactMond.index; i <= PreferenceKey.ArtifactInazuma.index; i++) {
    //   listRepopTime[i] = repopTime(await PreferenceKey.values[i].getDateTime(), 24);
    // }
    // 栽培
    for (var i = PreferenceKey.GardeningVegetable.index; i <= PreferenceKey.GardeningMeadow.index; i++) {
      listRepopTime[i] = repopTime(await PreferenceKey.values[i].getDateTime(), 70);
    }
    // 変化器
    listRepopTime[PreferenceKey.Transformer.index] = repopTime(await PreferenceKey.Transformer.getDateTime(), 166);

    pickedDateTime['transformer'] = await PreferenceKey.Transformer.getTZDateTime();

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
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().add(new Duration(days: -3)),
        lastDate: DateTime.now()
    ) ?? DateTime.now();
    picked = picked.add(new Duration(hours: 12)); // 0時だと前日扱いなので適当に12時にでもしとく
    setState(() {
      PreferenceKey.values[areaIndex].setDateTime(picked);
      listRepopDay[areaIndex] = repopDay(picked, 3, 7);
    });
  }

  Future<void> editPickDateTime(BuildContext context, int areaIndex, int interval) async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().add(new Duration(days: -7)),
        lastDate: DateTime.now()
    );
    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 0, minute: 0)
      );
      if (time != null) {
        picked = picked.add(new Duration(hours: time.hour, minutes: time.minute));
        setState(() {
          PreferenceKey.values[areaIndex].setDateTime(picked!);
          listRepopTime[areaIndex] = repopTime(picked, interval);
        });
      }
    }
  }

  // 通知予約
  // TODO: この関数の中で石とか変化機とかごとに分岐させて各々時間を作りたい
  Future<void>? createNotification(int notionId, tz.TZDateTime dateTime, String text) async {
    if (!await PreferenceKey.NotionTransformer.getBoolean(false)) { // 通知offだったら作らない TODO: どの通知かで振り分ける
      return null;
    }

    if (dateTime.isBefore(tz.TZDateTime.now(tz.local))) { // 過去の日付だったら何もしない
      return null;
    }
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
              _stornColumn()
          ),
          _genreCard(
              'images/Item_Artifact.png',
              '聖遺物', // 24h
              false,
              Colors.deepPurple[100]!,
              Column(
                children: [
                  _pickTimeRow('モンド', PreferenceKey.ArtifactMond, 24, '拾う'),
                  _pickTimeRow('璃月', PreferenceKey.ArtifactLiyue, 24, '拾う'),
                  _pickTimeRow('稲妻', PreferenceKey.ArtifactInazuma, 24, '拾う'),
                ]
              )
          ),
          // _genreCard(
          //     'images/Item_Wilderness_Rod.png',
          //     '釣り', // 3日後の5時
          //     false,
          //     Colors.lightBlue[100]!,
          //     null
          // ),
          _genreCard(
              'images/Item_Parametric_Transformer.png',
              '参量物質変化器', // 166h
              true,
              Colors.green[100]!,
              _pickTimeRow('変換', PreferenceKey.Transformer, 166, '変換', true),
          ),
          _genreCard(
              'images/Item_Serenitea_Pot.png',
              '栽培', // 70h
              false,
              Colors.lightGreen[100]!,
              Column(
                children: [
                  _pickTimeRow('素晴らしい野菜畑', PreferenceKey.GardeningVegetable, 70, '栽培'),
                  _pickTimeRow('麗しい花畑', PreferenceKey.GardeningFlower, 70, '栽培'),
                  _pickTimeRow('美しい水田', PreferenceKey.GardeningMeadow, 70, '栽培'),
                ]
              )
          ),
        // Column(children: [
        //   Accordion('Section #1',
        //   'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam bibendum ornare vulputate. Curabitur faucibus condimentum purus quis tristique.'),
        //   Accordion('Section #2',
        //   'Fusce ex mi, commodo ut bibendum sit amet, faucibus ac felis. Nullam vel accumsan turpis, quis pretium ipsum. Pellentesque tristique, diam at congue viverra, neque dolor suscipit justo, vitae elementum leo sem vel ipsum'),
        //   Accordion('Section #3',
        //   'Nulla facilisi. Donec a bibendum metus. Fusce tristique ex lacus, ac finibus quam semper eu. Ut maximus, enim eu ornare fringilla, metus neque luctus est, rutrum accumsan nibh ipsum in erat. Morbi tristique accumsan odio quis luctus.'),
        //   ]),
          ElevatedButton(
            onPressed: () {
              createNotification(0, tz.TZDateTime.now(tz.local).add(Duration(seconds: 3)), 'テスト');
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.grey,
              elevation: 8,
            ),
            child: Text('通知テスト'),
          )
        ],
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        child: AdWidget(ad: myBanner),
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
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
  Column _stornColumn() {
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

  /// あと○時間/分の一行
  Row _pickTimeRow(String title, PreferenceKey preferenceKey, int repopHour, String pick, [bool isNotify = false]) {
    if (isNotify) createNotification(
        notionIdResource['transformer']!,
        pickedDateTime['transformer']!.add(Duration(hours: 166)),
        '参量物質変化器が再使用可能になりました'
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                editPickDateTime(context, preferenceKey.index, repopHour);
              },
              child: Text(
                'あと${listRepopTime[preferenceKey.index]}',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(3),),
            ElevatedButton(
              onPressed: () {
                preferenceKey.setDateTime(DateTime.now());
                setState(() {
                  listRepopTime[preferenceKey.index] = repopTime(DateTime.now(), repopHour);
                });
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.grey,
                elevation: 8,
              ),
              child: Text(pick),
            ),
          ],
        ),
      ],
    );
  }

}