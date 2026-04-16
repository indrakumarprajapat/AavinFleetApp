// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// import '../../../../constants/app_enums.dart';
// import '../../../../models/DeviceInfo.dart';
// import '../../../../models/agent_model.dart';
// import '../../../../models/booth_model.dart';
// import '../../../../models/slot_model.dart';
// import '../../../../api/api_service.dart';
// import '../../../../services/global_cart_service.dart';
// import '../../../../utils/device-util.dart';
// import '../../../agent/claims/controllers/claims_controller.dart';
//
// class HomeController extends GetxController {
//   final _selectedIndex = 0.obs;
//   // final _userType = UserType.customer.obs;
//   final apiService = Get.find<ApiService>();
//   final globalCartService = Get.find<GlobalCartService>();
//   final _slots = <SlotModel>[].obs;
//   final _isLoading = false.obs;
//   final _isAadhaarKycVerified = false.obs;
//   final _isPanKycVerified = false.obs;
//   final _boothDetails = Rxn<Society>();
//   final _agent = Rxn<SocietyUser>();
//
//   int get selectedIndex => _selectedIndex.value;
//   // UserType get userType => _userType.value;
//   // bool get isCustomer => _userType.value == UserType.customer;
//   // bool get isDealer => _userType.value == UserType.agent;
//   List<SlotModel> get slots => _slots;
//   bool get isLoading => _isLoading.value;
//   bool get isAadhaarKycVerified => _isAadhaarKycVerified.value;
//   bool get isPanKycVerified => _isPanKycVerified.value;
//   Society? get boothDetails => _boothDetails.value;
//   SocietyUser? get agent => _agent.value;
//   String get agentName => _agent.value?.name ?? '';
//   String get aadhaarNumber => _agent.value?.aadharNumber ?? '';
//   String get panName => _agent.value?.panNumber ?? '';
//   var suppliesDate = ''.obs;
//
//   void changeTabIndex(int index) {
//     _selectedIndex.value = index;
//   }
//
//   // void setUserType(UserType type) {
//   //   _userType.value = type;
//   // }
//
//   void setKycStatus(bool aadhaarVerified, bool panVerified) {
//     _isAadhaarKycVerified.value = aadhaarVerified;
//     _isPanKycVerified.value = panVerified;
//   }
//
//   Future<void> loadAgentSlots() async {
//     try {
//       _isLoading.value = true;
//        final slots = await apiService.getAgentSlots();
//        _slots.value = slots;
//
//        if(slots.isNotEmpty){
//          final slotDateTime = DateTime.parse(slots[0].slotDate ?? '');
//          suppliesDate("${slotDateTime.day}/${slotDateTime.month}/${slotDateTime.year}");
//        }
//
//     } catch (e) {
//       print('Error loading slots: $e');
//     } finally {
//       _isLoading.value = false;
//     }
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     Get.put(ClaimsController());
//     // _checkAutoLogin();
//     loadAgentSlots();
//     loadKycStatus();
//   }
//
//   // Future<void> _checkAutoLogin() async {
//   //   final storage = GetStorage();
//   //   final accessToken = storage.read('access_token');
//   //   final userType = storage.read('user_type') ?? UserType.society.index;
//   //
//   //   if (accessToken != null && userType == UserType.society.index) {
//   //     try {
//   //        var  deviceInfo = DeviceInfo();
//   //       var  version = '';
//   //       try{
//   //         deviceInfo = await DeviceUtil.getDeviceDetails();
//   //         version = await DeviceUtil.getAppVersion();
//   //
//   //       }catch(err){
//   //         print(err);
//   //       }
//   //
//   //       final response = await apiService.agentAutoLogin(accessToken,deviceInfo,version);
//   //
//   //       if (response.agent != null) {
//   //         await storage.write('agent', response.agent?.toJson() ?? {});
//   //         await storage.write('societyDetails', response.boothDetails ?? {});
//   //         print('Agent auto-login successful');
//   //         loadKycStatus();
//   //       }
//   //     } catch (e) {
//   //       print('Agent auto-login failed: $e');
//   //       storage.erase();
//   //       Get.offAllNamed('/login');
//   //     }
//   //   }
//   // }
//
//   void loadKycStatus() {
//       final storage = GetStorage();
//       var agentData = storage.read('agent');
//       var boothData = storage.read('societyDetails');
//
//        if (agentData != null) {
//         try {
//           if (agentData is Map<String, dynamic>) {
//             _agent.value = SocietyUser.fromJson(agentData);
//           } else {
//             _agent.value = SocietyUser.fromJson(Map<String, dynamic>.from(agentData));
//           }
//           _isAadhaarKycVerified.value = _agent.value?.isAadhaarKycVerified ?? false;
//           _isPanKycVerified.value = _agent.value?.isPanKycVerified ?? false;
//         } catch (e) {
//           print('Error parsing agent data: $e');
//           _agent.value = null;
//           _isAadhaarKycVerified.value = false;
//           _isPanKycVerified.value = false;
//         }
//       } else {
//         _agent.value = null;
//         _isAadhaarKycVerified.value = false;
//         _isPanKycVerified.value = false;
//       }
//
//       if (boothData != null) {
//         try {
//           if (boothData is Society) {
//             _boothDetails.value = boothData;
//           } else if (boothData is Map<String, dynamic>) {
//             _boothDetails.value = Society.fromJson(boothData);
//           } else {
//             _boothDetails.value = Society.fromJson(Map<String, dynamic>.from(boothData));
//           }
//         } catch (e) {
//           print('Error parsing booth data: $e');
//           _boothDetails.value = null;
//         }
//       } else {
//         print('Booth data is null');
//         _boothDetails.value = null;
//       }
//   }
// }