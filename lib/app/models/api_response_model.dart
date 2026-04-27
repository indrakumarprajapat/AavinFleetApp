import 'package:aavin/app/constants/app_enums.dart';

import 'agent_model.dart';
import 'booth_model.dart';
import '../models/customer_model.dart';

class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;
   // final int? agentId;
  // final int? customerId;
  final String? accessToken;

  ApiResponseModel({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    // this.agentId,
    // this.customerId,
    this.accessToken,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      accessToken: json['accessToken'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      error: json['error']?.toString(),
      statusCode: json['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
      'statusCode': statusCode,
    };
  }
}

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
    final userType = UserType.fleetUser.index;
    
    // Handle nested societyUser structure from backend
    Map<String, dynamic>? societyUserData;
    if (json['fleetUser'] != null) {
      if (json['fleetUser'] is Map && json['fleetUser']['fleetUser'] != null) {
        societyUserData = json['fleetUser']['fleetUser'] as Map<String, dynamic>;
      } else if (json['fleetUser'] is Map) {
        societyUserData = json['fleetUser'] as Map<String, dynamic>;
      }
    }

    return LoginResponseModel(
      token: json['token']?.toString(),
      message: json['message']?.toString(),
      success: json['success'] ?? false,
      userType: userType,
      fleetUser: societyUserData != null
        ? FleetUser.fromJson(societyUserData)
        : null,
      // boothDetails: json['fleetUser'] != null
      //   ? Society.fromJson(json['fleetUser'] as Map<String, dynamic>)
      //   : null,
      // customer: userType == 1 && json['customer'] != null
      //   ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
      //   : null,
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