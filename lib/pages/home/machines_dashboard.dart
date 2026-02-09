import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/models/machine.dart';

class MachineDashboardPage extends StatefulWidget {
  final Machine machine;

  const MachineDashboardPage({super.key, required this.machine});

  @override
  State<MachineDashboardPage> createState() => _MachineDashboardPageState();
}

class _MachineDashboardPageState extends State<MachineDashboardPage> {
  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset('assets/images/Logo (Img).png', height: 48),
            const SizedBox(width: 8),
            Text(
              'NutriBin',
              textAlign: TextAlign.left,
              style: GoogleFonts.interTight(
                color: _primaryColor,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Machine Header Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.restore_from_trash,
                                size: 40,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.machine.name,
                                    style: GoogleFonts.interTight(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF57636C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Color(0xFF57636C),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.machine.location,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF57636C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(widget.machine.status),
                          ],
                        ),
                        if (widget.machine.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.machine.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF57636C),
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFE0E3E7)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.tag,
                                label: 'Device ID',
                                value: widget.machine.deviceId,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoItem(
                                icon: Icons.calendar_today,
                                label: 'Registered',
                                value: _formatDate(widget.machine.registeredAt),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Grid
                Text(
                  'Statistics',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF57636C),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      icon: Icons.delete_outline,
                      title: 'Total Waste',
                      value: '0 kg',
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.eco,
                      title: 'Compost Ready',
                      value: '0 kg',
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      icon: Icons.trending_up,
                      title: 'This Week',
                      value: '0 kg',
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      icon: Icons.speed,
                      title: 'Efficiency',
                      value: '0%',
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF57636C),
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Add Waste Entry',
                  subtitle: 'Record new waste deposit',
                  onTap: () {
                    // TODO: Navigate to add waste entry
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Waste Entry - Coming Soon')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.history,
                  title: 'View History',
                  subtitle: 'See all waste entries',
                  onTap: () {
                    // TODO: Navigate to history
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View History - Coming Soon')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.settings,
                  title: 'Machine Settings',
                  subtitle: 'Configure machine parameters',
                  onTap: () {
                    // TODO: Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Machine Settings - Coming Soon')),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MachineStatus status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 14, color: config['color']),
          const SizedBox(width: 4),
          Text(
            config['label'],
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF57636C)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF57636C),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF57636C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF57636C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF57636C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: _primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.interTight(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF57636C).withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(MachineStatus status) {
    switch (status) {
      case MachineStatus.online:
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'label': 'Online',
        };
      case MachineStatus.offline:
        return {
          'color': Colors.red,
          'icon': Icons.cancel,
          'label': 'Offline',
        };
      case MachineStatus.maintenance:
        return {
          'color': Colors.orange,
          'icon': Icons.build_circle,
          'label': 'Maintenance',
        };
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}