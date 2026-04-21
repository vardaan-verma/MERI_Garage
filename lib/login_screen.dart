import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  String _selectedGarageType = '4 Wheelers'; // Can be '4 Wheelers' or '2 Wheelers'
  bool _isLogin = true; // true for Login, false for Register
  String _selectedCountry = 'India'; // Default selected country
  bool _isStaffMember = false;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _garageNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Brand Colors
  final Color primaryRed = const Color(0xFFE03C31);
  final Color secondaryBlue = const Color(0xFF0059A9);
  final Color surfaceColor = const Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Pre-populating demo credentials for ease of testing
    _mobileController.text = '9643105456';
    _passwordController.text = '9643105456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _garageNameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        // Navigate to the Main Dashboard upon login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        print("Registering new $_selectedGarageType Garage...");
        print("Garage Name: ${_garageNameController.text}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Initiated...')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Lowered Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.15, // Lower opacity as requested
              child: Image.asset(
                'assets/images/backgroundsplashscreen.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: Hero(
                            tag: 'logo',
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 100,
                              errorBuilder: (context, error, stackTrace) => 
                                  Icon(Icons.garage, size: 80, color: primaryRed),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Welcome Text
                        Text(
                          _isLogin ? "Welcome Back" : "Create Account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: secondaryBlue,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin 
                            ? "Sign in to manage your workshop"
                            : "Register your garage in minutes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),

                    // Login / Register Mode Toggle
                    _buildModeToggle(),
                    const SizedBox(height: 16),

                    // Country Selection Toggle
                    _buildCountryToggle(),
                    const SizedBox(height: 24),

                    // Garage Type Toggle (4 Wheelers vs 2 Wheelers)
                    _buildSlidingToggle(
                      options: _selectedCountry == 'India' ? ['4 Wheelers', '2 Wheelers'] : ['4 Wheelers'],
                      selectedOption: _selectedGarageType,
                      onChanged: (val) => setState(() => _selectedGarageType = val),
                    ),
                    const SizedBox(height: 24),

                    // Form Fields
                    if (!_isLogin) ...[
                      _buildTextField(
                        controller: _garageNameController,
                        label: 'Garage Name',
                        icon: Icons.store,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile No.',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    if (!_isLogin) ...[
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildPasswordField(),
                    
                    if (_isLogin) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: !_isStaffMember,
                            activeColor: primaryRed,
                            onChanged: (val) {
                              if (val == true) setState(() => _isStaffMember = false);
                            },
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isStaffMember = false),
                            child: Text(
                              'Owner',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: _isStaffMember,
                            activeColor: primaryRed,
                            onChanged: (val) {
                              if (val == true) setState(() => _isStaffMember = true);
                            },
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isStaffMember = true),
                            child: Text(
                              'Staff Member',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Forgot Password?', 
                            style: TextStyle(color: secondaryBlue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ] else
                      const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: surfaceColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryRed.withOpacity(0.4),
                      ),
                      child: Text(
                        _isLogin ? 'LOGIN' : 'REGISTER',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 OTODIGITAL TECHNOLOGIES PVT LTD. All rights reserved.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  ),
],
),
);
  }

  Widget _buildModeToggle() {
    return _buildSlidingToggle(
      options: ['Login', 'Register'],
      selectedOption: _isLogin ? 'Login' : 'Register',
      onChanged: (val) => setState(() => _isLogin = val == 'Login'),
    );
  }

  Widget _buildCountryToggle() {
    return _buildSlidingToggle(
      options: ['🇮🇳 IND', '🇦🇪 UAE', '🇸🇩 SDN', '🇪🇬 EGY', '🇶🇦 QAT'],
      selectedOption: _selectedCountry == 'India' ? '🇮🇳 IND' 
                      : _selectedCountry == 'UAE' ? '🇦🇪 UAE'
                      : _selectedCountry == 'Sudan' ? '🇸🇩 SDN'
                      : _selectedCountry == 'Egypt' ? '🇪🇬 EGY'
                      : '🇶🇦 QAT',
      onChanged: (val) {
        setState(() {
          if (val == '🇮🇳 IND') _selectedCountry = 'India';
          else if (val == '🇦🇪 UAE') _selectedCountry = 'UAE';
          else if (val == '🇸🇩 SDN') _selectedCountry = 'Sudan';
          else if (val == '🇪🇬 EGY') _selectedCountry = 'Egypt';
          else if (val == '🇶🇦 QAT') _selectedCountry = 'Qatar';
          
          if (_selectedCountry != 'India') {
            _selectedGarageType = '4 Wheelers';
          }
        });
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline, color: secondaryBlue),
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryBlue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: secondaryBlue),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryBlue, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildSlidingToggle({
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onChanged,
  }) {
    int selectedIndex = options.indexOf(selectedOption);
    if (selectedIndex == -1) selectedIndex = 0;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / (options.length > 0 ? options.length : 1);
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: selectedIndex * itemWidth,
                width: itemWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
              Row(
                children: options.map((option) {
                  bool isSelected = selectedOption == option;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(option),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? primaryRed : Colors.grey.shade500,
                          ),
                          child: Text(option, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
