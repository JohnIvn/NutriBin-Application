import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nutribin_application/pages/fertilizer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample NPK data for the week
  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Mon', 'nitrogen': 20, 'phosphorus': 35, 'potassium': 15},
    {'day': 'Tue', 'nitrogen': 25, 'phosphorus': 40, 'potassium': 18},
    {'day': 'Wed', 'nitrogen': 22, 'phosphorus': 38, 'potassium': 20},
    {'day': 'Thu', 'nitrogen': 28, 'phosphorus': 45, 'potassium': 22},
    {'day': 'Fri', 'nitrogen': 24, 'phosphorus': 42, 'potassium': 19},
    {'day': 'Sat', 'nitrogen': 30, 'phosphorus': 50, 'potassium': 25},
    {'day': 'Sun', 'nitrogen': 26, 'phosphorus': 48, 'potassium': 21},
  ];

  @override
  void dispose() {
    super.dispose();
  }

  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color(0xFF39D2C0);
  Color get _tertiaryColor => const Color(0xFFEE8B60);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _secondaryBackground,
        drawer: _buildDrawer(),
        appBar: AppBar(
          backgroundColor: _primaryColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.dehaze, color: Colors.white, size: 24),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Dashboard',
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 24),
              onPressed: () {
                // Navigate to account page
                Navigator.pushNamed(context, '/account');
              },
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildRatioSummaryCard(),
                _buildRouteOverviewCard(),
                _buildMachineReportsCard(),
                _buildWasteConvertedCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      elevation: 16,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: _primaryColor),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 330.7,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/Logo (Img).png',
                            width: 84.6,
                            height: 114.8,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 84.6,
                                height: 114.8,
                                color: Colors.white.withOpacity(0.1),
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        Text(
                          'NutriBin',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDrawerButton('Home', Icons.house, () {
                    Navigator.pushNamed(context, '/dashboard');
                  }),
                  // _buildDrawerButton('Guide', Icons.menu_book, () {
                  //   Navigator.pushNamed(context, '/guide');
                  // }),
                  _buildDrawerButton('Cameras', Icons.camera, () {
                    Navigator.pushNamed(context, '/camera');
                  }),
                  _buildDrawerButton('Fertilizers', Icons.bar_chart, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FertilizerPage(),
                      ),
                    );
                  }),
                  _buildDrawerButton('Machine', Icons.settings, () {
                    Navigator.pushNamed(context, '/machine');
                  }),
                ],
              ),
            ),
            Container(
              width: 330.7,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildDrawerButton(
                    'About Us',
                    Icons.featured_play_list_rounded,
                    () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  _buildDrawerButton('Support', Icons.contacts, () {
                    Navigator.pushNamed(context, '/support');
                  }),
                  _buildDrawerButton('Studies', Icons.library_books, () {
                    Navigator.pushNamed(context, '/studies');
                  }),
                  _buildDrawerButton(
                    'Terms & Service',
                    Icons.content_paste_rounded,
                    () {
                      Navigator.pushNamed(context, '/termsOfService');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.interTight(color: Colors.white, fontSize: 16),
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }

  Widget _buildRatioSummaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 2,
              color: Color(0x33000000),
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ratio Summary',
                      style: GoogleFonts.interTight(
                        color: const Color(0xFF57636C),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overview of NPK Ratio',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF57636C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNPKCircle('Nitrogen', '24%', _secondaryColor),
                  _buildNPKCircle('Phosphorus', '56%', _primaryColor),
                  _buildNPKCircle('Potassium', '20%', _tertiaryColor),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNPKCircle(String label, String percentage, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF57636C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              percentage,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOverviewCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child:
          Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Route Overview',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF57636C),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'An overview of your route.',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF57636C),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Color(0xFF57636C),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Route progress',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF57636C),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tasks to be completed',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF57636C),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(curve: Curves.easeInOut, duration: 300.ms)
              .moveY(
                curve: Curves.easeInOut,
                begin: 20,
                end: 0,
                duration: 300.ms,
              ),
    );
  }

  Widget _buildMachineReportsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child:
          Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Machine Reports',
                            style: GoogleFonts.interTight(
                              color: const Color(0xFF57636C),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Recent reports from the sensors',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF57636C),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          _buildReportItem(
                            'Camera',
                            'Valid Waste Disposed, No Issues Found',
                            'Date:',
                            'Today, 6:20pm',
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE0E3E7),
                          ),
                          _buildReportItem(
                            'Servos',
                            'Lid Servo Calibrated, No Issues Found',
                            'Due:',
                            'Today, 7:34pm',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(curve: Curves.easeInOut, duration: 300.ms)
              .moveY(
                curve: Curves.easeInOut,
                begin: 20,
                end: 0,
                duration: 300.ms,
              ),
    );
  }

  Widget _buildReportItem(
    String title,
    String description,
    String timeLabel,
    String time,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 100,
              alignment: Alignment.center,
              child: Container(
                width: 4,
                height: 76,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF57636C),
                            fontSize: 12,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Color(0xFF57636C),
                          size: 24,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        description,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF57636C),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Text(
                            timeLabel,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF57636C),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF57636C),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteConvertedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child:
          Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                        child: Text(
                          'Waste Converted',
                          style: GoogleFonts.interTight(
                            color: const Color(0xFF57636C),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 0, 16),
                        child: Text(
                          'Overview of NPK Produced this Week',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF57636C),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Nitrogen', _primaryColor),
                            _buildLegendItem('Phosphorus', _secondaryColor),
                            _buildLegendItem('Potassium', _tertiaryColor),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 10,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: const Color(0xFFE0E3E7),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() <
                                                  _weeklyData.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Text(
                                                _weeklyData[value
                                                    .toInt()]['day'],
                                                style: GoogleFonts.inter(
                                                  color: const Color(
                                                    0xFF57636C,
                                                  ),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 10,
                                    reservedSize: 40,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                          return Text(
                                            '${value.toInt()}',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF57636C),
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: const Color(0xFFE0E3E7),
                                ),
                              ),
                              minX: 0,
                              maxX: (_weeklyData.length - 1).toDouble(),
                              minY: 0,
                              maxY: 60,
                              lineBarsData: [
                                // Nitrogen line
                                LineChartBarData(
                                  spots: _weeklyData.asMap().entries.map((
                                    entry,
                                  ) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value['nitrogen'].toDouble(),
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: _primaryColor,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: _primaryColor,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(show: false),
                                ),
                                // Phosphorus line
                                LineChartBarData(
                                  spots: _weeklyData.asMap().entries.map((
                                    entry,
                                  ) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value['phosphorus'].toDouble(),
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: _secondaryColor,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: _secondaryColor,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(show: false),
                                ),
                                // Potassium line
                                LineChartBarData(
                                  spots: _weeklyData.asMap().entries.map((
                                    entry,
                                  ) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      entry.value['potassium'].toDouble(),
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: _tertiaryColor,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: _tertiaryColor,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(curve: Curves.easeInOut, duration: 300.ms)
              .moveY(
                curve: Curves.easeInOut,
                begin: 20,
                end: 0,
                duration: 300.ms,
              ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radio_button_checked_sharp, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF57636C),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
