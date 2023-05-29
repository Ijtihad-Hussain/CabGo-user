import 'package:cab_go_user/splash_screen.dart';
import 'package:cab_go_user/utils/constants.dart';
import 'package:cab_go_user/utils/providerAppData.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'homeScreen.dart';
import 'utils/languages.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ScreenUtilInit(
      builder: (context, _) => MyApp(),
      designSize: const Size(375, 812),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: GetMaterialApp(
        title: 'CabGo',
        color: kYellow,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black54,
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/home', page: () => HomeScreen()),
          GetPage(name: '/login', page: () => LoginScreen()),
        ],
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        translations: Languages(), // define your translations class
        builder: (context, child) {
          return Directionality(
            textDirection: Get.locale?.languageCode == 'en'
                ? TextDirection.ltr
                : TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return Theme(
                  data: ThemeData(
                    platform: Get.locale?.languageCode == 'en'
                        ? TargetPlatform.android
                        : TargetPlatform.iOS,
                  ),
                  child: child!,
                );
              },
            ),
          );
        },
        home:
        // Directionality(
        //   textDirection: Get.locale?.languageCode == 'en'
        //       ? TextDirection.ltr
        //       : TextDirection.ltr,
        //   child:
          Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: kLBlack,
                  title: Text(
                    'cab_go'.tr,
                    // style: TextStyle(
                    //     // color: Colors.orangeAccent,
                    //     ),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 20.h),
                      child: PopupMenuButton<Locale>(
                        initialValue: Get.locale!,
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
                          const PopupMenuItem<Locale>(
                            value: Locale('en', 'US'),
                            child: Text('English'),
                          ),
                          const PopupMenuItem<Locale>(
                            value: Locale('de', 'DE'),
                            child: Text('Deutsch'),
                          ),
                        ],
                        onSelected: (Locale newLocale) {
                          Get.updateLocale(newLocale);
                        },
                      ),
                    ),
                  ],
                ),
                body: SplashScreen(),
              );
            },
          ),
        // ),
      ),
    );
  }
}