/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/initial_binding.dart';
import 'app/config/app_initializer.dart';
import 'app/constants/app_colors.dart';
import 'app/routes/app_pages.dart';
import 'app/data/data_service.dart';

void main() async {

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      AppInitializer.init();
    } catch (e, s) {
      debugPrint("Startup error: $e");
      debugPrintStack(stackTrace: s);
    }

    // Global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      print('Flutter Error: ${details.exception}');
      print('Stack Trace: ${details.stack}');
    };

    await GetStorage.init();
    Get.put(GetStorage());
    await Get.putAsync(() => DataService().init());

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    runApp(RestartWidget(child: MyApp()));
  }, (error, stackTrace) {
    print('Unhandled Error: $error');
    print('Stack Trace: $stackTrace');
  });
}

class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AAVIN',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      enableLog: true,
      smartManagement: SmartManagement.full,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        dialogBackgroundColor: Colors.white,
        cardColor: Colors.white,
      ),
    );
  }
}

 */

import 'dart:async';
import 'package:aavin/app/route_assignment(home)/route_assignment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'app/constants/app_colors.dart';
import 'app/data/data_service.dart';
import 'app/config/app_initializer.dart';

import 'app/config/app_config.dart';
import 'package:aavin/app/route_assignment(home)/route_assignment_screen.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize GetStorage
    await GetStorage.init();
    Get.put(GetStorage());

    // Initialize your DataService if needed
    await Get.putAsync(() => DataService().init());

    // Set system overlay and orientation
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(RestartWidget(child: MyApp()));
  }, (error, stackTrace) {
    print('Unhandled Error: $error');
    print('Stack Trace: $stackTrace');
  });
}

/// Restart Widget to restart the app if needed
class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

/// Main App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AAVIN',
      debugShowCheckedModeBanner: false,

      /// Initial Binding
      initialBinding: BindingsBuilder(() {
        // Put RouteController so it’s available for RouteAssignmentScreen
        Get.put(RouteController());
      }),

      /// Set initial screen to RouteAssignmentScreen
      home: const RouteAssignmentScreen(),

      enableLog: true,
      smartManagement: SmartManagement.full,

      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        dialogBackgroundColor: Colors.white,
        cardColor: Colors.white,
      ),
    );
  }
}