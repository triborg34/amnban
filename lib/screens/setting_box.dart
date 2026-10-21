import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/sliders_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Network / relay / alarm settings.
class SettingBox extends StatelessWidget {
  SettingBox({
    required this.scontroller,
    super.key,
  });
  settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;

        final network = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اطلاعات شبکه',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ipFunction("نام شبکه", "Lan"),
            const SizedBox(height: 8),
            ipFunction("آدرس شبکه", "${url}"),
            const SizedBox(height: 8),
            ipFunction("نوع آدرس", 'IPV4'),
          ],
        );

        final tuning = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تنظیمات تشخیص',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SlidersWidgets(scontroller: scontroller),
          ],
        );

        final relay = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'اتصال به رله',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(
                  width: 110,
                  child: Text(
                    "فعال سازی رله",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Obx(() => Switch(
                      value: scontroller.isRfid.value,
                      onChanged: (value) async {
                        scontroller.isRfid.value = value;
                        scontroller.rfconnect.value = value;
                      },
                    )),
              ],
            ),
            Obx(() => Visibility(
                  visible: scontroller.isRfid.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: scontroller.rfipController,
                              readOnly: false,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'arial'),
                              decoration: const InputDecoration(
                                labelText: 'آدرس شبکه',
                                hintText: 'eg:192.168.1.91',
                                hintTextDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: scontroller.rfportConroller,
                              readOnly: false,
                              textDirection: TextDirection.ltr,
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'arial'),
                              decoration: const InputDecoration(
                                labelText: 'پورت',
                                hintText: 'eg:2000',
                                hintTextDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("رله یک", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Obx(() => Checkbox(
                                value: scontroller.isrlOne.value,
                                onChanged: (value) {
                                  scontroller.isrlOne.value = value!;
                                },
                              )),
                          const SizedBox(width: 16),
                          const Text("رله دو", style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          Obx(() => Checkbox(
                                value: scontroller.isrlTwo.value,
                                onChanged: (value) {
                                  scontroller.isrlTwo.value = value!;
                                },
                              )),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(
                  width: 110,
                  child: Text(
                    "فعال سازی آلارم",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Obx(() => Switch(
                      value: scontroller.isAlarm.value,
                      onChanged: (value) {
                        scontroller.isAlarm.value = value;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(value ? " فعال شد" : "غیر فعال شد",
                                textDirection: TextDirection.rtl)));
                      },
                    )),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(
                  width: 110,
                  child: Text(
                    "فعال سازی هشدار",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Obx(() => Switch(
                      value: scontroller.isNotif.value,
                      onChanged: (value) {
                        platformNotification.requestPermission();
                        scontroller.isNotif.value = value;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(value ? " فعال شد" : "غیر فعال شد",
                                textDirection: TextDirection.rtl)));
                      },
                    )),
              ],
            ),
          ],
        );

        final columns = <Widget>[network, tuning, relay];

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                columns[i],
              ],
            ],
          );
        }

        return Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            for (final column in columns)
              SizedBox(width: (constraints.maxWidth - 36) / 3, child: column),
          ],
        );
      },
    );
  }

  Padding ipFunction(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "${label}:",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
