import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachineWidget extends StatefulWidget {
  const MachineWidget({super.key});

  static String routeName = 'Machine';
  static String routePath = '/machine';

  @override
  State<MachineWidget> createState() => _MachineWidgetState();
}

class _MachineWidgetState extends State<MachineWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color.fromARGB(255, 57, 136, 210);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: AppBar(
            backgroundColor: _primaryColor,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Text(
                              'Modules',
                              style: GoogleFonts.interTight(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
            ),
            elevation: 0,
          ),
        ),
        body: Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: _primaryColor,
              unselectedLabelColor: _secondaryText,
              labelStyle: GoogleFonts.interTight(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.interTight(fontSize: 18),
              indicatorColor: _primaryColor,
              tabs: const [
                Tab(text: 'MCUs'),
                Tab(text: 'Motors'),
                Tab(text: 'Sensors'),
              ],
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // MCUs Tab
                  _buildModuleList([
                    {'name': 'Arduino Q', 'status': 'Module Functioning'},
                    {'name': 'ESP Camera 1', 'status': 'Module Functioning'},
                    {'name': 'ESP Camera 2', 'status': 'Module Functioning'},
                    {'name': 'ESP Servos 1', 'status': 'Module Functioning'},
                    {'name': 'ESP Servos 1', 'status': 'Module Functioning'},
                    {'name': 'ESP Sensors', 'status': 'Module Functioning'},
                  ]),

                  // Motors Tab
                  _buildModuleList([
                    {'name': 'Lid Servo', 'status': 'Module Functioning'},
                    {'name': 'Diverter Servo', 'status': 'Module Functioning'},
                    {'name': 'Grinder Motor', 'status': 'Module Functioning'},
                    {'name': 'Mixer Motor', 'status': 'Module Functioning'},
                    {'name': 'Exhaust Intake', 'status': 'Module Functioning'},
                    {'name': 'Exhauset Output', 'status': 'Module Functioning'},
                  ]),

                  // Sensors Tab
                  _buildModuleList([
                    {'name': 'Gas (Methane)', 'status': 'Module Functioning'},
                    {'name': 'Gas (Nitrogen)', 'status': 'Module Functioning'},
                    {'name': 'Humidity', 'status': 'Module Functioning'},
                    {'name': 'Camera 1', 'status': 'Module Functioning'},
                    {'name': 'Camera 2', 'status': 'Module Functioning'},
                    {'name': 'pH Level', 'status': 'Module Functioning'},
                    {'name': 'NPK', 'status': 'Module Functioning'},
                    {'name': 'Reed Sensor', 'status': 'Module Functioning'},
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleList(List<Map<String, String>> modules) {
    return SingleChildScrollView(
      // Add bottom padding for gesture bar
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: modules.map((module) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: _secondaryColor,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Color(0x320E151B),
                    offset: Offset(0.0, 1),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.settings_sharp,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                module['status']!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        // Handle check button press
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
