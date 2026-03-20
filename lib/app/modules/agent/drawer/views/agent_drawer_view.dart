import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../config/app_config.dart';
import '../../../../constants/app_enums.dart';
import '../../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../monthly-statements/views/monthly_statement_view.dart';
import '../../profile/views/agent_profile_view.dart';
import '../../wallet_statements/views/wallet_statements_view.dart';
import '../../earnings/views/earnings_view.dart';

class AgentDrawer extends StatefulWidget {
  final VoidCallback? onClose;
  const AgentDrawer({super.key, this.onClose});

  @override
  State<AgentDrawer> createState() => _AgentDrawerState();
}

class _AgentDrawerState extends State<AgentDrawer> {
  bool isBoothDetailsExpanded = false;
  String? profilePhotoUrl;
  final config = Get.find<ClientConfig>();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    GetStorage().listenKey('profileUpdated', (value) {
      if (mounted) {
        _loadProfileData();
      }
    });

    GetStorage().listenKey('profilePhotoUrl', (value) {
      if (mounted) {
        _loadProfileData();
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  void _loadProfileData() {
    final storage = GetStorage();
    final storedUrl = storage.read('profilePhotoUrl');
    if (mounted) {
      profilePhotoUrl = storedUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final agent = storage.read('agent') ?? {};
    final firstName = agent['name']?.toString() ?? '';
    final mobileNumber = agent['mobileNumber']?.toString() ?? '';
    final storedUrl = storage.read('profilePhotoUrl');
    if (storedUrl != null) {
      profilePhotoUrl = storedUrl;
    }
    
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.grey[700],
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        Expanded(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                    SizedBox(height: 30),
                    _buildProfileCard(firstName, mobileNumber),
                    const SizedBox(height: 20),
                    _buildBoothDetailsHeader(),
                    if (isBoothDetailsExpanded) ...[
                      const SizedBox(height: 12),
                      _buildBoothDetailsCard(),
                    ],
                    const SizedBox(height: 24),
                    _buildSectionTitle(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha:0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: Colors.grey[700],
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String firstName, String mobileNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withValues(alpha:0.9),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  firstName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mobileNumber,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withValues(alpha:0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.of(context).pop();
              final result = await Get.to(() => AgentProfileView());
              if (result == true || result == null) {
                _loadProfileData();
              }
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF05967B).withValues(alpha:0.1),
                  backgroundImage: profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty 
                      ? NetworkImage(profilePhotoUrl!) : null,
                  child: profilePhotoUrl == null || profilePhotoUrl!.isEmpty ? Icon(
                    Icons.person,
                    size: 35,
                    color: Color(0xFF05967B),
                  ) : null,
                ),
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: Container(
              //     width: 24,
              //     height: 24,
              //     decoration: BoxDecoration(
              //       color: Color(0xFF05967B),
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.white, width: 2),
              //     ),
              //     child: Icon(
              //       Icons.camera_alt,
              //       size: 12,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoothDetailsHeader() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isBoothDetailsExpanded = !isBoothDetailsExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF).withValues(alpha:0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00ABD5).withValues(alpha:0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF05967B).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.store_outlined,
                color: Color(0xFF05967B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Society Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Icon(
              isBoothDetailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoothDetailsCard() {
    final homeController = Get.find<HomeController>();
    final boothName = homeController.boothDetails?.societyName?.toString() ?? 'N/A';
    final boothCode = homeController.boothDetails?.societyCode?.toString() ?? 'N/A';
    final address = homeController.boothDetails?.address?.toString() ?? 'N/A';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Society Name',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                boothName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Username',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                boothCode,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Address',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'Quick Actions',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildQuickActions() {
    final homeController = Get.find<HomeController>();
    final isLocationSubmitted = true ;//homeController.boothDetails?.isLocSubmit == true;
    
    return Column(
      children: [
        if (isLocationSubmitted) ...[
          // _buildActionItem(
          //   isSvg: 1,
          //   svgUrl: 'assets/icons/order.svg',
          //   iconColor: Color(0xFF05967B),
          //   title: 'Orders',
          //   subtitle: 'View all orders',
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Get.toNamed('/order');
          //   },
          // ),
          // if (config.name == ClientConfig.CLIENT_NAMAKKAL || config.name == ClientConfig.CLIENT_NILGIRIS) const SizedBox(height: 12),
          // if (config.name == ClientConfig.CLIENT_NAMAKKAL || config.name == ClientConfig.CLIENT_NILGIRIS) _buildActionItem(
          //   icon: Icons.currency_rupee,
          //   iconColor: Color(0xFF00ADD9),
          //   title: 'Monthly Statement',
          //   subtitle: 'Monthly Statement',
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Get.to(() => MonthlyStatementView());
          //   },
          //   isSvg: 0,
          // ),
          // if (config.name == ClientConfig.CLIENT_CBE) const SizedBox(height: 12),
          // if (config.name == ClientConfig.CLIENT_CBE) _buildActionItem(
          //   icon: Icons.my_library_books_rounded,
          //   iconColor: Color(0xFF00ADD9),
          //   title: 'Statements',
          //   subtitle: 'Financial statements',
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Get.to(() => WalletStatementsView());
          //   },
          //   isSvg: 0,
          // ),
          // if (config.name == ClientConfig.CLIENT_CBE || config.name == ClientConfig.CLIENT_NAMAKKAL) const SizedBox(height: 12),
          // if (config.name == ClientConfig.CLIENT_CBE || config.name == ClientConfig.CLIENT_NAMAKKAL) _buildActionItem(
          //   icon: Icons.receipt_long,
          //   iconColor: Color(0xFFFF6B35),
          //   title: 'Claims',
          //   subtitle: 'View all claims',
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Get.toNamed('/claims');
          //   },
          //   isSvg: 0,
          // ),
          // if (config.name == ClientConfig.CLIENT_CBE) const SizedBox(height: 12),
          // if (config.name == ClientConfig.CLIENT_CBE) _buildActionItem(
          //   icon: Icons.currency_rupee,
          //   iconColor: Color(0xFF00ADD9),
          //   title: 'Earning',
          //   subtitle: 'Commission stateme...',
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Get.to(() => EarningsView());
          //   },
          //   isSvg: 0,
          // ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.water_drop,
            iconColor: Color(0xFF2196F3),
            title: 'Milk Supplies',
            subtitle: 'View milk supplies',
            onTap: () {
              Navigator.of(context).pop();
              Get.toNamed('/milk-supplies');
            },
            isSvg: 0,
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            isSvg: 0,
            icon: Icons.logout_outlined,
            iconColor: Color(0xFFE74C3C),
            title: 'Log Out',
            subtitle: 'Account logout',
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionItem({
    IconData? icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required num isSvg,
    String? svgUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF).withValues(alpha:0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00ABD5).withValues(alpha:0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isSvg == 1
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        svgUrl!,
                        color: iconColor,
                      ),
                    )
                  : Icon(
                      icon,
                      color: iconColor,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final storage = GetStorage();
              await storage.erase();
              Get.deleteAll();
              if(config.name == ClientConfig.CLIENT_CBE){
                Get.offAllNamed(Routes.USER_TYPE);
              }else{
                Get.offAllNamed(Routes.LOGIN, arguments: UserType.society);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}