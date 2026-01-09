import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color(0xFF39D2C0);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: _primaryColor,
        appBar: AppBar(
          backgroundColor: _secondaryBackground,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: _secondaryText,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _secondaryText,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 140,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/a/ACg8ocJyqilZ9WOdY_Bc-ZhiSRYpODRSFvJWJOLqisDExh1oIS-xVBBl=s288-c-no',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User Name
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                child: Text(
                  'Matthew Cania',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              // User Email
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'matthew24@gmail.com',
                  style: GoogleFonts.interTight(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),

              // Settings Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    color: _secondaryBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 3,
                        color: Color(0x33000000),
                        offset: Offset(0, -1),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 3),

                              // Settings Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Profile Information',
                                  style: GoogleFonts.interTight(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: _secondaryText,
                                  ),
                                ),
                              ),

                              // First Name
                              _buildProfileRow(
                                icon: Icons.person,
                                label: 'First Name',
                                value: 'Matthew',
                              ),

                              // Last Name
                              _buildProfileRow(
                                icon: Icons.person,
                                label: 'Last Name',
                                value: 'Cania',
                              ),

                              // Birthday
                              _buildProfileRow(
                                icon: Icons.calendar_month,
                                label: 'Birthday',
                                value: '07-24-2005',
                              ),

                              // Age
                              _buildProfileRow(
                                icon: Icons.calendar_today,
                                label: 'Age',
                                value: '20',
                              ),

                              // Phone Number
                              _buildProfileRow(
                                icon: Icons.work_outline,
                                label: 'Phone Number',
                                value: '+639*******52',
                              ),

                              // Email
                              _buildProfileRow(
                                icon: Icons.mail,
                                label: 'Email',
                                value: 'matthew24@gmail.com',
                              ),

                              // Change Password
                              _buildProfileRow(
                                icon: Icons.lock,
                                label: 'Change Password',
                                value: '**************',
                              ),

                              // Edit Profile
                              _buildProfileRow(
                                icon: Icons.edit,
                                label: 'Edit Profile',
                                value: null,
                                bottomPadding: 64,
                                routeName: '/account-edit',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String label,
    String? value,
    double bottomPadding = 8,
    String? routeName,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: InkWell(
        onTap: () {
          if (routeName != null) {
            Navigator.pushNamed(context, routeName);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
              child: Icon(icon, color: _secondaryText, size: 24),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.inter(fontSize: 14, color: _secondaryText),
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: _primaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
