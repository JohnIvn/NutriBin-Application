import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MachinePage extends StatefulWidget {
  final Function(Machine)? onMachineSelected;

  const MachinePage({super.key, this.onMachineSelected});

  @override
  State<MachinePage> createState() => _MachinePageState();
}

class _MachinePageState extends State<MachinePage> {
  List<Machine> _machines = [];
  bool _isLoading = true;

  Color get _primaryColor => Theme.of(context).colorScheme.primary;
  Color get _tertiaryColor => Theme.of(context).colorScheme.tertiary;
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  Future<void> _loadMachines() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final machinesJson = prefs.getStringList('machines') ?? [];

    setState(() {
      _machines = machinesJson
          .map((json) => Machine.fromJson(jsonDecode(json)))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _saveMachines() async {
    final prefs = await SharedPreferences.getInstance();
    final machinesJson = _machines
        .map((machine) => jsonEncode(machine.toJson()))
        .toList();
    await prefs.setStringList('machines', machinesJson);
  }

  void _showAddMachineDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMachineDialog(
        onAdd: (machine) async {
          setState(() {
            _machines.add(machine);
          });
          await _saveMachines();
        },
      ),
    );
  }

  void _showDeleteConfirmation(Machine machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Machine',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${machine.name}"?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF57636C)),
            ),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _machines.remove(machine);
              });
              await _saveMachines();
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard(Machine machine) {
    if (widget.onMachineSelected != null) {
      widget.onMachineSelected!(machine);
    } else {
      // Fallback behavior if no callback provided
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${machine.name}...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _machines.isEmpty
            ? _buildEmptyState()
            : _buildMachineList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMachineDialog,
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Machine',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restore_from_trash_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Machines Yet',
              style: GoogleFonts.interTight(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF57636C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Register your first NutriBin machine to get started',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF57636C),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddMachineDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add Machine',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'My Machines',
                style: GoogleFonts.interTight(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: _tertiaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _machines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final machine = _machines[index];
                return _buildMachineCard(machine, index);
              },
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildMachineCard(Machine machine, int index) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 3,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToDashboard(machine),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restore_from_trash,
                          size: 32,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              machine.name,
                              style: GoogleFonts.interTight(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              machine.location,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF57636C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF57636C),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteConfirmation(machine);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: GoogleFonts.inter(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE0E3E7)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          icon: Icons.numbers,
                          label: 'ID',
                          value: machine.deviceId,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatusChip(machine.status)),
                    ],
                  ),
                  if (machine.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      machine.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF57636C),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          curve: Curves.easeInOut,
          duration: 300.ms,
          delay: (index * 50).ms,
        )
        .moveY(
          curve: Curves.easeInOut,
          begin: 20,
          end: 0,
          duration: 300.ms,
          delay: (index * 50).ms,
        );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF57636C)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF57636C),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF57636C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(MachineStatus status) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusConfig['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusConfig['icon'], size: 16, color: statusConfig['color']),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF57636C),
                ),
              ),
              Text(
                statusConfig['label'],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusConfig['color'],
                ),
              ),
            ],
          ),
        ],
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
        return {'color': Colors.red, 'icon': Icons.cancel, 'label': 'Offline'};
      case MachineStatus.maintenance:
        return {
          'color': Colors.orange,
          'icon': Icons.build_circle,
          'label': 'Maintenance',
        };
    }
  }
}

// Add Machine Dialog
class AddMachineDialog extends StatefulWidget {
  final Function(Machine) onAdd;

  const AddMachineDialog({super.key, required this.onAdd});

  @override
  State<AddMachineDialog> createState() => _AddMachineDialogState();
}

class _AddMachineDialogState extends State<AddMachineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  MachineStatus _selectedStatus = MachineStatus.online;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _deviceIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final machine = Machine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        location: _locationController.text,
        deviceId: _deviceIdController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        registeredAt: DateTime.now(),
      );

      widget.onAdd(machine);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Register Machine',
                      style: GoogleFonts.interTight(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF57636C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: 'Machine Name',
                  hint: 'e.g., Kitchen NutriBin',
                  icon: Icons.label_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a machine name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'e.g., Building A, Floor 2',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _deviceIdController,
                  label: 'Device ID',
                  hint: 'e.g., NB-001',
                  icon: Icons.tag,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a device ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Additional notes about this machine',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Initial Status',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF57636C),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MachineStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: MachineStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toString().split('.').last.toUpperCase(),
                        style: GoogleFonts.inter(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF57636C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF57636C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF57636C).withOpacity(0.5),
            ),
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }
}

// Machine Model
enum MachineStatus { online, offline, maintenance }

class Machine {
  final String id;
  final String name;
  final String location;
  final String deviceId;
  final String description;
  final MachineStatus status;
  final DateTime registeredAt;

  Machine({
    required this.id,
    required this.name,
    required this.location,
    required this.deviceId,
    required this.description,
    required this.status,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'deviceId': deviceId,
      'description': description,
      'status': status.index,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      deviceId: json['deviceId'],
      description: json['description'],
      status: MachineStatus.values[json['status']],
      registeredAt: DateTime.parse(json['registeredAt']),
    );
  }
}
