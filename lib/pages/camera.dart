import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Sample data model
class CameraData {
  final String id;
  final String date;
  final String time;
  final String description;

  CameraData({
    required this.id,
    required this.date,
    required this.time,
    required this.description,
  });
}

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabController;

  // Sample JSON data
  List<CameraData> cameraData = [
    CameraData(
      id: '1',
      date: '1-2-2025',
      time: '10:11 AM',
      description: 'Valid Trash Detected',
    ),
    CameraData(
      id: '2',
      date: '1-2-2025',
      time: '10:15 AM',
      description: 'Motion Detected',
    ),
    CameraData(
      id: '3',
      date: '1-2-2025',
      time: '10:20 AM',
      description: 'Area Clear',
    ),
    CameraData(
      id: '4',
      date: '1-2-2025',
      time: '10:25 AM',
      description: 'Invalid Object',
    ),
    CameraData(
      id: '5',
      date: '1-2-2025',
      time: '10:30 AM',
      description: 'System Normal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  void dispose() {
    tabController.dispose();
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
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(context),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTabBar(context),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          _buildCameraTab(context, 'Camera Sensor 1'),
                          _buildCameraTab(context, 'Camera Sensor 2'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 123, 0),
        automaticallyImplyLeading: false,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: EdgeInsets.zero,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        // size: 30,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          'Camera',
                          style: GoogleFonts.inter(
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
          // expandedTitleScale: 1.0,
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: Colors.blue[700],
      unselectedLabelColor: Colors.grey[600],
      labelStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      indicatorColor: Colors.blue[700],
      tabs: const [
        Tab(text: 'Camera 1'),
        Tab(text: 'Camera 2'),
      ],
    );
  }

  Widget _buildCameraTab(BuildContext context, String cameraName) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            cameraName,
            style: GoogleFonts.inter(
              color: Colors.grey[700],
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDataTable(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.blue[700]),
          headingRowHeight: 56,
          dataRowHeight: 48,
          columnSpacing: 20,
          columns: [
            DataColumn(
              label: Text(
                'ID',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Date',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Time',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          rows: cameraData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return DataRow(
              color: WidgetStateProperty.all(
                index % 2 == 0 ? Colors.grey[50] : Colors.white,
              ),
              cells: [
                DataCell(
                  Text(
                    data.id,
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                  ),
                ),
                DataCell(
                  Text(
                    data.date,
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                  ),
                ),
                DataCell(
                  Text(
                    data.time,
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(
                  Text(
                    data.description,
                    style: GoogleFonts.inter(color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Main app to run this widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CameraWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(MyApp());
}
