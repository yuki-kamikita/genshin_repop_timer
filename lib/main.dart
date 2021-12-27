import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'view/page/repop_date_viewer.dart';

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
// Riverpodは今更大変そうなので一旦諦め
// modelを別ファイルにする
// stringファイル作る

// TODO: 聖遺物（国ごと）
// TODO: 釣り
// TODO: 栽培
// TODO: 派遣
// TODO: ポケットワープポイント

// TODO: 広告

// TODO: 編集

// 多言語対応
// 日本時間以外への対応