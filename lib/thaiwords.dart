import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThaiVocabularyScreen extends StatefulWidget {
  const ThaiVocabularyScreen({super.key});

  @override
  State<ThaiVocabularyScreen> createState() => _ThaiVocabularyScreenState();
}

class _ThaiVocabularyScreenState extends State<ThaiVocabularyScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _timeKey = GlobalKey();
  final GlobalKey _unitKey = GlobalKey();
  final GlobalKey _numberKey = GlobalKey();
  final GlobalKey _dayKey = GlobalKey();
  final GlobalKey _monthKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // タイ語用の共通テキストスタイル（タイ文字が見やすいように19pxに拡大！）
  TextStyle get _thaiTextStyle => GoogleFonts.sarabun(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title:
            const Text('Thai words🇹🇭', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C221E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 上部チップ（文字サイズを14pxに拡大）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: const Color(0xFF252525),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              children: [
                _buildCategoryChip('Time/時刻', Icons.access_time,
                    () => _scrollToSection(_timeKey)),
                _buildCategoryChip('Time unit/時間の単位', Icons.timer,
                    () => _scrollToSection(_unitKey)),
                _buildCategoryChip(
                    'No./数字', Icons.tag, () => _scrollToSection(_numberKey)),
                _buildCategoryChip('DoW/曜日', Icons.calendar_today,
                    () => _scrollToSection(_dayKey)),
                _buildCategoryChip('Mon/月', Icons.calendar_month,
                    () => _scrollToSection(_monthKey)),
              ],
            ),
          ),

          // 表の本体（ピンチで拡大縮小できるようにInteractiveViewerを追加！）
          Expanded(
            child: InteractiveViewer(
              minScale: 1.0, // 最小（標準サイズ）
              maxScale: 4.0, // 最大4倍まで拡大可能
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 時刻
                    _buildSectionTitle('Time/時刻（時間を表す言葉）', Icons.access_time,
                        key: _timeKey),
                    _buildSimpleTable([
                      [
                        'เที่ยงคืน',
                        'thîaŋ khɯɯn / ティアンクーン',
                        '0:00（夜中12時/Midnight）'
                      ],
                      ['ตีหนึ่ง', 'tii nɯ̀ŋ / ティー・ヌン', '1:00（午前1時）'],
                      ['ตีสอง', 'tii sɔ̌ɔŋ / ティー・ソーン', '2:00（午前2時）'],
                      ['ตีสาม', 'tii sǎam / ティー・サーム', '3:00（午前3時）'],
                      ['ตีสี่', 'tii sìi / ティー・シー', '4:00（午前4時）'],
                      ['ตีห้า', 'tii hâa / ティー・ハー', '5:00（午前5時）'],
                      [
                        'หกโมงเช้า',
                        'hòk mooŋ cháaw / ホック・モーン・チャーオ',
                        '6:00（午前6時）'
                      ],
                      [
                        'เจ็ดโมงเช้า',
                        'cèt mooŋ cháaw / ジェット・モーン・チャーオ',
                        '7:00（午前7時）'
                      ],
                      [
                        'แปดโมงเช้า',
                        'pɛ̀ɛt mooŋ cháaw / ペート・モーン・チャーオ',
                        '8:00（午前8時）'
                      ],
                      [
                        'เก้าโมงเช้า',
                        'kâaw mooŋ cháaw / ガーオ・モーン・チャーオ',
                        '9:00（午前9時）'
                      ],
                      [
                        'สิบโมงเช้า',
                        'sìp mooŋ cháaw / シップ・モーン・チャーオ',
                        '10:00（午前10時）'
                      ],
                      [
                        'สิบเอ็ดโมงเช้า',
                        'sìp èt mooŋ cháaw / シップ・エット・モーン・チャーオ',
                        '11:00（午前11時）'
                      ],
                      ['เที่ยง', 'thîaŋ / ティアン', '12:00（正午/Noon）'],
                      ['บ่ายโมง', 'bàay mooŋ / バーイ・モーン', '13:00（午後1時）'],
                      [
                        'บ่ายสองโมง',
                        'bàay sɔ̌ɔŋ mooŋ / バーイ・ソーン・モーン',
                        '14:00（午後2時）'
                      ],
                      [
                        'บ่ายสามโมง',
                        'bàay sǎam mooŋ / バーイ・サーム・モーン',
                        '15:00（午後3時）'
                      ],
                      [
                        'สี่โมงเย็น',
                        'sìi mooŋ yen / シー・モーン・イェン',
                        '16:00（午後4時）'
                      ],
                      [
                        'ห้าโมงเย็น',
                        'hâa mooŋ yen / ハー・モーン・イェン',
                        '17:00（午後5時）'
                      ],
                      [
                        'หกโมงเย็น',
                        'hòk mooŋ yen / ホック・モーン・イェン',
                        '18:00（午後6時）'
                      ],
                      ['หนึ่งทุ่ม', 'nɯ̀ŋ thûm / ヌン・トゥム', '19:00（夜7時）'],
                      ['สองทุ่ม', 'sɔ̌ɔŋ thûm / ソーン・トゥム', '20:00（夜8時）'],
                      ['สามทุ่ม', 'sǎam thûm / サーム・トゥム', '21:00（夜9時）'],
                      ['สี่ทุ่ม', 'sìi thûm / シー・トゥム', '22:00（夜10時）'],
                      ['ห้าทุ่ม', 'hâa thûm / ハー・トゥム', '23:00（夜11時）'],
                    ]),

                    const SizedBox(height: 24),

                    // 2. 時間の単位
                    _buildSectionTitle('Time unit/時間帯・単位', Icons.timer,
                        key: _unitKey),
                    _buildSimpleTable([
                      ['เที่ยงคืน', 'thîaŋ khɯɯn / ティアンクーン', '真夜中/Midnight'],
                      ['ตี', 'tii / ティー', '未明/Small hours'],
                      ['โมงเช้า', 'mooŋ cháaw / モーン・チャーオ', '午前/AM'],
                      ['เที่ยง', 'thîaŋ / ティアン', '正午/Noon'],
                      ['บ่าย', 'bàay / バーイ', '午後/early afternoon'],
                      ['โมงเย็น', 'mooŋ yen / モーン・イェン', '夕方/late afternoon'],
                      ['ทุ่ม', 'thûm / トゥム', '夜/Evening,Night'],
                      ['โมง', 'mooŋ / モーン', '時/Hour'],
                      ['นาที', 'naathii / ナーティー', '分/Minute'],
                      ['วินาที', 'wínaathii / ウィナーティー', '秒/Second'],
                      ['ตรง', 'troŋ / トロン', 'ぴったり/Exactly'],
                      ['ครึ่ง', 'khɯ̂ŋ / クルン', '半分/Half past'],
                    ]),

                    const SizedBox(height: 24),

                    // 3. 数字
                    _buildSectionTitle('Numbers/数字', Icons.tag,
                        key: _numberKey),
                    _buildSimpleTable([
                      ['ศูนย์', 'sǔun / スーン', '0 (๐)'],
                      ['หนึ่ง', 'nɯ̀ŋ / ヌン', '1 (๑)'],
                      ['สอง', 'sɔ̌ɔŋ / ソーン', '2 (๒)'],
                      ['สาม', 'sǎam / サーム', '3 (๓)'],
                      ['สี่', 'sìi / シー', '4 (๔)'],
                      ['ห้า', 'hâa / ハー', '5 (๕)'],
                      ['หก', 'hòk / ホック', '6 (๖)'],
                      ['เจ็ด', 'cèt / ジェット', '7 (๗)'],
                      ['แปด', 'pɛ̀ɛt / ペート', '8 (๘)'],
                      ['เก้า', 'kâaw / ガーオ', '9 (๙)'],
                      ['สิบ', 'sìp / シップ', '10 (๑๐)'],
                      ['สิบเอ็ด', 'sìp èt / シップ・エット', '11 (๑๑)'],
                      ['สิบสอง', 'sìp sɔ̌ɔŋ / シップ・ソーン', '12 (๑๒)'],
                      ['ยี่สิบ', 'yîi sìp / イー・シップ', '20 (๒๐)'],
                      ['ยี่สิบเอ็ด', 'yîi sìp èt / イー・シップ・エット', '21 (๒๑)'],
                      ['ยี่สิบสอง', 'yîi sìp sɔ̌ɔŋ / イー・シップ・ソーン', '22 (๒๒)'],
                      ['สามสิบ', 'sǎam sìp / サーム・シップ', '30 (๓๐)'],
                      ['สี่สิบ', 'sìi sìp / シー・シップ', '40 (๔๐)'],
                      ['ห้าสิบ', 'hâa sìp / ハー・シップ', '50 (๕๐)'],
                      ['หกสิบ', 'hòk sìp / ホック・シップ', '60 (๖๐)'],
                      ['เจ็ดสิบ', 'cèt sìp / ジェット・シップ', '70 (๗๐)'],
                      ['แปดสิบ', 'pɛ̀ɛt sìp / ペート・シップ', '80 (๘๐)'],
                      ['เก้าสิบ', 'kâaw sìp / ガーオ・シップ', '90 (๙๐)'],
                      ['เก้าสิบเก้า', 'kâaw sìp kâaw / ガーオ・シップ・ガーオ', '99 (๙๙)'],
                      //['ร้อย', 'rɔ́ɔy / ローイ', '100'],
                      ['(หนึ่ง)ร้อย', '(nɯ̀ŋ) rɔ́ɔy / (ヌン)ローイ', '100（1百）'],
                      //['พัน', 'phan / パン', '1,000'],
                      ['(หนึ่ง)พัน', '(nɯ̀ŋ) phan / (ヌン)パン', '1,000（1千）'],
                      //  ['หมื่น', 'mɯ̀ɯn / ムーン', '10,000'],
                      ['(หนึ่ง)หมื่น', '(nɯ̀ŋ) mɯ̀ɯn / (ヌン)ムーン', '10,000（1万）'],
                      // ['แสน', 'sɛ̌ɛn / セーン', '100,000'],
                      ['(หนึ่ง)แสน', '(nɯ̀ŋ) sɛ̌ɛn / (ヌン)セーン', '100,000（10万）'],
                      // ['ล้าน', 'láan / ラーン', '1,000,000'],
                      [
                        '(หนึ่ง)ล้าน',
                        '(nɯ̀ŋ) láan / (ヌン)ラーン',
                        '1,000,000（100万）'
                      ],
                      ['สิบล้าน', 'sìp láan / シップ・ラーン', '10,000,000（1000万）'],
                      [
                        'หนึ่งร้อยล้าน',
                        'nɯ̀ŋ rɔ́ɔy láan / (ヌン・ローイ・ラーン',
                        '100,000,000（1億）'
                      ],
                    ]),

                    const SizedBox(height: 24),

                    // 4. 曜日
                    // _buildSectionTitle('Day of Week/曜日', Icons.calendar_today,
                    //   key: _dayKey),
                    //_buildSimpleTable([
                    // ['วันจันทร์', 'wan can / ワン・ジャン', '月曜日/Mon'],
                    //['วันอังคาร', 'wan aŋkhaana / ワン・アンカーン', '火曜日/Tue'],
                    //['วันพุธ', 'wan phut / ワン・プット', '水曜日/Wed'],
                    //[
                    // 'วันพฤหัส(บดี)',
                    // 'wan phárɯ́hàt(sabɔɔdii)  / ワン・パルハット(サボーディー)',
                    // '木曜日/Thu'
                    //],
                    //['วันศุกร์', 'wan sùk / ワン・スック', '金曜日/Fri'],
                    //['วันเสาร์', 'wan sǎaw / ワン・サオ', '土曜日/Sat'],
                    //['วันอาทิตย์', 'wan aathít / ワン・アーティット', '日曜日/Sun'],
                    //]),

                    //const SizedBox(height: 24),

// 4. 曜日
                    // 4. 曜日（はみ出し対策版）
                    _buildSectionTitle('Day of Week/曜日', Icons.calendar_today,
                        key: _dayKey),
                    _buildSimpleTable([
                      [
                        'วันจันทร์',
                        'wan can / ワン・ジャン',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('月曜日/Mon',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4), // テキストとアイコンの間に少し隙間
                            Icon(Icons.nightlight,
                                color: Color.fromARGB(199, 229, 226, 127),
                                size: 18),
                          ],
                        ),
                      ],
                      [
                        'วันอังคาร',
                        'wan aŋkhaana / ワン・アンカーン',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('火曜日/Tue',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4),
                            Icon(Icons.diamond,
                                color: Color.fromARGB(255, 240, 113, 200),
                                size: 18),
                          ],
                        ),
                      ],
                      [
                        'วันพุธ',
                        'wan phut / ワン・プット',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('水曜日/Wed',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4),
                            // アイコンが2つあるので、ここだけ横並び（Row）にするか、
                            // 完全に縦並びにするか選べるよ。
                            // ここは2つを横に並べる方法で書いておくね。もしこれでもはみ出るなら、Columnの中に2つのIconを縦に並べてね。
                            Row(
                              children: const [
                                Icon(Icons.nature,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 4), // アイコン同士の間に隙間
                                Icon(Icons.pets, color: Colors.grey, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ],
                      [
                        'วันพฤหัส(บดี)',
                        'wan phárɯ́hàt(sabɔɔdii) / ワン・パルハット(サボーディー)',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('木曜日/Thu',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4),
                            Icon(Icons.sports_basketball,
                                color: Color.fromARGB(255, 255, 149, 0),
                                size: 18),
                          ],
                        ),
                      ],
                      [
                        'วันศุกร์',
                        'wan sùk / ワン・スック',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('金曜日/Fri',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4),
                            Icon(Icons.water_drop,
                                color: Colors.lightBlue, size: 18),
                          ],
                        ),
                      ],
                      [
                        'วันเสาร์',
                        'wan sǎaw / ワン・サオ',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('土曜日/Sat',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4),
                            Icon(Icons.wine_bar,
                                color: Colors.purple, size: 18),
                          ],
                        ),
                      ],
                      [
                        'วันอาทิตย์',
                        'wan aathít / ワン・アーティット',
                        Column(
                          // Columnで縦に並べる
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // 左寄せにする
                          children: const [
                            Text('日曜日/Sun',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                            SizedBox(height: 4),
                            Icon(Icons.sunny,
                                color: Color.fromARGB(255, 255, 69, 7),
                                size: 18),
                          ],
                        ),
                      ],
                    ]),

                    const SizedBox(height: 24),

                    // 5. 月
                    _buildSectionTitle('Month/月', Icons.calendar_month,
                        key: _monthKey),
                    _buildSimpleTable([
                      ['เดือน', 'dɯan / ドゥアン', '月（〜月）/Month'],
                      [
                        'มกราคม',
                        'mákkaraakhom / マッガラーコム Mókkaraakhom/モッガラーコム',
                        '1月（ม.ค.）/Jan'
                      ],
                      ['กุมภาพันธ์', 'kumphaaphan / グンパーパン', '2月 (ก.พ.)/Feb'],
                      ['มีนาคม', 'miinaakhom / ミーナーコム', '3月 (มี.ค.)/Mar'],
                      ['เมษายน', 'meesǎayon / メーサーヨン', '4月 (เม.ย.)/Apr'],
                      [
                        'พฤษภาคม',
                        'phrɯ́tsaphaakhom / プルッサパーコム',
                        '5月 (พ.ค.)/May'
                      ],
                      ['มิถุนายน', 'míthùnaayon / ミトゥナーヨン', '6月 (มิ.ย.)/Jun'],
                      ['กรกฎาคม', 'karákàdaakhom / ガラガダーコム', '7月 (ก.ค.)/Jul'],
                      ['สิงหาคม', 'sǐŋhǎakhom / シンハーコム', '8月 (ส.ค.)/Aug'],
                      ['กันยายน', 'kanyaayon / ガンヤーヨン', '9月 (ก.ย.)/Sep'],
                      ['ตุลาคม', 'tùlaakhom / トゥラーコム', '10月 (ต.ค.)/Oct'],
                      [
                        'พฤศจิกายน',
                        'phrɯ́tsacìkaayon / プルッサジガーヨン',
                        '11月 (พ.ย.)/Nov'
                      ],
                      ['ธันวาคม', 'thanwaakhom / タンワーコーム', '12月 (ธ.ค.)/Dec'],
                    ]),
                    const SizedBox(height: 40),
