import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../config/app_config.dart';
import '../../../../config/app_initializer.dart';
import '../../../../models/DeviceInfo.dart';
import '../../../../models/slot_model.dart';
import '../../../../api/api_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../../services/global_cart_service.dart';
import '../../../../utils/device-util.dart';
import '../../../../widgets/claims_content_widget.dart';
import '../../../../widgets/milk_content_widget.dart';
// import '../../../../widgets/others_content_widget.dart';
import '../../../../widgets/wallet_content_widget.dart';
import '../../claims/controllers/claims_controller.dart';
import '../../../../widgets/daily_supplies_form_dialog.dart';
import '../controllers/home_controller.dart';
import '../../drawer/views/agent_drawer_view.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver, TickerProviderStateMixin {
  TabController? _tabController;
  PageController? _pageController;
  final _currentIndex = 0.obs;
  final _verificationStep = 1.obs; // 1: KYC verification, 2: Bank verification
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _isInitialLoading = true.obs;
  final config = Get.find<ClientConfig>();
  final controller = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();

    Future.delayed(Duration(seconds: 1), () {
      _isInitialLoading.value = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args != null && args['tab'] != null) {
        final tabIndex = args['tab'] as int;
        _currentIndex.value = tabIndex;
        _pageController?.animateToPage(tabIndex, duration: Duration(milliseconds: 300), curve: Curves.ease);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        final globalCartService = Get.find<GlobalCartService>();
        globalCartService.refreshCartEstimate();
      } catch (e) {
      }
    }
  }

  void _onPageChanged(int index) {
    _currentIndex.value = index;
    _tabController?.animateTo(index);
  }

  void _onTabTapped(int index) {
    _currentIndex.value = index;
    // _pageController?.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
    // if( config.name == ClientConfig.CLIENT_CBE ||  config.name == ClientConfig.CLIENT_NAMAKKAL){
    //   if(_currentIndex.value == 1){
    //     Get.find<ClaimsController>().loadClaims();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xFFF8F8F8),
        drawer: AgentDrawer(),
        body: Stack(
          children: [
            GestureDetector(
              // onPanUpdate: isLocationSubmitted ? (details) {
              //   if (details.delta.dx < 0) {
              //     Get.toNamed('/cart');
              //   }
              // } : null,
              child: _pageController != null && isLocationSubmitted
                  ? PageView(
                controller: _pageController!,
                onPageChanged: _onPageChanged,
                children: [
                  _buildHomeContent(controller),
                  // if( config.name == ClientConfig.CLIENT_CBE ||  config.name == ClientConfig.CLIENT_NAMAKKAL) _buildClaimsContent(),
                  // _buildOthersContent(),
                  // _buildWalletContent(),
                ],
              )
                  : _buildHomeContent(controller),
            ),
            _buildCustomHeader(isLocationSubmitted,controller.boothDetails?.societyName??'' ,controller.boothDetails?.societyCode??''),
          ],
        ),
        // bottomNavigationBar: isLocationSubmitted ? _buildBottomNav() : SizedBox.shrink(),
      );
    });
  }

  Widget _buildHomeContent(HomeController controller) {
    final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
    final isBankVerified = controller.agent?.hasBankAccountVerified == true;
    final allVerified = controller.isAadhaarKycVerified &&
        controller.isPanKycVerified &&
        isBankVerified &&
        isLocationSubmitted;

    return RefreshIndicator(
      onRefresh: () async {
        await controller.loadAgentSlots();
        try {
          final globalCartService = Get.find<GlobalCartService>();
          await globalCartService.refreshCartEstimate();
        } catch (_) {}
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.32),

            /// Body Container
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6F9),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              child: Obx(() {
                if (controller.isLoading) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF007EA7),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!allVerified) _buildVerificationCard(),

                    if (allVerified) ...[
                      _buildSectionHeader("Submit Supplies"),
                      const SizedBox(height: 20),
                      _buildOrderCardsModern(controller),
                    ],

                    const SizedBox(height: 30),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildOrderCardsModern(HomeController controller) {
    if (controller.slots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No slots available",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: controller.slots.map((slot) {
        final isEvening = slot.shift == 2;

        return _buildModernOrderCard(
          title: slot.shiftName ?? (isEvening ? "Evening" : "Morning"),
          icon: isEvening ? Icons.nightlight_round : Icons.wb_sunny,
          color: isEvening ? const Color(0xFF007EA7) : const Color(0xFFFF8C42),
          slot: slot,
        );
      }).toList(),
    );
  }

  Widget _buildModernOrderCard({
    required String title,
    required IconData icon,
    required Color color,
    required SlotModel slot,
  }) {
    final remainingTime =
    _calculateRemainingTime(slot.createdAt ?? '', slot.cutoffTime ?? '');

    return GestureDetector(
      onTap: () {
        Get.to(() => DailySuppliesFormDialog(
          slotId: slot.id ?? 1,
          shift: slot.shift ?? 1,
          slotDate: slot.slotDate ?? '',
          shiftName: title,
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 26),
            ),

            const SizedBox(width: 16),

            /// Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$title Shift",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Cutoff in $remainingTime",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios_rounded, size: 16)
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Complete your KYC verification to start placing orders.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Obx(()=>
           Text(
             controller.suppliesDate.value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader(
      bool isLocationSubmitted,
      String societyName,
      String regNumber,
      ) {

    String greeting = "Welcome ";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Gradient Backgroundo
        Container(
          height: MediaQuery.of(context).size.height * 0.28,
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00ADD3),
                Color(0xFF007EA7),
                Color(0xFF005F7A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        config.app_title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  isLocationSubmitted
                      ? _buildCartIcon()
                      : CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 30),

              /// Greeting
              Text(
                "$greeting 👋",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),

              SizedBox(height: 6),

              /// Society Name
              Text(
                societyName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 6),

              /// Registration Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Society Code: $regNumber",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }


  Widget _buildCartIcon() {
    return Stack(
      children: [
        Obx(() {
          final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
          return IconButton(
            onPressed: isLocationSubmitted ? () => Get.toNamed('/cart') : null,
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 30,
            ),
          );
        }),
        Obx(() {
          try {
            final cartService = Get.find<GlobalCartService>();
            final totalItems = cartService.itemsCount;
            if (totalItems > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$totalItems',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } catch (e) {
          }
          return SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        currentIndex: _currentIndex.value,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/homeIcon.svg',
              width: 21.21,
              height: 22,
            ),
            label: 'Home',
          ),
          if( config.name == ClientConfig.CLIENT_CBE ||  config.name == ClientConfig.CLIENT_NAMAKKAL) BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/cardMilk.svg',
              width: 13.71,
              height: 19.41,
            ),
            label: 'Claims',
          ),
          // BottomNavigationBarItem(
          //   icon: SvgPicture.asset(
          //     'assets/icons/cardMilk.svg',
          //     width: 13.71,
          //     height: 19.41,
          //   ),
          //   label: 'Card Milk',
          // ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/otherIcon.svg',
              width: 18.39,
              height: 21.67,
            ),
            label: 'Others',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/walletIcon.svg',
              width: 22.44,
              height: 19.17,
            ),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }



  Widget _buildIdProofView() {
    final controller = Get.find<HomeController>();
    final apiService = Get.find<ApiService>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_verificationStep == 1)
          Obx(() => _buildBoothDetailsCard(controller)),
        if (_verificationStep == 1) ...[
          const SizedBox(height: 20),
          Obx(() => _buildCardView("Aadhaar Number", controller.aadhaarNumber, controller.isAadhaarKycVerified)),
          const SizedBox(height: 20),
          Obx(() => _buildCardView("PAN Number", controller.panName, controller.isPanKycVerified)),
        ],
        const SizedBox(height: 30),

        Obx(() {
          final bothVerified = controller.isAadhaarKycVerified && controller.isPanKycVerified;
          final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;

          final isBankVerified = controller.agent?.hasBankAccountVerified == true;
          final allVerified = controller.isAadhaarKycVerified && controller.isPanKycVerified && isBankVerified && isLocationSubmitted;
          final kycVerified = controller.isAadhaarKycVerified && controller.isPanKycVerified;

          if(kycVerified && _verificationStep.value != 2){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _verificationStep.value = 2;
            });
          }
          if (allVerified) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'KYC Completed Successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_verificationStep.value == 2) {
            return _buildBankDetailsVerification(controller);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showUpdateDetailsDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Wrong',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Correct',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBoothDetailsCard(HomeController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${controller.agentName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Society: ${controller.boothDetails?.societyName ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Society Code: ${controller.boothDetails?.societyCode ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            if (controller.boothDetails?.address != null) ...[
              const SizedBox(height: 4),
              Text(
                'Address: ${controller.boothDetails?.address}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardView(String title, String value, bool isVerified) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm KYC Details'),
        content: const Text('Are you sure your Aadhaar and PAN details are correct?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              _verificationStep.value = 2;
              try {
                final apiService = Get.find<ApiService>();
                await apiService.verifyKyc(
                  isAadhaarKycVerified: true,
                  isPanKycVerified: true,
                );
                controller.setKycStatus(true, true);
              } catch (e) {
                Get.snackbar('Error', 'Failed to verify KYC: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDetailsDialog() {
    final nameController = TextEditingController();
    final aadharController = TextEditingController();
    final panController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountHolderController = TextEditingController();
    final ifscController = TextEditingController();
    final bankNameController = TextEditingController();
    final bankBranchController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update your details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aadharController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: panController,
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'PAN Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankBranchController,
                decoration: const InputDecoration(
                  labelText: 'Branch Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ifscController,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final apiService = Get.find<ApiService>();
                await apiService.updateAgentDetails(
                  name: nameController.text.isNotEmpty ? nameController.text : null,
                  aadharNumber: aadharController.text.isNotEmpty ? aadharController.text : null,
                  panNumber: panController.text.isNotEmpty ? panController.text : null,
                  accountNumber: accountNumberController.text.isNotEmpty ? accountNumberController.text : null,
                  accountHolderName: accountHolderController.text.isNotEmpty ? accountHolderController.text : null,
                  ifscCode: ifscController.text.isNotEmpty ? ifscController.text : null,
                  bankName: bankNameController.text.isNotEmpty ? bankNameController.text : null,
                  bankBranch: bankBranchController.text.isNotEmpty ? bankBranchController.text : null,
                  reqType: 1,
                );

                final storage = GetStorage();
                final accessToken = storage.read('access_token');
                var deviceInfo = DeviceInfo();
                var version = '';
                try {
                  deviceInfo = await DeviceUtil.getDeviceDetails();
                  version = await DeviceUtil.getAppVersion();
                } catch (err) {
                  print(err);
                }
                // final autoLoginResponse = await apiService.agentAutoLogin(accessToken, deviceInfo, version);
                final autoLoginResponse = await apiService.agentAutoLogin(accessToken);
                storage.write('agent', autoLoginResponse.agent?.toJson() ?? {});
                storage.write('societyDetails', autoLoginResponse.boothDetails?.toJson() ?? {});

                controller.loadKycStatus();

                Get.snackbar('Success', 'Details updated successfully');
              } catch (e) {
                String errorMessage = e.toString();
                if (errorMessage.contains('message:')) {
                  final messageStart = errorMessage.indexOf('message:') + 8;
                  final messageEnd = errorMessage.indexOf('}', messageStart);
                  if (messageEnd != -1) {
                    errorMessage = errorMessage.substring(messageStart, messageEnd).trim();
                  }
                }
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Error'),
                    content: Text(errorMessage),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsVerification(HomeController controller) {
    return Column(
      children: [
        Obx(() {
          final isBankVerified = controller.agent?.hasBankAccountVerified == true;
          return Column(
            children: [
              _buildCardView("Account Holder", controller.agent?.accountHolderName ?? 'N/A', isBankVerified),
              const SizedBox(height: 20),
              _buildCardView("Account Number", controller.agent?.accountNumber ?? 'N/A', isBankVerified),
              const SizedBox(height: 20),
              _buildCardView("Bank Name", controller.agent?.bankName ?? 'N/A', isBankVerified),
              const SizedBox(height: 20),
              _buildCardView("Branch", controller.agent?.bankBranch ?? 'N/A', isBankVerified),
              const SizedBox(height: 20),
              _buildCardView("IFSC Code", controller.agent?.ifscCode ?? 'N/A', isBankVerified),
            ],
          );
        }),
        const SizedBox(height: 30),
        Obx(() {
          final isBankVerified = controller.agent?.hasBankAccountVerified == true;

          if (isBankVerified) {
            final isLocationSubmitted = controller.boothDetails?.isLocSubmit == true;
            if (!isLocationSubmitted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAllNamed(Routes.BOOTH_CAPTURE);
              });
              return PopScope(
                canPop: false,
                child: SizedBox.shrink(),
              );
            }
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isBankVerified)
                ElevatedButton(
                  onPressed: () {
                    _showUpdateBankDetailsDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Wrong',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              if (!isBankVerified)
                ElevatedButton(
                  onPressed: () {
                    _showBankConfirmationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Correct',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  void _showBankConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Bank Details'),
        content: const Text('Are you sure your bank details are correct?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final apiService = Get.find<ApiService>();
                await apiService.verifyKyc(
                  isAadhaarKycVerified: null,
                  isPanKycVerified: null,
                  hasBankAccountVerified: true,
                );

                final storage = GetStorage();
                final accessToken = storage.read('access_token');

                var  deviceInfo = DeviceInfo();
                var  version = '';
                try{
                  deviceInfo = await DeviceUtil.getDeviceDetails();
                  version = await DeviceUtil.getAppVersion();

                }catch(err){
                  print(err);
                }
                // final autoLoginResponse = await apiService.agentAutoLogin(accessToken,deviceInfo,version);
                final autoLoginResponse = await apiService.agentAutoLogin(accessToken);

                storage.write('agent', autoLoginResponse.agent?.toJson() ?? {});
                storage.write('societyDetails', autoLoginResponse.boothDetails?.toJson() ?? {});

                controller.loadKycStatus();

              } catch (e) {
                Get.snackbar('Error', 'Failed to verify bank details: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showUpdateBankDetailsDialog() {
    final bankNameController = TextEditingController();
    final accountHolderController = TextEditingController();
    final accountNumberController = TextEditingController();
    final ifscController = TextEditingController();
    final branchController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Bank Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: branchController,
                decoration: const InputDecoration(
                  labelText: 'Branch Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ifscController,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                final apiService = Get.find<ApiService>();
                await apiService.updateAgentDetails(
                  accountNumber: accountNumberController.text.isNotEmpty ? accountNumberController.text : null,
                  accountHolderName: accountHolderController.text.isNotEmpty ? accountHolderController.text : null,
                  ifscCode: ifscController.text.isNotEmpty ? ifscController.text : null,
                  bankName: bankNameController.text.isNotEmpty ? bankNameController.text : null,
                  bankBranch: branchController.text.isNotEmpty ? branchController.text : null,
                  reqType: 2,
                );
                Get.snackbar('Success', 'Bank details update request submitted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to submit bank details update: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _calculateRemainingTime(String slotDate, String cutoffTime) {
    try {
      final now = DateTime.now();
      final slotDateTime = DateTime.parse(slotDate);
      final cutoffParts = cutoffTime.split(':');
      final cutoffDateTime = DateTime(
        slotDateTime.year,
        slotDateTime.month,
        slotDateTime.day,
        int.parse(cutoffParts[0]),
        int.parse(cutoffParts[1]),
      );

      final difference = cutoffDateTime.difference(now);

      if (difference.isNegative) {
        return 'Expired';
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m left';
      } else {
        return '${minutes}m left';
      }
    } catch (e) {
      return 'Invalid time';
    }
  }
}
