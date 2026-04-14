import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/models/support_ticket.dart';
import 'package:nutribin_application/pages/common/ticket_chat.dart';
import 'package:nutribin_application/services/support_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactWidget extends StatefulWidget {
  const ContactWidget({super.key});

  static String routeName = 'Support';
  static String routePath = '/support';

  @override
  State<ContactWidget> createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  // Support ticket management
  List<SupportTicket> _tickets = [];
  bool _isLoadingTickets = false;
  String? _customerId;
  bool _showTicketForm = false;

  // Form controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCustomerData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimations = List.generate(
      7,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            (0.6 + index * 0.1).clamp(0.0, 1.0),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      7,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                (0.6 + index * 0.1).clamp(0.0, 1.0),
                curve: Curves.easeInOut,
              ),
            ),
          ),
    );

    _animationController.forward();
  }

  Future<void> _loadCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('userId');

    if (customerId != null) {
      setState(() {
        _customerId = customerId;
      });
      await _fetchTickets();
    }
  }

  Future<void> _fetchTickets() async {
    if (_customerId == null) return;

    setState(() {
      _isLoadingTickets = true;
    });

    final result = await SupportService.getTickets(customerId: _customerId!);

    setState(() {
      _isLoadingTickets = false;
      if (result['ok'] == true) {
        _tickets = result['data'] ?? [];
      }
    });
  }

  Future<void> _submitTicket() async {
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_customerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final result = await SupportService.createTicket(
      customerId: _customerId!,
      subject: _subjectController.text,
      description: _descriptionController.text,
      priority: _selectedPriority,
    );

    if (mounted) {
      if (result['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support ticket created successfully')),
        );
        _subjectController.clear();
        _descriptionController.clear();
        setState(() {
          _showTicketForm = false;
          _selectedPriority = 'medium';
        });
        await _fetchTickets();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error creating ticket')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedContainer({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimations[index].value,
          child: Opacity(opacity: _fadeAnimations[index].value, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildTicketForm({
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a New Ticket',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                labelStyle: GoogleFonts.inter(color: subTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.inter(color: textColor),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: GoogleFonts.inter(color: subTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 4,
              style: GoogleFonts.inter(color: textColor),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                labelStyle: GoogleFonts.inter(color: subTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: ['low', 'medium', 'high']
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(
                        priority.toUpperCase(),
                        style: GoogleFonts.inter(color: textColor),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitTicket,
                    child: Text(
                      'Submit Ticket',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showTicketForm = false;
                      });
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTicketsList({
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    return _tickets.map((ticket) {
      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketChatPage(ticket: ticket),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isDarkMode
                      ? Border.all(color: Colors.white.withOpacity(0.05))
                      : Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ticket.subject,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                ticket.priority,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ticket.priority.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getPriorityColor(ticket.priority),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: subTextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                ticket.status,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ticket.status.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(ticket.status),
                              ),
                            ),
                          ),
                          Text(
                            'ID: ${ticket.id.substring(0, 8)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC COLORS ---
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color!;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // --- APP BAR CONFIG ---
    final appBarBg = isDarkMode ? backgroundColor : primaryColor;
    const appBarContentColor = Colors.white;

    // --- ICON HIGHLIGHT ---
    final highlightColor = isDarkMode ? const Color(0xFF8FAE8F) : primaryColor;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: appBarBg,
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 24),
            color: appBarContentColor,
            onPressed: () => Navigator.pop(context),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Contact Us',
              textAlign: TextAlign.center,
              style: GoogleFonts.interTight(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: appBarContentColor,
              ),
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.transparent, height: 1.0),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to support',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'How can we help you?',
                          style: GoogleFonts.interTight(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact Options Row
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildOptionCard(
                            index: 0,
                            icon: Icons.add_circle_outline,
                            label: 'Create Ticket',
                            cardColor: cardColor,
                            iconColor: highlightColor,
                            textColor: textColor,
                            isDarkMode: isDarkMode,
                            onTap: () {
                              setState(() {
                                _showTicketForm = !_showTicketForm;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildOptionCard(
                            index: 1,
                            icon: Icons.email_outlined,
                            label: 'Email Us',
                            cardColor: cardColor,
                            iconColor: highlightColor,
                            textColor: textColor,
                            isDarkMode: isDarkMode,
                            onTap: () => _openFaqs(),
                          ),
                          const SizedBox(width: 12),
                          _buildOptionCard(
                            index: 2,
                            icon: Icons.refresh,
                            label: 'My Tickets',
                            cardColor: cardColor,
                            iconColor: highlightColor,
                            textColor: textColor,
                            isDarkMode: isDarkMode,
                            onTap: _fetchTickets,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Ticket Form Section
                      if (_showTicketForm)
                        _buildTicketForm(
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          isDarkMode: isDarkMode,
                        ),

                      // My Support Tickets Section
                      if (_tickets.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Support Tickets',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._buildTicketsList(
                              cardColor: cardColor,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              isDarkMode: isDarkMode,
                            ),
                          ],
                        ),

                      // Frequently Asked Questions Section
                      if (!_showTicketForm || _tickets.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              'Frequently Asked Questions',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildAnimatedContainer(
                              index: 3,
                              child: _buildFAQCard(
                                question:
                                    'What does the compost bin system do?',
                                answer:
                                    'The compost bin system helps convert organic waste like food scraps and garden waste into nutrient-rich compost, reducing landfill waste and creating a natural fertilizer for plants.',
                                cardColor: cardColor,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAnimatedContainer(
                              index: 4,
                              child: _buildFAQCard(
                                question:
                                    'What types of waste can be placed in the compost bin?',
                                answer:
                                    'You can place fruit and vegetable scraps, coffee grounds, eggshells, garden clippings, and other biodegradable organic materials. Avoid meat, dairy, and oily foods as they can attract pests.',
                                cardColor: cardColor,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAnimatedContainer(
                              index: 5,
                              child: _buildFAQCard(
                                question:
                                    'How does the system monitor the composting process?',
                                answer:
                                    'The system uses sensors to monitor temperature, moisture, and aeration levels to ensure optimal composting conditions, providing notifications if adjustments are needed.',
                                cardColor: cardColor,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildAnimatedContainer(
                              index: 6,
                              child: _buildFAQCard(
                                question:
                                    'Does the compost bin require regular maintenance?',
                                answer:
                                    'Yes, regular maintenance involves adding the right mix of green and brown materials, stirring or turning the compost, and checking sensor readings to maintain proper conditions for decomposition.',
                                cardColor: cardColor,
                                textColor: textColor,
                                subTextColor: subTextColor,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required IconData icon,
    required String label,
    required Color cardColor,
    required Color iconColor,
    required Color textColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: _buildAnimatedContainer(
        index: index,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: isDarkMode
                    ? Border.all(color: Colors.white.withOpacity(0.05))
                    : Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: isDarkMode
                    ? []
                    : [
                        const BoxShadow(
                          blurRadius: 4,
                          color: Color(0x0D000000),
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required String question,
    required String answer,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.05))
            : Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: isDarkMode
            ? []
            : [
                const BoxShadow(
                  blurRadius: 3,
                  color: Color(0x0D000000),
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              answer,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: subTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFaqs() async {
    final Uri url = Uri.parse('https://nutribin.up.railway.app/login');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication, // opens real browser
    )) {
      debugPrint('Could not launch $url');
    }
  }
}
