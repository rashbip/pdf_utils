import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ResultController extends GetxController {
    var imagesPath = <String>[].obs;

    @override
    void onInit() {
      super.onInit();
      if (Get.arguments != null && Get.arguments is List<String>) {
        imagesPath.value = Get.arguments;
      }
    }
}


class ResultPage extends GetView<ResultController> {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
      ),
      body: Obx(
        () => controller.imagesPath.isEmpty
            ? const Center(
                child: Text('No images'),
              )
            : ListView.builder(
                itemCount: controller.imagesPath.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(File(controller.imagesPath[index])),
                      // Center(child: Text(controller.imagesPath[index], style: const TextStyle(color: Colors.black),)),
                    ],
                  );
                },
              ),
      ),
    );
  }
}