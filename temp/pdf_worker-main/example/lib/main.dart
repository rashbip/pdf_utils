import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_worker_example/locker_page.dart';
import 'package:pdf_worker_example/merge_page.dart';
import 'package:pdf_worker_example/result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MergePage(),
      initialBinding: BindingsBuilder(
        () {
          Get.put(LockerController());
          Get.put(MergeController());
        },
      ),
      getPages: [
        GetPage(
          name: '/result',
          page: () => ResultPage(),
          binding: BindingsBuilder(
            () {
              Get.put(ResultController());
            },
          ),
        ),
      ],
    );
  }
}