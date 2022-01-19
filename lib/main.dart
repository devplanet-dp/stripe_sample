import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stripe_sample_app/ui/screens/home_screen.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _linkSubscription;

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;
      router(uri!);
    }, onError: (Object err) {
      print('Got error $err');
    });
  }

  router(Uri uri) {
    if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments[0];
      switch (path) {
        case 'register-success':
          Get.showSnackbar(GetSnackBar(
            title: "Registration success",
            message: uri.queryParameters['account_id'],
          ));
          break;
        default:
          Get.showSnackbar(const GetSnackBar(
            title: "Registration not completed",
            message: '',
          ));
          break;
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
