import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  // Color scheme
  Color get _primaryColor => Theme.of(context).primaryColor;
  Color get _secondaryColor => const Color.fromARGB(255, 23, 98, 168);
  Color get _secondaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => const Color(0xFF57636C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryBackground,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('About Us'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/FarmImg.png',
                  width: MediaQuery.of(context).size.width,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Title and Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NutriBin: Excess Food Composting and Fertilizer Monitoring System',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: _secondaryText),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NutriBin is an intelligent IoT ecosystem that bridges the gap between household waste and sustainable agriculture. It transforms the way we handle organic scraps by combining high-performance mechanical processing with real-time data analytics.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: _secondaryText),
                  ),
                  const Divider(height: 32, thickness: 1),
                  const SizedBox(height: 8),
                  Text(
                    'Developers',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: _secondaryText),
                  ),
                ],
              ),
            ),

            // Developers List
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildDeveloperAvatar('Clarence'),
                    _buildDeveloperAvatar('Jan Ivan'),
                    _buildDeveloperAvatar('Matthew'),
                    _buildDeveloperAvatar('Luke'),
                    _buildDeveloperAvatar('Ace'),
                  ],
                ),
              ),
            ),

            // Feature Cards
            _buildFeatureCard(
              Icons.thermostat_sharp,
              'Automated Thermal Processing',
              'Rapidly converts food scraps into stable fertilizer using a controlled cycle of mechanical mixing and optimized heating',
            ),
            _buildFeatureCard(
              Icons.autorenew_outlined,
              'Smart NPK Nutrient Profiling',
              'Integrated sensors analyze Nitrogen, Phosphorus, and Potassium levels, providing a digital "Nutrient Report Card" for every batch',
            ),
            _buildFeatureCard(
              Icons.monitor_heart,
              'Real-time Hardware Monitoring',
              'Live tracking of machine health, including internal moisture and temperature, via the ESP32-powered web dashboard',
            ),

            // Process Steps
            Container(
              width: double.infinity,
              color: _secondaryBackground,
              child: Column(
                children: [
                  _buildProcessStep(
                    Icons.input,
                    'Input',
                    'Input Soft biodegradable food scraps',
                    _primaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildProcessStep(
                    Icons.compress,
                    'Process',
                    'Process a three-stage cycle of mixing, drying, and chemical sensor analysis.',
                    _secondaryColor,
                  ),
                  const SizedBox(height: 8),
                  _buildProcessStep(
                    Icons.output,
                    'Output',
                    'Fertilizer + Report',
                    const Color(0xFF39D2C0),
                  ),
                ],
              ),
            ),

            // Call to Action
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 64),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _secondaryBackground,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x33000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      'Ready to turn your waste into life?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account today to connect your hardware, monitor your batches, and join a community dedicated to science-backed sustainability',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _secondaryText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.login_rounded, size: 15),
                          label: const Text('Join Us'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.menu_book, size: 15),
                          label: const Text('System Guide'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDeveloperAvatar(String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _primaryColor, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                'https://images.unsplash.com/photo-1614436163996-25cee5f54290?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1484&q=80',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: _secondaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0x33000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: _primaryColor, size: 72),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: _secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x33000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
