import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'view/page/repop_viewer.dart';

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
      localizationsDelegates: const [ // 何これ
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ // 何これ
        locale,
      ],
      home: RepopViewerPage(title: 'Genshin Repop Timer'),
    );
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

// TODO: アコーディオン
// TODO: 広告

// TODO: 多言語対応
// TODO: 日本時間以外への対応