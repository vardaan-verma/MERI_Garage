import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_theme.dart';
import 'webview_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static const String _baseUrl = 'https://www.merigarage.com/software';

  Future<void> _openWebPage(String title, String url) async {
    if (kIsWeb) {
      // On web (Chrome), open in a new browser tab
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $title'),
              backgroundColor: AppTheme.primaryRed,
            ),
          );
        }
      }
    } else {
      // On Android / iOS — use native in-app WebView
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewScreen(title: title, url: url),
        ),
      );
    }
  }

  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.secondaryBlue.withAlpha(20),
              child: const Icon(Icons.person, color: AppTheme.secondaryBlue),
            ),
            const SizedBox(width: 12),
            Text('Account details', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Express Garage', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('express@merigarage.com', style: GoogleFonts.inter(color: Colors.black54)),
            const Divider(height: 32),
            Row(
              children: [
                Text('Role: ', style: GoogleFonts.inter(color: Colors.black54)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'OWNER',
                    style: GoogleFonts.inter(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(color: AppTheme.secondaryBlue, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Meri',
                style: TextStyle(
                  color: AppTheme.primaryRed,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: 'Garage',
                style: TextStyle(color: AppTheme.secondaryBlue),
              ),
            ],
          ),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _showAccountDialog,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE2E8F0),
                child: Icon(Icons.person, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildOverviewTab(),
          _buildManagementTab(),
          _buildCustomerVehicleTab(),
          _buildReportsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomSlider(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showJobOptions,
        backgroundColor: AppTheme.secondaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildManagementTab() {
    return Container(
      color: Colors.transparent, // Uses scaffold background
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildSectionHeader('MANAGEMENT'),
          _buildExpandableSection(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Expense',
            initiallyExpanded: true,
            children: [
              _buildMenuAction('Add Expenses', Icons.add_circle_outline_rounded, url: '$_baseUrl/expense/add'),
              _buildNestedExpandable(
                title: 'View Expenses',
                children: [
                  _buildMenuAction('All Expenses', Icons.radio_button_checked_rounded, isNested: true, url: '$_baseUrl/expense/view'),
                  _buildMenuAction('Spare Expenses', Icons.radio_button_checked_rounded, isNested: true, url: '$_baseUrl/expense/spare'),
                  _buildMenuAction('Salary Expenses', Icons.radio_button_checked_rounded, isNested: true, url: '$_baseUrl/expense/salary'),
                  _buildMenuAction('Sublet Expenses', Icons.radio_button_checked_rounded, isNested: true, url: '$_baseUrl/expense/sublet'),
                  _buildMenuAction('Utility Expenses', Icons.radio_button_checked_rounded, isNested: true, url: '$_baseUrl/expense/utility'),
                  _buildMenuAction('Miscellaneous Expenses', Icons.radio_button_checked_rounded, isNested: true, url: '$_baseUrl/expense/miscellaneous'),
                ],
              ),
            ],
          ),
          _buildMenuItem(Icons.assessment_rounded, 'Paid Revenue', url: '$_baseUrl/revenue'),
          _buildMenuItem(Icons.receipt_long_rounded, 'Amount receivables', url: '$_baseUrl/receivable'),
          _buildMenuItem(Icons.inventory_2_rounded, 'Inventory', url: '$_baseUrl/inventory'),
          _buildMenuItem(Icons.person_add_alt_1_rounded, 'Add Mechanics', url: '$_baseUrl/mechanics/add'),
          _buildMenuItem(Icons.home_repair_service_rounded, 'Service Package', url: '$_baseUrl/service-package'),
          _buildExpandableSection(
            icon: Icons.local_shipping_rounded,
            title: 'Vendor',
            initiallyExpanded: true,
            children: [
              _buildMenuAction('Add Vendor', Icons.add_circle_outline_rounded, url: '$_baseUrl/vendor/add'),
              _buildMenuAction('View Vendor', Icons.visibility_outlined, url: '$_baseUrl/vendor/view'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerVehicleTab() {
    return Container(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildSectionHeader('CUSTOMER & VEHICLES'),
          _buildMenuItem(Icons.people_alt_rounded, 'All Customers', url: '$_baseUrl/customer'),
          _buildMenuItem(Icons.directions_car_rounded, 'All Vehicles', url: '$_baseUrl/vehicle'),
          _buildExpandableSection(
            icon: Icons.notifications_rounded,
            title: 'Reminders',
            initiallyExpanded: true,
            children: [
              _buildMenuAction('Service Reminders', Icons.alarm_on_rounded, url: '$_baseUrl/reminder/service'),
              _buildMenuAction('Insurance Reminders', Icons.verified_user_rounded, url: '$_baseUrl/reminder/insurance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Container(
      color: Colors.transparent,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildSectionHeader('REPORTS'),
          const SizedBox(height: 8),
          _buildMenuItem(Icons.analytics_outlined, 'Revenue Report', url: '$_baseUrl/report/revenue'),
          _buildMenuItem(Icons.payments_outlined, 'Expense Report', url: '$_baseUrl/report/expense'),
          _buildMenuItem(Icons.people_outline, 'Tax Report', url: '$_baseUrl/report/tax'),
          _buildMenuItem(Icons.account_balance_wallet_outlined, 'Complete Loss and Profit Report', url: '$_baseUrl/report/profit-loss'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.black45,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(icon, color: AppTheme.secondaryBlue, size: 26),
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          collapsedIconColor: Colors.black45,
          iconColor: AppTheme.primaryRed,
          children: children,
        ),
      ),
    );
  }

  Widget _buildNestedExpandable({required String title, required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Row(
            children: [
              const Icon(Icons.arrow_right_rounded, color: AppTheme.secondaryBlue, size: 28),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.black45, size: 22),
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? url}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.secondaryBlue, size: 26),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
        onTap: url != null ? () => _openWebPage(title, url) : null,
      ),
    );
  }

  Widget _buildMenuAction(String title, IconData icon, {bool isNested = false, String? url}) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: isNested ? 72.0 : 56.0),
      leading: Icon(icon, color: isNested ? AppTheme.primaryRed : Colors.black45, size: isNested ? 20 : 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: url != null ? () => _openWebPage(title, url) : null,
    );
  }

  void _showJobOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Job Actions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _buildJobOption(
                icon: Icons.add_circle_outline,
                title: 'Make a New Job',
                subtitle: 'Create a new job card for a customer',
                onTap: () {
                  Navigator.pop(context);
                  _openWebPage('New Job Card', '$_baseUrl/jobcard/add');
                },
              ),
              const SizedBox(height: 16),
              _buildJobOption(
                icon: Icons.history,
                title: 'View Previous Jobs',
                subtitle: 'Check history of all job cards',
                onTap: () {
                  Navigator.pop(context);
                  _openWebPage('Previous Jobs', '$_baseUrl/jobcard/view');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJobOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBlue.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.secondaryBlue),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top Row: Total Customers and Inventory
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'TOTAL CUSTOMERS',
                  value: '157',
                  subValue: '+12%',
                  isSubValueBadge: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'INVENTORY STOCKS',
                  value: '99',
                  subValue: 'Low stock alert: 4 items',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Running Jobcards
          _buildWideStatCard(
            title: 'RUNNING JOBCARDS',
            value: '90',
            icon: Icons.people_outline,
          ),
          const SizedBox(height: 16),
          // Completed Jobcards
          _buildHeroCard(
            title: 'COMPLETED JOBCARDS',
            value: '220',
            subtitle: 'this month',
          ),
          const SizedBox(height: 24),
          // Financial Overview
          _buildFinancialOverview(),
          const SizedBox(height: 24),
          // All Expenses Summary
          _buildExpensesSummary(),
          const SizedBox(height: 24),
          // Revenue Analytics
          _buildAnalyticsCard(
            title: 'Revenue Analytics',
            period: 'Nov 2025 – Apr 2026',
            color: AppTheme.secondaryBlue,
          ),
          const SizedBox(height: 24),
          // Expenses Analytics
          _buildAnalyticsCard(
            title: 'Expenses Analytics',
            period: 'Nov 2025 – Apr 2026',
            color: AppTheme.primaryRed,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subValue,
    bool isSubValueBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          isSubValueBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, size: 14, color: AppTheme.secondaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        subValue,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  subValue,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black45,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWideStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryBlue,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.secondaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Overview',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 24),
          _buildRevenueExpenseItem('TOTAL REVENUE', '\$42,900', 0.8, AppTheme.secondaryBlue),
          const SizedBox(height: 20),
          _buildRevenueExpenseItem('TOTAL EXPENSES', '\$18,450', 0.4, AppTheme.primaryRed),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Receivables',
                style: GoogleFonts.inter(color: Colors.black54),
              ),
              Text(
                '\$12,100',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueExpenseItem(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFF1F5F9),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildExpensesSummary() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Expenses Summary',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 35,
                    sections: [
                      PieChartSectionData(
                        color: AppTheme.secondaryBlue,
                        value: 60,
                        title: '100%',
                        radius: 15,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: AppTheme.primaryRed,
                        value: 25,
                        radius: 15,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: Colors.orange,
                        value: 15,
                        radius: 15,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('SPARE PARTS', '60%', AppTheme.secondaryBlue),
                    const SizedBox(height: 8),
                    _buildLegendItem('SALARY', '25%', AppTheme.primaryRed),
                    const SizedBox(height: 8),
                    _buildLegendItem('UTILITIES', '15%', Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              Text(
                percent,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard({required String title, required String period, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    period,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'FILTER',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 1.5),
                      FlSpot(2, 1.2),
                      FlSpot(3, 1),
                      FlSpot(4, 2),
                      FlSpot(5, 1.8),
                    ],
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['NOV', 'DEC', 'JAN', 'FEB', 'MAR', 'APR'].map((m) {
              return Text(
                m,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSlider() {
    final options = ['HOME', 'MANAGEMENT', 'CUSTOMERS', 'REPORTS', 'SETTINGS'];
    
    return Container(
      height: 95,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(35),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / options.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  left: _currentIndex * itemWidth,
                  width: itemWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withAlpha(30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: List.generate(options.length, (index) {
                    bool isSelected = _currentIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentIndex = index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconForIndex(index),
                              size: 24,
                              color: isSelected ? AppTheme.primaryRed : Colors.grey[400],
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                options[index],
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppTheme.primaryRed : Colors.grey[600],
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Container(
      color: Colors.transparent, // Consistent with homepage
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // Account & Garage Details Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: AppTheme.primaryRed.withAlpha(20),
                      child: const Icon(Icons.person, color: AppTheme.primaryRed, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Express Garage',
                            style: GoogleFonts.inter(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'OWNER ACCOUNT',
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: GoogleFonts.inter(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Divider(color: Colors.black12, height: 1),
                ),
                _buildInfoRow(Icons.email_rounded, 'express@merigarage.com'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on_rounded, 'New Delhi, India'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          _buildSectionHeader('STAFF SETTINGS'),
          _buildMenuItem(Icons.groups_rounded, 'User Management', url: '$_baseUrl/user-management'),
          
          const SizedBox(height: 16),
          _buildSectionHeader('SETTINGS'),
          _buildMenuItem(Icons.garage_rounded, 'Garage Profile', url: '$_baseUrl/garage-profile'),
          _buildMenuItem(Icons.lock_reset_rounded, 'Garage Password', url: '$_baseUrl/change-password'),
          
          const SizedBox(height: 48),
          
          _buildSectionHeader('HELP & SUPPORT'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _openWebPage('Get Support', '$_baseUrl/support'),
              icon: const Icon(Icons.support_agent_rounded, size: 24),
              label: Text('Get Support', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFF007BFF).withAlpha(100),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.primaryRed, size: 24),
              label: Text(
                'LOG OUT ACCOUNT',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: AppTheme.primaryRed.withAlpha(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 100), // Extra space for FAB
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.secondaryBlue.withAlpha(100), size: 20),
        const SizedBox(width: 12),
        Text(
          value,
          style: GoogleFonts.inter(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.home_rounded;
      case 1: return Icons.business_center_rounded;
      case 2: return Icons.groups_rounded;
      case 3: return Icons.description_rounded;
      case 4: return Icons.settings_rounded;
      default: return Icons.home_rounded;
    }
  }
}

