import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';

class add_or_edit_user extends StatelessWidget {
  add_or_edit_user({
    required this.ucontroller,
    super.key,
  });
  userController ucontroller;

  @override
  Widget build(BuildContext context) {
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
                "اضافه کردن کاربر",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: TextEditingController(), hint: 'نام', width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: TextEditingController(),
                  hint: 'نام خانوادگی',
                  width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: TextEditingController(),
                  hint: 'ایمیل',
                  width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: TextEditingController(),
                  hint: 'نام کاربری ',
                  width: 250),
              SizedBox(
                height: 15,
              ),
              CoustomTextField3(
                  controller: TextEditingController(),
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
                      value: 'مدیر',
                      items: [
                        DropdownMenuItem(
                            value: "مدیر",
                            child: Text(
                              "مدیر",
                              style: TextStyle(),
                            )),
                        DropdownMenuItem(value: "ناظر", child: Text("ناظر"))
                      ],
                      onChanged: (value) => value!),
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
                      onPressed: () {},
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
