// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, prefer_typing_uninitialized_variables
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/config/theme.dart';
import 'package:hws_app/ui/widgets/common/app_card.dart';
import 'package:hws_app/ui/widgets/common/progress_bar_card.dart';
import 'package:hws_app/ui/widgets/second_screen/text_divider.dart';
import 'package:ionicons/ionicons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Dio dio = Dio();
  final ScrollController scrollController = ScrollController();
  bool showbtn = false;

  Future<void> _pullToRefresh() async {
    setState(() {});
    return;
  }

  @override
  void initState() {
    scrollController.addListener(() {
      double showOffset = 10.0;

      if (scrollController.offset > showOffset) {
        setState(() {
          showbtn = true;
        });
      } else {
        setState(() {
          showbtn = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: Scaffold(
        floatingActionButton: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: showbtn ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: () {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Ionicons.arrow_up_outline,
              color: Colors.white,
            ),
          ),
        ),
        body: Material(
          color: Theme.of(context).colorScheme.background,
          child: Center(
            child: ListView(
              controller: scrollController,
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(5)),
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.2,
                    autoPlay: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 1000),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    onPageChanged: null,
                  ),
                  items: [
                    // TODO: 放正確的 Banner
                    "https://assets.zeczec.com/asset_564910_image_big.jpg?1669375399",
                    "https://assets.zeczec.com/asset_588929_image_big.jpg?1674832431",
                    "https://assets.zeczec.com/asset_579197_image_big.jpg?1671716988",
                    "https://assets.zeczec.com/asset_581729_image_big.jpg?1672369217"
                  ].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            child: Image.network(
                              i,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const TextDivider(text: 'bottom_nav_app'),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                  ),
                  items: [
                    // TODO: 放釘選功能
                    // 四個一組才不跑版
                    ['clock_list', 'api_demo', 'hive_demo', 'file_demo'],
                    ['clock_list', 'api_demo', 'hive_demo', 'file_demo'],
                  ].map((i) {
                    var AppCardItems = <Widget>[];

                    for (var x = 0; x < i.length; x++) {
                      AppCardItems.add(AppCard(appPath: i[x]));
                    }

                    return Builder(
                      builder: (BuildContext context) {
                        return GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2 / 1.4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: AppCardItems,
                        );
                      },
                    );
                  }).toList(),
                ),
                const TextDivider(text: 'analyze'),
                Card(
                  // TODO: 放正確的圖表分析
                  margin: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                  ),
                  shadowColor: Theme.of(context).colorScheme.shadow,
                  color: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: AspectRatio(
                    aspectRatio: 1.5,
                    child: Column(
                      children: const <Widget>[
                        Padding(padding: EdgeInsets.all(5)),
                        Text(
                          'Monthly Sales',
                          style: TextStyle(
                            color: MetronicTheme.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 16, left: 6),
                            child: _LineChart(),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  // TODO: 放正確的進度分析
                  padding: const EdgeInsets.all(5),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 1.4,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: const [
                      ProgressBarCard(
                        barName: 'INCOME',
                        subNumber: 841953,
                        totalNumber: 1000000,
                        barIcon: Ionicons.cash_outline,
                      ),
                      ProgressBarCard(
                        barName: 'SAVINGS',
                        subNumber: 141953,
                        totalNumber: 1000000,
                        barIcon: Ionicons.finger_print_outline,
                      ),
                      ProgressBarCard(
                        barName: 'EXPENSE',
                        subNumber: 541953,
                        totalNumber: 1000000,
                        barIcon: Ionicons.gift_outline,
                      ),
                      ProgressBarCard(
                        barName: 'BILLS',
                        subNumber: 441953,
                        totalNumber: 1000000,
                        barIcon: Ionicons.bug_outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData1,
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData1 => LineChartData(
        // 圖表顯示該值資訊
        lineTouchData: lineTouchData1,
        // 圖表隔線
        gridData: gridData,
        // 圖表 XY 軸的 title 樣式
        titlesData: titlesData1,
        // 圖表外匡
        borderData: borderData,
        // 圖表資料
        lineBarsData: lineBarsData1,
        // 圖表顯示範圍 (最大值-1、最小值-1)
        minX: 0,
        minY: 0,
        maxX: 14,
        maxY: 4,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      ); // 點擊圖表顯示該值

  FlGridData get gridData => FlGridData(show: false); // 圖表隔線

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles,
        ),
      ); // 圖表 XY 軸的 title 樣式

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: MetronicTheme.primary.withOpacity(0.2), width: 4),
          left: BorderSide(
              color: MetronicTheme.primary.withOpacity(0.2), width: 4),
        ),
      ); // 圖表外匡

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
        lineChartBarData1_3,
      ]; // 圖表資料

  SideTitles get leftTitles => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1m';
        break;
      case 2:
        text = '2m';
        break;
      case 3:
        text = '3m';
        break;
      case 4:
        text = '5m';
        break;
      case 5:
        text = '6m';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('SEPT', style: style);
        break;
      case 7:
        text = const Text('OCT', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: MetronicTheme.success.withOpacity(0.8),
        barWidth: 6,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 1.5),
          FlSpot(5, 1.4),
          FlSpot(7, 3.4),
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        color: MetronicTheme.danger.withOpacity(0.8),
        barWidth: 6,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
          color: MetronicTheme.danger.withOpacity(0),
        ),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
        ],
      );

  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: true,
        color: MetronicTheme.warning.withOpacity(0.8),
        barWidth: 6,
        isStrokeCapRound: true,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 2.8),
          FlSpot(3, 1.9),
          FlSpot(6, 3),
          FlSpot(10, 1.3),
          FlSpot(13, 2.5),
        ],
      );
}


