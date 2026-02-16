import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nutribin_application/services/machine_service.dart';

class RepairStatusPage extends StatefulWidget {
  const RepairStatusPage({super.key});

  static String routeName = 'repair_status';
  static String routePath = '/repair-status';

  @override
  State<RepairStatusPage> createState() => _RepairStatusPageState();
}

class _RepairStatusPageState extends State<RepairStatusPage> {
  bool isLoading = true;
  List<dynamic> repairRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchRepairRequests();
  }

  // Color scheme
  Color get _primaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _secondaryText =>
      Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;
  Color get _shadowColor => _isDarkMode
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.1);

  Future<void> _fetchRepairRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await MachineService.fetchRepairRequests();

      if (response['ok'] == true) {
        setState(() {
          repairRequests = response['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError(response['message'] ?? 'Failed to fetch repair requests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'postponed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryBackground,
      appBar: AppBar(
        title: Text(
          'Repair Status',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _textColor),
            onPressed: _fetchRepairRequests,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : repairRequests.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchRepairRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: repairRequests.length,
                itemBuilder: (context, index) {
                  final request = repairRequests[index];
                  return _buildRepairCard(request);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_circle_outlined,
            size: 80,
            color: _secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No repair requests found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCard(dynamic request) {
    final status = request['repair_status'] ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final date = DateTime.parse(request['date_created']);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    final serialNumber = request['serial_number'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: statusColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings_suggest,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Repair Request',
                        style: GoogleFonts.interTight(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    Icons.qr_code,
                    'Machine Serial',
                    serialNumber,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    Icons.calendar_today,
                    'Date Created',
                    formattedDate,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.interTight(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request['description'] ?? 'No description provided',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: _secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _secondaryText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 12, color: _secondaryText),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
      ],
    );
  }
}
