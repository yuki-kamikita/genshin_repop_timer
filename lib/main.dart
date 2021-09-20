import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genshin Repop Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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

class _TopPageState extends State<TopPage> {
  int _originalResin = 0;
  int _condensedResin = 0;

  @override
  void initState() {
    super.initState();
    readSharedPreference();
  }

  void readSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _originalResin = prefs.getInt('originalResinCount') ?? 0;
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

  String text = '';
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
  void savePickDate(DateTime dateTime, String key) async {
    initializeDateFormatting("ja_JP");
    DateFormat formatter = new DateFormat('M/d(E)', "ja_JP");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, dateTime.toString());
    setState(() {
      listRepopDay[key] = repopDay(dateTime, 3);
      // text = "${listDay[key]}日後 ${formatter.format(dateTime.add(Duration(days: 3)))}";
    });
  }

  int repopDay(DateTime pickedDate, int interval) {
    DateTime popDateTime = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day+interval, pickedDate.hour-5);
    DateTime popDate = new DateTime(popDateTime.year, popDateTime.month, popDateTime.day);
    final Duration difference = popDate.difference(DateTime.now());
    int day = difference.inDays + 1;
    if (day < 0) day = 0;
    return day;
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
                  Text(
                    '樹脂',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '天然樹脂', // 8m
                        style: TextStyle(
                          fontSize: 20,
                        ),
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
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _changeOriginalResin(-60);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            elevation: 8,
                          ),
                          child: Text('-60'),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(3),),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _changeOriginalResin(-40);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            elevation: 8,
                          ),
                          child: Text('-40'),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(3),),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _changeOriginalResin(-30);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            elevation: 8,
                          ),
                          child: Text('-30'),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(3),),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _changeOriginalResin(-20);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            elevation: 8,
                          ),
                          child: Text('-20'),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(3),),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            _changeOriginalResin(60);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            elevation: 8,
                          ),
                          child: Text('+60'),
                        ),
                      ),
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
                  Text(
                    '鉱石',
                    style: TextStyle(
                      fontSize: 24,
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
                          Text(
                            'モンド',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                ' 蒼風の高地',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'あと${listRepopDay['Windwail']}日',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      savePickDate(DateTime.now(), 'Windwail');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      elevation: 8,
                                    ),
                                    child: Text('掘った'),
                                  ),
                                ]
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                ' 望風山地',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'あと${listRepopDay['Stormbearer']}日',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      savePickDate(DateTime.now(), 'Stormbearer');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      elevation: 8,
                                    ),
                                    child: Text('掘った'),
                                  ),
                                ]
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                ' 風龍廃墟',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Row(
                                  children: <Widget>[
                                    Text(
                                      'あと${listRepopDay['Stormterror']}日',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        savePickDate(DateTime.now(), 'Stormterror');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey,
                                        elevation: 8,
                                      ),
                                      child: Text('掘った'),
                                    ),
                                  ]
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                ' 軽策荘',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    'あと${listRepopDay['Qingce']}日',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      savePickDate(DateTime.now(), 'Qingce');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.grey,
                                      elevation: 8,
                                    ),
                                    child: Text('掘った'),
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Colors.brown[100],
                    child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                          children: <Widget>[
                            Text(
                              '璃月',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 璃沙郊',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Lisha']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Lisha');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 孤雲閣',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Guyun']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Guyun');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 慶雲頂',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Qingyun']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Qingyun');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 奥蔵山',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Aocang']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Aocang');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                          ],
                        )
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(5),
                    color: Colors.yellow[100],
                    child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Columnの中身をmatch_parentsにする
                          children: <Widget>[
                            Text(
                              '稲妻',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 鳴神島',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Narukami']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Narukami');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 神無塚',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Kannazuka']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Kannazuka');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' ヤシオリ島',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Yashiori']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Yashiori');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' 海祇島',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Watatsumi']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Watatsumi');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  ' セイライ島',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                Row(
                                    children: <Widget>[
                                      Text(
                                        'あと${listRepopDay['Seirai']}日',
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          savePickDate(DateTime.now(), 'Seirai');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.grey,
                                          elevation: 8,
                                        ),
                                        child: Text('掘った'),
                                      ),
                                    ]
                                ),
                              ],
                            ),
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
            color: Colors.purple[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text(
                '聖遺物', // 24h
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.lightBlue[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text(
                '釣り', // 3日後の5時
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.green[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text(
                '参量物質変化器', // 166h
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(5),
            color: Colors.lightGreen[100],
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: Text(
                '栽培', // 70h
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: リファクタリング

// TODO: 天然樹脂、濃縮樹脂
// TODO: 聖遺物（国ごと）
// TODO: 釣り
// TODO: 変転機
// TODO: 栽培

// TODO: 通知
// TODO: アコーディオン
// TODO: アイコン、画像
// TODO: 広告