// 可愛いアイコンとフッターメッセージ
                    Center(
                      child: Column(
                        children: [
                          // アイコンを並べる（お好みのアイコンに変えてね！）
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_nature,
                                  color: Color.fromARGB(255, 144, 187, 157),
                                  size: 28),
                              SizedBox(width: 12),
                              Icon(Icons.local_florist,
                                  color: Color.fromARGB(255, 241, 215, 138),
                                  size: 36),
                              SizedBox(width: 12),
                              Icon(Icons.wb_sunny,
                                  color: Color.fromARGB(255, 239, 196, 140),
                                  size: 28),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'สบาย ๆ ',
                            style: GoogleFonts.sawarabiGothic(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50), // 一番下に少しゆとりを持たせる
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // カテゴリチップパーツ（サイズ拡大）
  Widget _buildCategoryChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.amberAccent),
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      backgroundColor: const Color(0xFF3E3E3E),
      onPressed: onTap,
    );
  }

  // アイコン付きの見出しパーツ（タイトルサイズ拡大）
  Widget _buildSectionTitle(String title, IconData icon,
      {required GlobalKey key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  // エクセル風テーブルパーツ（読み方・意味の文字サイズ拡大 ＆ Widget対応版）
  Widget _buildSimpleTable(List<List<dynamic>> data) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade700, width: 0.8),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1.8),
        2: FlexColumnWidth(1.5),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFF333333)),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('タイ文字',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                      fontSize: 15)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('読み方',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                      fontSize: 15)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('意味',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                      fontSize: 15)),
            ),
          ],
        ),
        ...data.map(
          (row) => TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(row[0].toString(), style: _thaiTextStyle),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(row[1].toString(),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 15)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // 3列目がWidget（Rowなど）ならそのまま表示、文字列ならTextにする仕組み
                child: row[2] is Widget
                    ? row[2]
                    : Text(row[2].toString(),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 15)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
