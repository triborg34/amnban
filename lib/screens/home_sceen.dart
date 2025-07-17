import 'package:amnban/utils/controller.dart';

import 'package:amnban/widgets/extended_table.dart';

import 'package:amnban/widgets/data_base_entries.dart';



import 'package:amnban/widgets/video_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeSceen extends StatelessWidget {
  HomeSceen({
    required this.mController,
    super.key,
  });
  mainPageConroller mController;
  databaseController dcontroller = Get.find<databaseController>();
  knowPersonController kcontroller = Get.find<knowPersonController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              VideoBox(mController: mController),
              SizedBox(
                width: 15,
              ),
              dataBaseEntries(
                  dcontroller: dcontroller,
                  mController: mController,
                  kcontroller: kcontroller)
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Obx(() => dcontroller.entries.isEmpty
              ? SizedBox.shrink()
              : Visibility(
                  visible: mController.isSelected.value,
                  child: ExtendedTable(
                    index: dcontroller.selectedIndex.value,
                      dcontroller: dcontroller, kcontroller: kcontroller),
                )),
        ],
      ),
    );
  }
}
