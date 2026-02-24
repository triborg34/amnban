import 'package:amnban/screens/setting_box.dart';

import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';

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
        ElevatedButton(
            onPressed: () async {
              final body = <String, dynamic>{
                "plateConf": scontroller.plateConf.value,
                "charConf": scontroller.charConf.value,
                "isRfid": scontroller.isRfid.value,
                "rl1": scontroller.isrlOne.value,
                "rl2": scontroller.isrlTwo.value,
                "rfidip": scontroller.rfipController.text,
                "rfidport": int.parse(scontroller.rfportConroller.text),
                "alarm": scontroller.isAlarm.value,
                "quality": (scontroller.quality.value).toInt(),
                'rfconnect':scontroller.rfconnect.value,
                'notif':scontroller.isNotif.value
              };

              final record = await pb
                  .collection('setting')
                  .update(scontroller.settings.first.id!, body: body);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ذخیره شد ${record.id}",  textDirection: TextDirection.rtl,)));
            },
            child: Text("ذخیره"))
      ],
    );
  }
}
