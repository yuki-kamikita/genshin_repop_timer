import 'package:flutter/material.dart';

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

  void _changeOriginalResin(int value) {
    setState(() {
      int changedOriginalResin = _originalResin + value;
      if (changedOriginalResin >= 0) {
        _originalResin = changedOriginalResin;
      }
    });
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
                          fontSize: 24,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            _originalResin.toString(),
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            '/160',
                            style: TextStyle(
                              fontSize: 24,
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
                            elevation: 16,
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
                            elevation: 16,
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
                            elevation: 16,
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
                            elevation: 16,
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
                            elevation: 16,
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
              child: Text(
                '鉱石', // 3日後の5時
                style: TextStyle(
                  fontSize: 24,
                ),
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

// 天然樹脂、濃縮樹脂
// 三日石（地方ごと）、聖遺物（国ごと）、釣り、変転機
// 変わったヒルチャール（デフォルトoff）
// オプションで
// 表示on/off
// 通知時間の設定