import 'dart:convert';

import 'package:amnban/models/userClass.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
                              ucontroller.users[index].nickname ?? '-',
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
                              ucontroller.users[index].email ?? '-',
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
                              ucontroller.users[index].username ?? '-',
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
                              ucontroller.users[index].accsesslvl ?? '-',
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
                                  onPressed: () async {
                                    userClass user = ucontroller.users[index];
                                    String passwordPlain = '';
                                    try {
                                      final stored = user.password;
                                      if (stored != null &&
                                          stored.isNotEmpty) {
                                        passwordPlain = utf8
                                            .decode(base64.decode(stored));
                                      }
                                    } catch (e) {
                                      appLog('user password decode failed', e);
                                    }
                                    List<String> nameSplit =
                                        (user.nickname ?? '').split(' ');
                                    await showAdaptiveDialog(
                                        context: context,
                                        builder: (context) => add_or_edit_user(
                                            name: nameSplit.isNotEmpty
                                                ? nameSplit[0]
                                                : '',
                                            lastName:
                                                nameSplit.length > 1 ? nameSplit.sublist(1).join(' ') : '',
                                            username: user.username ?? '',
                                            password: passwordPlain,
                                            email: user.email ?? '',
                                            isEdit: true,
                                            role: user.accsesslvl ?? 'مدیر',
                                            index: index,
                                            ucontroller: ucontroller));
                                  },
                                  icon: Icon(Icons.edit))),
                        ),
                        VerticalDivider(
                          color: selecetpurpule,
                        ),
                       SizedBox(
                          width: 5.w,
                          height: 50,
                          child: Center(
                              child: IconButton(
                                  onPressed: () async {
                                    userClass user = ucontroller.users[index];
                                    final id = user.id;
                                    if (id == null || id.isEmpty) return;
                                    try {
                                      await pb
                                          .collection('users')
                                          .delete(id)
                                          .timeout(const Duration(
                                              seconds: 15));
                                    } catch (e) {
                                      appLog('delete user failed', e);
                                    }
                                  },
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
                        email: '',
                        isEdit: false,
                        lastName: '',
                        name: '',
                        password: '',
                        role: 'مدیر',
                        username: '',
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
