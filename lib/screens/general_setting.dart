import 'package:amnban/screens/setting_box.dart';

import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GeneralSetting extends StatelessWidget {
  const GeneralSetting({
    super.key,
    required this.scontroller,
  });

  final settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingBox(
          scontroller: scontroller,
        ),
        SizedBox(
          height: 15,
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ElevatedButton.icon(
            onPressed: () async {
              final portParsed =
                  int.tryParse(scontroller.rfportConroller.text.trim());
              if (portParsed == null) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
                    content: Text('پورت نامعتبر است',
                        textDirection: TextDirection.rtl)));
                return;
              }
              if (scontroller.settings.isEmpty ||
                  scontroller.settings.first.id == null) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
                    content: Text('تنظیمات یافت نشد',
                        textDirection: TextDirection.rtl)));
                return;
              }
              final body = <String, dynamic>{
                "plateConf": scontroller.plateConf.value,
                "charConf": scontroller.charConf.value,
                "isRfid": scontroller.isRfid.value,
                "rl1": scontroller.isrlOne.value,
                "rl2": scontroller.isrlTwo.value,
                "rfidip": scontroller.rfipController.text.trim(),
                "rfidport": portParsed,
                "alarm": scontroller.isAlarm.value,
                "quality": (scontroller.quality.value).toInt(),
                'rfconnect': scontroller.rfconnect.value,
                'notif': scontroller.isNotif.value
              };

              try {
                final record = await pb
                    .collection('setting')
                    .update(scontroller.settings.first.id!, body: body)
                    .timeout(const Duration(seconds: 15));
                http.get(Uri.parse('http://${url}:${port}/utils/setting'));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  "ذخیره شد ${record.id} ",
                  textDirection: TextDirection.rtl,
                )));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                  "خطا در ذخیره",
                  textDirection: TextDirection.rtl,
                )));
              }
            },
            icon: const Icon(Icons.save_outlined, size: 16),
            label: const Text("ذخیره"),
          ),
        ),
      ],
    );
  }
}
