import 'dart:convert';

import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:amnban/widgets/rtspOff.dart';
import 'package:amnban/widgets/rtspOnn.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/consts.dart';

class AddOrEditCamera extends StatelessWidget {
  const AddOrEditCamera({
    
    super.key,
    required this.ccontroller,
    required this.context,
    required this.name,
    required this.ip,
    required this.port,
    required this.rtsp,
    required this.rtspName,
    required this.username,
    required this.password,
    required this.isRtsp,
    required this.gate,
    required this.isEditing,
    required this.isDiscovery,
    this.id
  }  );

  final cameraController ccontroller;
  final dynamic context;
  final String name;
  final String ip;
  final String port;
  final String rtsp;
  final String rtspName;
  final String username;
  final String password;
  final bool isRtsp;
  final String gate;
  final bool isEditing;
  final bool isDiscovery;
  final String? id;

  @override
  Widget build(BuildContext context) {
    ccontroller.nameController.text = name;
    ccontroller.ipController.text = ip;
    ccontroller.portController.text = port;
    ccontroller.rtspController.text = rtsp;
    ccontroller.rtspNameController.text = rtspName;
    ccontroller.usernameController.text = username;
    ccontroller.passwordController.text = password;
    ccontroller.isRtspEnabled.value = isRtsp;
    ccontroller.gateWayc.value = gate;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.indigo,
              border: Border.all(color: Color.fromARGB(255, 25, 32, 71)),
              borderRadius: BorderRadius.circular(15)),
          width: 400,
          height: 350,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isEditing ? "ویرایش دوربین" : "اضافه کردن دوربین",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 150,
                        child: CoustomTextField2(
                            hint: 'نام',
                            tcontroller: ccontroller.nameController)),
                    SizedBox(
                      width: 40,
                    ),
                    Obx(() => SizedBox(
                          width: 150,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: DropdownButtonFormField(
                            style: TextStyle(color: Colors.white),
                            dropdownColor:Color.fromARGB(255, 25, 32, 71) ,
                                decoration: InputDecoration(
                                  
                                    focusColor: Colors.transparent,
                                    fillColor: Color.fromARGB(255, 25, 32, 71),
                                    filled: true,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent))),
                                borderRadius: BorderRadius.circular(15),
                                value: ccontroller.gateWayc.value,
                                items: [
                                  DropdownMenuItem(
                                      value: "entre", child: Text("ورود",style: TextStyle(),)),
                                  DropdownMenuItem(
                                      value: "exit", child: Text("خروج"))
                                ],
                                onChanged: (value) =>
                                    ccontroller.gateWayc.value = value!),
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Obx(() => AnimatedCrossFade(
                      firstChild: RtspOff(ccontroller: ccontroller),
                      secondChild: RtspOn(ccontroller: ccontroller),
                      crossFadeState: ccontroller.isRtspEnabled.value == false
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                    )),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: 150,
                        child: CoustomTextField2(
                            hint: 'username',
                            tcontroller: ccontroller.usernameController)),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                        width: 160,
                        child: CoustomTextField2(
                            hint: 'password',
                            tcontroller: ccontroller.passwordController))
                  ],
                ),
                Spacer(),
                Center(
                    child: Container(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                      style:
                          TextButton.styleFrom(backgroundColor: Color.fromARGB(255, 25, 32, 71)),
                      onPressed: () async {
                        if (isDiscovery) {
                          var url =
                              Uri.parse('http://127.0.0.1:8000/onvif/get-rtsp');
                          final Map<String, dynamic> body = {
                            "ip": "${ccontroller.ipController.text}",
                            "port": "${ccontroller.portController.text}",
                            "username":
                                "${ccontroller.usernameController.text}",
                            "password": "${ccontroller.passwordController.text}"
                          };

                          await http.post(url,
                              body: jsonEncode(body),
                              headers: {
                                'Content-Type': "application/json"
                              }).then(
                            (value) {
                              ccontroller.rtspController.text =
                                  jsonDecode(value.body)['rtsp'];
                              ccontroller.isRtspEnabled.value = true;
                            },
                          );
                        }

                        if (!ccontroller.isRtspEnabled.value) {
                          ccontroller.rtspController.text =
                              "rtsp://${ccontroller.usernameController.text}:${ccontroller.passwordController.text}@${ccontroller.ipController.text}:${ccontroller.portController.text}/${ccontroller.rtspNameController.text}";
                        } else {
                          ccontroller.rtspNameController.text = 'stream';
                          ccontroller.ipController.text = ccontroller
                              .rtspController.text
                              .split('//')[1]
                              .split(":")[0];
                          ccontroller.portController.text = ccontroller
                              .rtspController.text
                              .split('//')[1]
                              .split(":")[1]
                              .substring(0, 3);
                        }

                        final body = <String, dynamic>{
                          "name": ccontroller.nameController.text,
                          "ip": ccontroller.ipController.text,
                          "port": ccontroller.portController.text,
                          "rtspName": ccontroller.rtspNameController.text,
                          "rtspUrl": ccontroller.rtspController.text,
                          "isRtsp": ccontroller.isRtspEnabled.value,
                          "gate": ccontroller.gateWayc.value,
                          'username': ccontroller.usernameController.text,
                          'password': base64.encode(
                              utf8.encode(ccontroller.passwordController.text)),
                          'path':"/rt${ccontroller.cameras.length+1}"
                        };

                        if (isEditing) {
                          final record = await pb
                              .collection('cameras')
                              .update(id!, body: body);
                                ScaffoldMessenger.maybeOf(context)!
                            .showSnackBar(SnackBar(content: Text("${record.id} Edited")));
                        }
                       else{
                         final record =
                            await pb.collection('cameras').create(body: body);
                              ScaffoldMessenger.maybeOf(context)!
                            .showSnackBar(SnackBar(content: Text(record.id)));
                       }
                        Navigator.pop(context);
                      
                      },
                      child: Text(
                        "ثبت",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
