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
  final int? agentId;
  final int? customerId;
  final String? accessToken;

  ApiResponseModel({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
    this.agentId,
    this.customerId,
    this.accessToken,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      agentId: json['agentId'],
      customerId: json['customerId'],
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
  final SocietyUser? agent;
  final Society? boothDetails;
  final Customer? customer;
  final int userType;

  LoginResponseModel({
    this.token,
    this.message,
    this.success = false,
    this.agent,
    this.boothDetails,
    this.customer,
    this.userType = 3,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userType = json['customer']?['userType'] ?? json['societyUser']?['userType'] ?? json['user']?['userType'] ?? UserType.society.index;
    
    // Handle nested societyUser structure from backend
    Map<String, dynamic>? societyUserData;
    if (json['societyUser'] != null) {
      if (json['societyUser'] is Map && json['societyUser']['societyUser'] != null) {
        societyUserData = json['societyUser']['societyUser'] as Map<String, dynamic>;
      } else if (json['societyUser'] is Map) {
        societyUserData = json['societyUser'] as Map<String, dynamic>;
      }
    } else if (json['user'] != null && json['user']['societyUser'] != null) {
      societyUserData = json['user']['societyUser'] as Map<String, dynamic>;
    }
    
    return LoginResponseModel(
      token: json['token']?.toString(),
      message: json['message']?.toString(),
      success: json['success'] ?? false,
      userType: userType,
      agent: societyUserData != null
        ? SocietyUser.fromJson(societyUserData)
        : null,
      boothDetails: json['societyDetails'] != null
        ? Society.fromJson(json['societyDetails'] as Map<String, dynamic>)
        : null,
      customer: userType == 1 && json['customer'] != null 
        ? Customer.fromJson(json['customer'] as Map<String, dynamic>) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'message': message,
      'success': success,
      'userType': userType,
      'agent': agent?.toJson(),
      'boothDetails': boothDetails?.toJson(),
      'customer': customer?.toJson(),
    };
  }
}