import 'dart:convert';

import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:amnban/widgets/rtspOff.dart';
import 'package:amnban/widgets/rtspOnn.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddOrEditCamera extends StatefulWidget {
  const AddOrEditCamera({
    super.key,
    required this.ccontroller,
    required this.context,
    required this.name,
    required this.ip,
    required this.cport,
    required this.rtsp,
    required this.rtspName,
    required this.username,
    required this.password,
    required this.isRtsp,
    required this.gate,
    required this.isEditing,
    required this.isDiscovery,
    required this.path,
    this.id,
  });

  final cameraController ccontroller;
  final dynamic context;
  final String name;
  final String ip;
  final String cport;
  final String rtsp;
  final String rtspName;
  final String username;
  final String password;
  final bool isRtsp;
  final String gate;
  final bool isEditing;
  final bool isDiscovery;
  final String? id;
  final String? path;

  @override
  State<AddOrEditCamera> createState() => _AddOrEditCameraState();
}

class _AddOrEditCameraState extends State<AddOrEditCamera> {
  late final cameraController ccontroller;
  late final bool isEditing;
  late final bool isDiscovery;
  late final String? id;
  late final String? path;

  @override
  void initState() {
    ccontroller = widget.ccontroller;
    isEditing = widget.isEditing;
    isDiscovery = widget.isDiscovery;
    id = widget.id;
    path = widget.path;
    // Seed the fields once on open; doing this in build() wiped the user's
    // edits on every rebuild.
    ccontroller.nameController.text = widget.name;
    ccontroller.ipController.text = widget.ip;
    ccontroller.portController.text = widget.cport;
    ccontroller.rtspController.text = widget.rtsp;
    ccontroller.rtspNameController.text = widget.rtspName;
    ccontroller.usernameController.text = widget.username;
    ccontroller.passwordController.text = widget.password;
    ccontroller.isRtspEnabled.value = widget.isRtsp;
    ccontroller.gateWayc.value = widget.gate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isEditing ? "ویرایش دوربین" : "اضافه کردن دوربین",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 150,
                        child: CoustomTextField2(
                            hint: 'نام',
                            tcontroller: ccontroller.nameController)),
                    const SizedBox(width: 24),
                    Obx(() => SizedBox(
                          width: 150,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: DropdownButtonFormField(
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 12.5),
                              dropdownColor: AppColors.surface,
                              decoration: InputDecoration(
                                  focusColor: Colors.transparent,
                                  fillColor: AppColors.surfaceHigh,
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.primary)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.border)),
                                  border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: AppColors.border))),
                              borderRadius: BorderRadius.circular(8),
                              initialValue: (ccontroller.gateWayc.value == 'entre' ||
                                      ccontroller.gateWayc.value == 'exit')
                                  ? ccontroller.gateWayc.value
                                  : 'entre',
                              items: const [
                                DropdownMenuItem(
                                    value: "entre", child: Text("ورود")),
                                DropdownMenuItem(
                                    value: "exit", child: Text("خروج"))
                              ],
                              onChanged: (value) =>
                                  ccontroller.gateWayc.value = value!,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => AnimatedCrossFade(
                      firstChild: RtspOff(ccontroller: ccontroller),
                      secondChild: RtspOn(ccontroller: ccontroller),
                      crossFadeState: ccontroller.isRtspEnabled.value == false
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 250),
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: 150,
                        child: CoustomTextField2(
                            hint: 'username',
                            tcontroller: ccontroller.usernameController)),
                    const SizedBox(
                      width: 24,
                    ),
                    SizedBox(
                        width: 160,
                        child: CoustomTextField2(
                            hint: 'password',
                            tcontroller: ccontroller.passwordController))
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                    child: SizedBox(
                  width: 260,
                  height: 44,
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        if (ccontroller.nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                              const SnackBar(
                                  content: Text('نام دوربین لازم است')));
                          return;
                        }
                        try {
                          if (isDiscovery) {
                            var uri = Uri.parse(
                                'http://$url:$port/onvif/get-rtsp');
                            final Map<String, dynamic> body = {
                              "ip": ccontroller.ipController.text.trim(),
                              "port": ccontroller.portController.text.trim(),
                              "username":
                                  ccontroller.usernameController.text.trim(),
                              "password":
                                  ccontroller.passwordController.text
                            };

                            final resp = await http
                                .post(uri,
                                    body: jsonEncode(body),
                                    headers: {
                                      'Content-Type': "application/json"
                                    })
                                .timeout(const Duration(seconds: 15));
                            if (resp.statusCode >= 200 &&
                                resp.statusCode < 300) {
                              try {
                                final decoded = jsonDecode(resp.body);
                                final rtsp = decoded is Map
                                    ? decoded['rtsp']?.toString()
                                    : null;
                                if (rtsp != null && rtsp.isNotEmpty) {
                                  ccontroller.rtspController.text = rtsp;
                                  ccontroller.isRtspEnabled.value = true;
                                }
                              } catch (e) {
                                appLog('rtsp discovery parse failed', e);
                              }
                            }
                          }

                          if (!ccontroller.isRtspEnabled.value) {
                            ccontroller.rtspController.text =
                                "rtsp://${ccontroller.usernameController.text.trim()}:${ccontroller.passwordController.text}@${ccontroller.ipController.text.trim()}:${ccontroller.portController.text.trim()}/${ccontroller.rtspNameController.text.trim()}";
                          } else {
                            ccontroller.rtspNameController.text = 'stream';
                            try {
                              final rtsp = ccontroller.rtspController.text;
                              final afterSlashes = rtsp.split('//');
                              if (afterSlashes.length > 1) {
                                final hostPort = afterSlashes[1].split(":");
                                if (hostPort.length > 1) {
                                  ccontroller.ipController.text = hostPort[0];
                                  final portPart = hostPort[1];
                                  ccontroller.portController.text =
                                      portPart.length >= 3
                                          ? portPart.substring(0, 3)
                                          : portPart;
                                }
                              }
                            } catch (e) {
                              appLog('rtsp parse failed', e);
                            }
                          }

                          final body = <String, dynamic>{
                            "name": ccontroller.nameController.text.trim(),
                            "ip": ccontroller.ipController.text.trim(),
                            "port": ccontroller.portController.text.trim(),
                            "rtspName":
                                ccontroller.rtspNameController.text.trim(),
                            "rtspUrl": ccontroller.rtspController.text.trim(),
                            "isRtsp": ccontroller.isRtspEnabled.value,
                            "gate": ccontroller.gateWayc.value,
                            'username':
                                ccontroller.usernameController.text.trim(),
                            'password': base64.encode(utf8.encode(
                                ccontroller.passwordController.text)),
                            'path': path
                          };

                          if (isEditing) {
                            if (id == null || id!.isEmpty) return;
                            final record = await pb
                                .collection('cameras')
                                .update(id!, body: body)
                                .timeout(
                                    const Duration(seconds: 15));
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                SnackBar(
                                    content:
                                        Text("${record.id} Edited")));
                          } else {
                            final record = await pb
                                .collection('cameras')
                                .create(body: body)
                                .timeout(
                                    const Duration(seconds: 15));
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                                SnackBar(content: Text(record.id)));
                          }
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          appLog('save camera failed', e);
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                              const SnackBar(
                                  content: Text('خطا در ذخیره دوربین')));
                        }
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        "ثبت",
                        style: TextStyle(color: Colors.white, fontSize: 14),
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
