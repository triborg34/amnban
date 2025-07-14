import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/add_or_edit_user.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({
    super.key,
  });

  userController ucontroller = Get.find<userController>();
  settingController scontroller = Get.find<settingController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      height: MediaQuery.maybeOf(context)!.size.height,
      width: MediaQuery.maybeOf(context)!.size.height,
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              scontroller.isUsers.value = !scontroller.isUsers.value;
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              width: MediaQuery.of(context).size.width,
              height: 50,
              color: purpule,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      "کاربران",
                      style: TextStyle(color: Colors.white),
                    ),
                    Spacer(),
                    Obx(
                      () => scontroller.isUsers.value
                          ? Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Obx(
            () => AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: UserBox(
                scontroller: scontroller,
                ucontroller: ucontroller,
              ),
              crossFadeState: scontroller.isUsers.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 350),
              firstCurve: Curves.decelerate,
              secondCurve: Curves.decelerate,
            ),
          )
        ],
      ),
    );
  }
}

class UserBox extends StatelessWidget {
  UserBox({
    required this.ucontroller,
    required this.scontroller,
    super.key,
  });

  userController ucontroller;
  settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: Get.width,
      height: 400,
      child: Column(
        children: [
          Obx(() => SizedBox(
                height: 300,
                child: ListView.builder(
                  primary: true,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Container(
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: selecetpurpule,
                        ),
                        borderRadius: BorderRadius.circular(5)),
                    width: Get.width,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        SizedBox(
                          width: 3.w,
                          height: 50,
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                        SizedBox(
                          width: 5.w,
                          height: 50,
                          child: Center(
                            child: Text(
                              ucontroller.users[index].nickname!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                        SizedBox(
                          width: 12.w,
                          height: 50,
                          child: Center(
                            child: Text(
                              ucontroller.users[index].email!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                        SizedBox(
                          width: 6.w,
                          height: 50,
                          child: Center(
                            child: Text(
                              ucontroller.users[index].username!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                        SizedBox(
                          width: 5.w,
                          height: 50,
                          child: Center(
                            child: Text(
                              ucontroller.users[index].accsesslvl!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                        SizedBox(
                          width: 5.w,
                          height: 50,
                          child: Center(
                              child: IconButton(
                                  onPressed: () {}, icon: Icon(Icons.edit))),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                        SizedBox(
                          width: 5.w,
                          height: 50,
                          child: Center(
                              child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ))),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        )
                      ],
                    ),
                  ),
                  itemCount: ucontroller.users.length,
                ),
              )),
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: () async {
                    await showAdaptiveDialog(
                      context: context,
                      builder: (context) => add_or_edit_user(
                        ucontroller: ucontroller,
                      ),
                    );
                  },
                  child: Text("اضافه کردن")))
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: purpule),
          borderRadius: BorderRadius.circular(15)),
    );
  }
}
