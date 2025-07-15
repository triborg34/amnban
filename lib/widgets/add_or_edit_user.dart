import 'dart:convert';

import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';

class add_or_edit_user extends StatelessWidget {
  add_or_edit_user({
    required this.name,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
    this.index,
    required this.isEdit,
    required this.role,
    required this.ucontroller,
    super.key,
  });
  userController ucontroller;
  String name;
  String lastName;
  String email;
  String username;
  String password;
  String role;
  int? index;
  bool isEdit;

  @override
  Widget build(BuildContext context) {
    ucontroller.name.text = name;
    ucontroller.lastName.text = lastName;
    ucontroller.email.text = email;
    ucontroller.username.text = username;
    ucontroller.password.text = password;
    ucontroller.accsesslvl.value = role;
    isEdit = isEdit;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(15),
          width: 300,
          height: 500,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                isEdit ? "ویرایش کاربر" : "اضافه کردن کاربر",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: ucontroller.name, hint: 'نام', width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: ucontroller.lastName,
                  hint: 'نام خانوادگی',
                  width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: ucontroller.email, hint: 'ایمیل', width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: ucontroller.username,
                  hint: 'نام کاربری ',
                  width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: ucontroller.password,
                  hint: 'رمز عبور',
                  width: 250),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                width: 250,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: DropdownButtonFormField(
                      style: TextStyle(color: Colors.black),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                          focusColor: Colors.transparent,
                          fillColor: Colors.white,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black))),
                      borderRadius: BorderRadius.circular(15),
                      value: ucontroller.accsesslvl.value,
                      items: [
                        DropdownMenuItem(
                            value: "مدیر",
                            child: Text(
                              "مدیر",
                              style: TextStyle(),
                            )),
                        DropdownMenuItem(value: "ناظر", child: Text("ناظر"))
                      ],
                      onChanged: (value) =>
                          ucontroller.accsesslvl.value = value!),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          side: BorderSide(color: Colors.black),
                          backgroundColor: Colors.white),
                      onPressed: () async {
                        try {
                          final body = {
                            "username": ucontroller.username.text,
                            "password": base64
                                .encode(utf8.encode(ucontroller.password.text)),
                            "accsesslvl": ucontroller.accsesslvl.value,
                            "email": ucontroller.email.text,
                            "nickname":
                                "${ucontroller.name.text.trim()} ${ucontroller.lastName.text.trim()}"
                          };

                          if (isEdit) {
                            final record = await pb.collection('users').update(
                                ucontroller.users[index!].id!,
                                body: body);
                            ScaffoldMessenger.maybeOf(context)!
                                .showSnackBar(SnackBar(
                                    content: Text(
                              "با ویرایش  شد ${record.id}",
                              textDirection: TextDirection.rtl,
                            )));
                          } else {
                            final record =
                                await pb.collection('users').create(body: body);
                            ScaffoldMessenger.maybeOf(context)!
                                .showSnackBar(SnackBar(
                                    content: Text(
                              "با موفقیت ساخته شد ${record.id}",
                              textDirection: TextDirection.rtl,
                            )));
                          }

                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.maybeOf(context)!
                              .showSnackBar(SnackBar(
                                  content: Text(
                            "خطا دوباره امتحان کنید",
                            textDirection: TextDirection.rtl,
                          )));
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        "ثبت",
                        style: TextStyle(color: Colors.black),
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
