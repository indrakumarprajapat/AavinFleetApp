import 'package:aavin/app/constants/app_enums.dart';

import 'agent_model.dart';
import 'booth_model.dart';
import '../models/customer_model.dart';

class LoginResponseModel {
  final String? token;
  final String? message;
  final bool success;
  final FleetUser? fleetUser;
  // final Society? boothDetails;
  // final Customer? customer;
  final int userType;

  LoginResponseModel({
    this.token,
    this.message,
    this.success = false,
    this.fleetUser,
    // this.boothDetails,
    // this.customer,
    this.userType = 3,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {

    // Handle nested societyUser structure from backend
    Map<String, dynamic>? fUser;
    if (json['fleetUser'] != null) {
      if (json['fleetUser'] is Map && json['fleetUser']['fleetUser'] != null) {
        fUser = json['fleetUser']['fleetUser'] as Map<String, dynamic>;
      } else if (json['fleetUser'] is Map) {
        fUser = json['fleetUser'] as Map<String, dynamic>;
      }
    }

    return LoginResponseModel(
      token: json['token']?.toString(),
      message: json['message']?.toString(),
      success: json['success'] ?? false,
      userType: UserType.fleetUser.index,
      fleetUser: fUser != null
        ? FleetUser.fromJson(fUser)
        : null,
     );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'message': message,
      'success': success,
      'userType': userType,
      'fleetUser': fleetUser?.toJson(),
      // 'boothDetails': boothDetails?.toJson(),
      // 'customer': customer?.toJson(),
    };
  }
}