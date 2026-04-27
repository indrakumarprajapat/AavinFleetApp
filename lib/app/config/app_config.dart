import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientConfig {
  final String name;
  final String app_title;
  final String loginLogo;
  final bool enableReports;
  final bool enablePayments;
  final String baseUrl;
  final String privacyPolicyLink;
  final String termAndCondLink;
  final LatLng centerLocation;

  static const String CLIENT_NAMAKKAL = 'namakkal';
  static const String CLIENT_CBE = 'cbe';
  static const String CLIENT_NILGIRIS = 'nilgiris';
  static const String CLIENT_DEFAULT = CLIENT_CBE;

  const ClientConfig({
    required this.name,
    required this.app_title,
    required this.loginLogo,
    required this.enableReports,
    required this.enablePayments,
    required this.baseUrl,
    required this.privacyPolicyLink,
    required this.termAndCondLink,
    required this.centerLocation
  });
}

/// 🔹 All client definitions live here
const Map<String, ClientConfig> clientConfigs = {
  "namakkal": ClientConfig(
    name:  ClientConfig.CLIENT_NAMAKKAL,
    app_title: "ddProcure.Ai",
    loginLogo: "assets/images/logo_namakkal.svg",
    enableReports: true,
    enablePayments: false,
    // baseUrl: "https://api.aavinnamakkal.in/",
    baseUrl: "http://192.168.29.89:3042/",
      privacyPolicyLink:'https://aavinnamakkal.in/privacy-policy',
    termAndCondLink:'https://aavinnamakkal.in/terms-and-conditions',
    centerLocation: LatLng(11.219321960519105, 78.16802061322994),
  ),
  "cbe": ClientConfig(
    name: ClientConfig.CLIENT_CBE,
    app_title: "Aavin Coimbatore",
    loginLogo: "assets/images/logo_cbe.svg",
    enableReports: true,
    enablePayments: true,
    // baseUrl: "https://api.aavincbe.cwitch.tech/",
    baseUrl: "http://192.168.29.89:3042/",

    privacyPolicyLink:'https://www.aavincoimbatore.com/assets/privacy-policy.html',
      termAndCondLink:'https://www.aavincoimbatore.com/assets/terms-and-conditions.html',
    centerLocation: LatLng(11.0168, 76.9558),
  ),
  "nilgiris": ClientConfig(
    name: ClientConfig.CLIENT_NILGIRIS,
    app_title: "Aavin Nilgiris",
    loginLogo: "assets/images/logo_nilgiris.svg",
    enableReports: false,
    enablePayments: false,
    baseUrl: "https://api.aavinnilgiris.org/",
      privacyPolicyLink:'https://aavinnilgiris.org/privacy-policy',
      termAndCondLink:'https://aavinnilgiris.org/terms-and-conditions',
    centerLocation: LatLng(11.413468370131161, 76.70249731758045),
  ),
};