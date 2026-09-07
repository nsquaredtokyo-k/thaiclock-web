import 'dart:async';
import 'package:flutter/material.dart';
import 'thaiwords.dart';
import 'package:url_launcher/url_launcher.dart'; // 外部リンクへ繋げる
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web; // 最新Web標準ライブラリ

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // アプリ全体のテキストフォントを GoogleFonts の Sarabun に一括設定！
        textTheme: GoogleFonts.sarabunTextTheme(
          ThemeData.dark().textTheme, // 時計画面のダークな雰囲気に合わせる場合は dark() がおすすめ
        ),
        // 入れるとしたら、ここに最下層の色指定を入れる
        // scaffoldBackgroundColor: const Color.fromARGB(255, 163, 105, 67),
      ),
      home: const ThaiClockHomeScreen(),
    );
  }
}

class ThaiClockHomeScreen extends StatefulWidget {
  const ThaiClockHomeScreen({super.key});

  @override
  State<ThaiClockHomeScreen> createState() => _ThaiClockHomeScreenState();
}

class _ThaiClockHomeScreenState extends State<ThaiClockHomeScreen> {
  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  bool _showPronunciation = false; // false: タイ語のみ, true: よみがな付き
  late Timer _timer;

  //======================================================

  DateTime _now = DateTime.now();

  // 🔑 App GroupのID（Xcodeの設定と合わせて）
  final String appGroupId = "group.com.example.thaiclockNew";

  // 🌟 3. タイ語の口語時間（6時間周期）変換アルゴリズム（決定版B）
  _ThaiTimeText _convertToThaiTextTime(DateTime date) {
    final hour = date.hour;
    final min = date.minute;

    String hPrefix = "";
    String hNumber = "";
    String hSuffix = "";
    String mText = "";

    // 時間の判定
    if (hour == 0) {
      hNumber = "เที่ยงคืน";
    } else if (hour >= 1 && hour <= 5) {
      hPrefix = "ตี";
      const hoursThai = ["", "หนึ่ง", "สอง", "สาม", "สี่", "ห้า"];
      hNumber = hoursThai[hour];
    } else if (hour >= 6 && hour <= 11) {
      const hoursThai = [
        "",
        "",
        "",
        "",
        "",
        "",
        "หก",
        "เจ็ด",
        "แปด",
        "เก้า",
        "สิบ",
        "สิบเอ็ด"
      ];
      hNumber = hoursThai[hour];
      hSuffix = "โมงเช้า";
    } else if (hour == 12) {
      hNumber = "เที่ยง";
    } else if (hour == 13) {
      hPrefix = "บ่าย";
      hSuffix = "โมง";
    } else if (hour >= 14 && hour <= 15) {
      hPrefix = "บ่าย";
      const hoursThai = ["", "", "สอง", "สาม"];
      hNumber = hoursThai[hour - 12];
      hSuffix = "โมง";
    } else if (hour >= 16 && hour <= 18) {
      const hoursThai = ["", "", "", "", "สี่", "ห้า", "หก"];
      hNumber = hoursThai[hour - 12];
      hSuffix = "โมงเย็น";
    } else if (hour >= 19 && hour <= 23) {
      const hoursThaiCorrected = ["", "หนึ่ง", "สอง", "สาม", "สี่", "ห้า"];
      hNumber = hoursThaiCorrected[hour - 18];
      hSuffix = "ทุ่ม";
    }

    // 分の判定
    if (min == 0) {
      mText = "ตรง";
    } else if (min == 30) {
      mText = "ครึ่ง";
    } else {
      mText = "${_convertNumToThaiText(min)} นาที";
    }

    return _ThaiTimeText(hPrefix, hNumber, hSuffix, mText);
  }

  // 🌟 4. 「秒」のテキスト変換
  String _getThaiSecondsNumberText(int seconds) {
    if (seconds == 0) return "ศูนย์";
    return _convertNumToThaiText(seconds);
  }

