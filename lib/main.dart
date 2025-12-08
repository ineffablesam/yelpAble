import 'package:flutter/material.dart';
import 'package:flutter_refresh_rate_control/flutter_refresh_rate_control.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yelpable/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Add this line

  final _refreshRateControl = FlutterRefreshRateControl();

  // Request high refresh rate
  try {
    bool success = await _refreshRateControl.requestHighRefreshRate();
    if (success) {
      print('High refresh rate enabled');
    } else {
      print('Failed to enable high refresh rate');
    }
  } catch (e) {
    print('Error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'First Method',
            initialRoute: AppPages.INITIAL,
            getPages: AppPages.routes,
          ),
        );
      },
    );
  }
}
