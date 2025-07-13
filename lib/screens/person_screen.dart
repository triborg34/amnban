import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/AlphaBetSelector.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonScreen extends StatelessWidget {
  PersonScreen({
    super.key,
  });

  knowPersonController kcontroller = Get.find<knowPersonController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => Container(
                height: 10,
                color: Colors.red,
              ),
              itemCount: 10,
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                await showAdaptiveDialog(
                  context: context,
                  builder: (context) {
                    return Center(
                        child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.all(15),
                        width: 450,
                        decoration: BoxDecoration(
                            color: const Color(0xFF6A5ACD),
                            borderRadius: BorderRadius.circular(15)),
                        height: 450,
                        child: Column(
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              'ثبت افراد',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                CoustomTextField1(
                                  controller: TextEditingController(),
                                  hint: "",
                                  width: 80,
                                ),
                                SizedBox(
                                  height: 40,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.deepPurple),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            DraggableScrollableSheet(
                                          initialChildSize:
                                              0.47, // You can adjust the size of the bottom sheet
                                          minChildSize: 0.3,
                                          maxChildSize: 0.7,
                                          expand: false,
                                          builder: (context, scrollController) {
                                          
                                            return Alphabetselector(
                                              scrollController:
                                                  scrollController,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Obx(() => Text(
                                          kcontroller.persianAlhpabet.value ==
                                                  ''
                                              ? "انتخاب حرف"
                                              : kcontroller
                                                  .persianAlhpabet.value,
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ));
                  },
                );
              },
              child: Text("اضافه کردن"))
        ],
      ),
    );
  }
}
