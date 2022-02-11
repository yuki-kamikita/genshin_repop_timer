import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'view/page/repop_date_viewer.dart';

void main() {
  // AdMob初期化
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // TimeZone初期化
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));

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

// TODO: 釣り
// TODO: 派遣
// TODO: ポケットワープポイント

// TODO: 編集

// 多言語対応
// 日本時間以外への対応