  // 🌟 5. 数字をタイ語の読みテキストに変換する汎用関数 (1〜59用)
  String _convertNumToThaiText(int num) {
    const ones = [
      "",
      "หนึ่ง",
      "สอง",
      "สาม",
      "สี่",
      "ห้า",
      "หก",
      "เจ็ด",
      "แปด",
      "เก้า"
    ];

    if (num < 10) {
      return ones[num];
    } else if (num < 20) {
      final tail = num % 10;
      return tail == 0 ? "สิบ" : "สิบ${tail == 1 ? "เอ็ด" : ones[tail]}";
    } else {
      final head = num ~/ 10;
      final tail = num % 10;
      final headText = (head == 2 ? "ยี่" : ones[head]);

      return tail == 0
          ? "$headTextสิบ"
          : "$headTextสิบ${tail == 1 ? "เอ็ด" : ones[tail]}";
    }
  }

  @override
  void initState() {
    super.initState();

    // 1秒ごとに画面を新しくするタイマー

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 🎨 曜日ごとのタイのラッキーカラーを決める関数
  Color _getWeekdayColor(int weekday) {
    // 曜日によって背景!!!!を変える時に必要.
    switch (weekday) {
      case DateTime.sunday:
        return const Color.fromARGB(255, 237, 71, 1); // 🟥 日曜日：赤
      case DateTime.monday:
        return const Color.fromARGB(255, 238, 231, 136); // 🟨 月曜日：黄
      case DateTime.tuesday:
        return const Color.fromARGB(255, 238, 140, 214); // 🩷 火曜日：ピンク
      case DateTime.wednesday: // 水曜日（特別ルール）
        final hour = _now.hour;
        if (hour < 12) {
          return const Color.fromARGB(255, 147, 219, 127); // 🟩水曜日AM
        } else {
          return const Color.fromARGB(255, 146, 143, 143); // 🩶水曜日PM
        }
      case DateTime.thursday:
        return const Color.fromARGB(255, 231, 137, 59); // 🟧 木曜日：オレンジ
      case DateTime.friday:
        return const Color.fromARGB(255, 86, 154, 237); // 🟦 金曜日：青
      case DateTime.saturday:
        return const Color.fromARGB(255, 191, 113, 243); // 🟪 土曜日：紫
      default:
        return Colors.white;
    }
  }

  // 🇹🇭 タイ語の日付（仏暦）テキストを作る関数
  String _getThaiFullDate(DateTime date) {
    final List<String> thaiDays = [
      "",
      "วันจันทร์",
      "วันอังคาร",
      "วันพุธ",
      "วันพฤหัสบดี",
      "วันศุกร์",
      "วันเสาร์",
      "วันอาทิตย์"
    ];
    final List<String> thaiMonths = [
      "",
      "มกราคม",
      "กุมภาพันธ์",
      "มีนาคม",
      "เมษายน",
      "พฤษภาคม",
      "มิถุนายน",
      "กรกฎาคม",
      "สิงหาคม",
      "กันยายน",
      "ตุลาคม",
      "พฤศจิกายน",
      "ธันวาคม"
    ];

    String dayName = thaiDays[date.weekday];
    String monthName = thaiMonths[date.month];
    int thaiYear = date.year + 543; // 西暦 + 543 = 仏暦

    return "$dayName ที่ ${date.day} $monthName $thaiYear";
  }

// --- ⭐️常にタイ時間を計算して「HH:mm」で返す関数 ---⭐️どこにいてもタイの時間
  String _getThailandDigitalTime(DateTime date) {
    // タイ（UTC+7）に変換
    final thaiDateTime = date.toUtc().add(const Duration(hours: 7));

    // HH:mm 形式にする
    final hour = thaiDateTime.hour.toString().padLeft(2, '0');
    final minute = thaiDateTime.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }

// 🔤 よみかた
  String _getPronunciationText(String thaiText) {
    switch (thaiText) {
      // 時間帯の単語
      case 'เที่ยงคืน':
        return '（thîaŋ khɯɯn / ティアンクーン / 真夜中）';
      case 'ตี':
        return '（tii / ティー / 未明）';
      case 'โมงเช้า':
        return '（mooŋ cháaw / モーン・チャーオ / 午前）';
      case 'บ่าย':
        return '（bàay / バーイ / 午後）';
      case 'บ่ายโมง':
        return '（bàay mooŋ / バイモーン / 13時）'; // ⭐️ 13時専用のよみがなを追加
      case 'โมง':
        return '（mooŋ / モーン / 時）';
      case 'โมงเย็น':
        return '（mooŋ yen / モーン・イェン / 夕方）';
      case 'ทุ่ม':
        return '（thûm / トゥム / 夜）';
      case 'เที่ยง':
        return '（thîaŋ / ティアン / 正午）';

      // 数字の読み方
      case 'หนึ่ง':
        return '（nɯ̀ŋ / ヌン / 1）';
      case 'สอง':
        return '（sɔ̌ɔŋ / ソーン / 2）';
      case 'สาม':
        return '（sǎam / サーム / 3）';
      case 'สี่':
        return '（sìi / シー / 4）';
      case 'ห้า':
        return '（hâa / ハー / 5）';
      case 'หก':
        return '（hòk / ホック / 6）';
      case 'เจ็ด':
        return '（cèt / ジェット / 7）';
      case 'แปด':
        return '（pɛ̀ɛt/ ペート / 8）';
      case 'เก้า':
        return '（kâaw / ガーオ / 9）';
      case 'สิบ':
        return '（sìp / シップ / 10）';
      case 'สิบเอ็ด':
        return '（sìp èt / シップ・エット / 11）';

      default:
        return '';
    }
  }

//======＝＝＝＝＝＝＝＝＝
// ⏱️ 分（1〜59）のタイ語よみがなを自動生成する関数
  String _getMinutePronunciation(int minute) {
    // 💡 0分（ตรง）と 30分（ครึ่ง）の読み方をここで先に判定！
    if (minute == 0) {
      return '（troŋ / トロン / ちょうど）';
    }
    if (minute == 30) {
      return '（khɯ̂ŋ / クルン / 半）';
    }

    if (minute <= 0 || minute >= 60) return '';

    // 1〜9の読み方リスト
    final Map<int, Map<String, String>> digits = {
      1: {'phonetic': 'nɯ̀ŋ', 'kana': 'ヌン'},
      2: {'phonetic': 'sɔ̌ɔŋ', 'kana': 'ソーン'},
      3: {'phonetic': 'sǎam', 'kana': 'サーム'},
      4: {'phonetic': 'sìi', 'kana': 'シー'},
      5: {'phonetic': 'hâa', 'kana': 'ハー'},
      6: {'phonetic': 'hòk', 'kana': 'ホック'},
      7: {'phonetic': 'cèt', 'kana': 'ジェット'},
      8: {'phonetic': 'pɛ̀ɛt', 'kana': 'ペート'},
      9: {'phonetic': 'kâaw', 'kana': 'ガーオ'},
    };

    int tens = minute ~/ 10; // 十の位
    int ones = minute % 10; // 一の位

    String pText = '';
    String kText = '';

    // --- 十の位の処理 ---
    if (tens == 1) {
      pText += 'sìp';
      kText += 'シップ';
    } else if (tens == 2) {
      pText += 'yîi sìp';
      kText += 'イー・シップ';
    } else if (tens >= 3) {
      pText += '${digits[tens]!['phonetic']} sìp';
      kText += '${digits[tens]!['kana']}・シップ';
    }

    // --- 一の位の処理 ---
    if (ones > 0) {
      if (tens > 0) {
        pText += ' ';
        kText += '・';
      }
      if (ones == 1 && tens > 0) {
        // 11, 21, 31などの「1」はエット（èt）になる
        pText += 'èt';
        kText += 'エット';
      } else {
        pText += digits[ones]!['phonetic']!;
        kText += digits[ones]!['kana']!;
      }
    }

    // 最後に「分（ナーティー / naathii）」をつける
    return '（$pText naathii / $kText・ナーティー）';
  }

//=============================================
// ⚙️ メニューを表示する関数
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 中身に合わせて高さを自動調整
            children: [
              // --------------------------------------------------
              // 2. よみかたの表示・非表示切り替え
              // --------------------------------------------------
              ListTile(
                leading: Icon(
                  _showPronunciation ? Icons.visibility : Icons.visibility_off,
                  color: _showPronunciation
                      ? Colors.amber
                      : const Color.fromARGB(255, 132, 105, 105),
                ),
                title: Text(
                  _showPronunciation ? 'よみかたを隠す' : 'よみかたを表示する',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 132, 105, 105),
                  ),
                ),
                trailing: Switch(
                  value: _showPronunciation,
                  activeThumbColor: Colors.amber,
                  onChanged: (bool value) {
                    setState(() {
                      _showPronunciation = value;
                    });
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  setState(() {
                    _showPronunciation = !_showPronunciation;
                  });
                  Navigator.pop(context);
                },
              ),

              const Divider(color: Colors.white12), // 区切り線

              // --------------------------------------------------
              // 3. About App リンク（GitHub等へジャンプ）
              // --------------------------------------------------
              // ListTile(
              //   leading: const Icon(Icons.info_outline),
              //   title: const Text('About App'),
              //   trailing: const Icon(Icons.open_in_new, size: 18), // 外部遷移アイコン
              //   onTap: () {
              //     Navigator.pop(context);
              //     // ご自身の GitHub ページの URL に書き換えてね！
              //     _launchURL(
              //         'https://nsquaredtokyo-k.github.io/thaiclock-web/');
              //   },
              // ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // 4. 一番下のアプリ名 ＆ バージョン表記（中央揃え）
              // --------------------------------------------------
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Center(
                  child: Text(
                    'Thai clock v1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

//=============================================
//==========================表示のところを画面サイズに合わせる============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Webサイト全体のダーク背景色
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000), // PC画面での最大幅
              child: Column(
                children: [
                  // ==========================================================
                  // 1. 🔝 ヘッダー（WEBサイトのタイトル）
                  // ==========================================================
                  const Text(
                    '🇹🇭 Thai Clock (タイ語時計) - Web版',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'タイ語独特の時間の読み方をリアルタイムで楽しめる時計アプリ',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // ==========================================================
                  // 2. 📱 メインエリア（PCでは左右分割 / スマホでは上下）
                  // ==========================================================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;

                      // 👈 左側：タイ時計本体（スマホ枠）
                      Widget clockWidget = Container(
                        width: isWide ? 380 : double.infinity,
                        height: 680,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B), // スマホの外枠（ダークグレー）
                          borderRadius: BorderRadius.circular(48), // スマホらしい丸み
                          border: Border.all(
                            color: const Color(0xFF334155), // スマホの縁フレーム
                            width: 8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40), // 液晶画面の角丸
                          child: Column(
                            children: [
                              // スマホ上部のスピーカー（ノッチ風）
                              Container(
                                width: 80,
                                height: 16,
                                margin:
                                    const EdgeInsets.only(top: 8, bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // 液晶画面エリア（従来の時計表示）
                              Expanded(
                                child: Container(
                                  color: const Color.fromARGB(
                                      255, 43, 25, 4), // 従来の時計背景色
                                  padding: const EdgeInsets.all(20.0),
                                  child:
                                      _buildClockContent(context), // 時計の中身を呼び出し
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      // 👉 右側：簡単な説明テキスト
                      Widget descriptionWidget = Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 タイ語の時刻表現について',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'タイ語の時間の言い方は、朝・昼・夕方・夜で使う単語がガラリと変わるユニークな仕組みになっています。\n\n'
                              '・ตี（ティー）：朝方（1時〜5時）\n'
                              '・โมงเช้า（モーンチャオ）：午前中（6時〜11時）\n'
                              '・เที่ยง（ティアン）：正午（12時）\n'
                              '・บ่าย（バーイ）：午後（13時〜15時）\n'
                              '・โมงเย็น（モーンイエン）：夕方（16時〜18時）\n'
                              '・ทุ่ม（トゥム）：夜（19時〜23時）\n'
                              '・เที่ยงคืน（ティアンクーン）：深夜0時\n\n'
                              '※日替わりでタイのラッキーカラー（曜日カラー）が日付に反映されます！',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 250, 248, 248)
                                    .withValues(alpha: 0.87),
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 24), // 上との余白

                            // ★ここから追加ボタン
                            ElevatedButton.icon(
                              onPressed: () {
                                // 幅380px、高さ700pxの小窓をパッと開く
                                web.window.open(
                                  'https://nsquaredtokyo-k.github.io/thaiclock-web/',
                                  'ThaiClockMini',
                                  'width=380,height=700,resizable=yes,scrollbars=no',
                                );
                              },
                              icon: const Icon(Icons.open_in_new, size: 18),
                              label: const Text(' デスクトップ用ミニ時計を開く'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isWide) {
                        // 横幅が広い（PC）ときは左右に並べる
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            clockWidget,
                            const SizedBox(width: 32),
                            Expanded(child: descriptionWidget),
                          ],
                        );
                      } else {
                        // 狭い（スマホ）ときは上下に並べる
                        return Column(
                          children: [
                            clockWidget,
                            const SizedBox(height: 24),
                            descriptionWidget,
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 48),

                  // ==========================================================
                  // 3. 📲 下部：スマホアプリ版のご案内・紹介エリア
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'スマホアプリ版（iOS / Android）ならもっと身近に！',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'タイ数字のアナログ時計🕐ウィジェット機能があり、お気に入りの写真を背景に設定できます',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 24),
// 📸 スクリーンショット3枚並べエリア
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 画面幅に合わせて画像の大きさを調整
                            final isWide = constraints.maxWidth > 600;

                            final screenshots = [
                              'web/images/screenshot1.png',
                              'web/images/screenshot2.png',
                              'web/images/screenshot3.png',
                            ];

                            return Wrap(
                              spacing: 16, // 横の間隔
                              runSpacing: 16, // 縦の間隔（折り返した時）
                              alignment: WrapAlignment.center,
                              children: screenshots.map((path) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    path,
                                    width: isWide ? 220 : 160,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // ⚠️ Androidウィジェット機能に関する注意事項
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ ウィジェット機能に関するご注意（Android版）',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFACC15), // 注意を惹く黄色
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Androidのホーム画面ウィジェット機能は、スマホのバッテリー消費を抑えるシステム仕様（省電力制御）のため、毎分00秒のタイミングで画面更新が行われる仕様となっております。\n'
                                '写真を変更した際、ホーム画面のウィジェットに反映されるまで最大で約1分程度のタイムラグが生じる場合がありますが、アプリおよびシステムの正常な動作によるものです。\n'
                                '※現在、Web版ではホーム画面ウィジェット機能はご利用いただけません。',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ==========================================================
                  // 4. 🔒 フッター（プライバシーポリシー・著作権表示）
                  // ==========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // プライバシーポリシーのダイアログ表示
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF2C2C2E),
                              title: const Text('プライバシーポリシー',
                                  style: TextStyle(color: Colors.white)),
                              content: const SingleChildScrollView(
                                child: Text(
                                  '1. 個人情報の収集について\n'
                                  '当アプリ（Thai Clock）では、ユーザーの氏名、メールアドレス、電話番号などの個人情報を収集・保存・送信することは一切ありません。\n\n'
                                  '2. 写真・画像データへのアクセスについて\n'
                                  '当アプリでは、時計の背景画像を設定する目的でのみ、端末内の写真・ギャラリーへのアクセスを行います。選択された画像データは端末内（ローカル環境）でのみ使用・保存され、外部のサーバー等へ送信されることはありません。\n\n'
                                  '3. 免責事項\n'
                                  '当アプリの利用により生じたトラブルや損害等について、開発者は一切の責任を負いかねますのでご了承ください。\n\n'
                                  '制定日: 2026年9月1日',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.6),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('閉じる',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Privacy Policy',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      const Text(' | ', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () {
                          _launchURL('https://forms.gle/gg1ynzueiQQTfhz8A');
                        },
                        child: const Text('Feedback',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '© 2026 thaiclock-web',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 🕒 従来の時計部分（右下アイコン付き）
  // =========================================================================
  Widget _buildClockContent(BuildContext context) {
    const baseFontSize = 380 * 0.1;
    const clockFontSize = 380 * 0.055;

    return Stack(
      children: [
        // 🔝 上部（デジタル時計 + 日付）
        Positioned(
          left: 0,
          right: 0,
          top: 16,
          bottom: 16,
          child: Column(
            children: [
              // ⏰1段目のタイ時間デジタル（国旗つき）
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "🇹🇭",
                    style: TextStyle(fontSize: clockFontSize),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getThailandDigitalTime(_now),
                    style: const TextStyle(
                      fontSize: clockFontSize,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 199, 212, 83),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 📅 【2段目】タイ語の日付
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _getThaiFullDate(_now),
                  style: TextStyle(
                    fontSize: baseFontSize * 0.5,
                    color: _getWeekdayColor(_now.weekday),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🔥 中央（タイ語テキスト時計）
        Positioned(
          left: 0,
          right: 0,
          top: 60,
          bottom: 40,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Builder(
                builder: (context) {
                  final thaiTime = _convertToThaiTextTime(_now);
                  final int h = _now.hour;

                  String secondText =
                      "${_getThaiSecondsNumberText(_now.second)} วินาที";
                  String minuteLine = thaiTime.minute;
                  List<String> hourLines = [];

                  if (h == 0) {
                    hourLines.add("เที่ยงคืน");
                  } else if (h >= 1 && h <= 5) {
                    hourLines.add("ตี");
                    hourLines.add(thaiTime.number);
                  } else if (h >= 6 && h <= 11) {
                    hourLines.add(thaiTime.number);
                    hourLines.add("โมงเช้า");
                  } else if (h == 12) {
                    hourLines.add("เที่ยง");
                  } else if (h == 13) {
                    hourLines.add("บ่ายโมง");
                  } else if (h == 14 || h == 15) {
                    hourLines.add("บ่าย");
                    hourLines.add(thaiTime.number);
                    hourLines.add("โมง");
                  } else if (h >= 16 && h <= 18) {
                    hourLines.add(thaiTime.number);
                    hourLines.add("โมงเย็น");
                  } else if (h >= 19 && h <= 23) {
                    hourLines.add(thaiTime.number);
                    hourLines.add("ทุ่ม");
                  }

                  if (minuteLine.trim() == "นาที") {
                    minuteLine = "";
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...hourLines.map((line) {
                        final bool isNumber = (line == thaiTime.number) ||
                            (line == "บ่ายโมง") ||
                            (line == "เที่ยง") ||
                            (line == "เที่ยงคืน");

                        final String reading = _getPronunciationText(line);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line,
                                style: TextStyle(
                                  fontSize: isNumber
                                      ? baseFontSize * 3.0
                                      : baseFontSize * 1.5,
                                  fontWeight: FontWeight.bold,
                                  color: isNumber
                                      ? const Color.fromRGBO(202, 201, 201, 1)
                                      : const Color.fromARGB(
                                          255, 105, 104, 104),
                                ),
                              ),
                              if (_showPronunciation && reading.isNotEmpty)
                                Text(
                                  reading,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 221, 208, 162),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      if (minuteLine.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          minuteLine,
                          style: TextStyle(
                            fontSize: baseFontSize * 1.5,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                            color: const Color.fromARGB(255, 105, 104, 104),
                          ),
                        ),
                        if (_showPronunciation)
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Text(
                              _getMinutePronunciation(_now.minute),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 144, 161, 126),
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        secondText,
                        style: TextStyle(
                          fontSize: baseFontSize * 0.5,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(118, 255, 255, 255),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // 4. 右下：単語帳アイコン ＆ ギアアイコン
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📖 上：単語帳アイコン
              IconButton(
                icon: const Icon(Icons.menu_book,
                    size: 28, color: Colors.white54),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThaiVocabularyScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              // ⚙️ ギアアイコン
              IconButton(
                icon:
                    const Icon(Icons.settings, size: 28, color: Colors.white54),
                onPressed: () => _showSettingsMenu(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 🌟 1. Bのコードが使う「タイ語の時間データ」をひとまとめにするクラス
class _ThaiTimeText {
  final String prefix;
  final String number;
  final String suffix;
  final String minute;

  _ThaiTimeText(this.prefix, this.number, this.suffix, this.minute);

  String get formattedClock {
    String hourText = "$prefix$number$suffix".trim();
    return "$hourText\n$minute";
  }
}
