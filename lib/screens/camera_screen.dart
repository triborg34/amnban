import 'dart:convert';

import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_camera.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:amnban/widgets/camera_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Cameras management screen.
///
/// Cameras are grouped by direction (ورود / خروج) and each card shows the
/// live frame and the latest detection of that camera.
class CameraScreen extends StatelessWidget {
  CameraScreen({
    super.key,
  });

  cameraController ccontroller = Get.find<cameraController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BentoCard(
            child: Row(
              children: [
                const Expanded(
                  child: CardHeader(
                    title: 'مدیریت دوربین ها',
                    subtitle: 'ثبت، ویرایش و پیکربندی دوربین ها',
                    icon: Icons.videocam_rounded,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await showAdaptiveDialog(
                      context: context,
                      builder: (context) => AddOrEditCamera(
                        path: '/rt${ccontroller.cameras.length + 1}',
                        ccontroller: ccontroller,
                        context: context,
                        name: '',
                        ip: '',
                        cport: '',
                        isRtsp: false,
                        gate: 'entre',
                        password: '',
                        rtsp: '',
                        rtspName: '',
                        username: '',
                        isDiscovery: false,
                        isEditing: false,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('افزودن دوربین جدید'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final kcontroller = Get.find<knowPersonController>();

            final entryCameras = ccontroller.cameras
                .where((c) => (c.gate ?? 'entre') == 'entre')
                .toList();
            final exitCameras = ccontroller.cameras
                .where((c) => (c.gate ?? 'entre') != 'entre')
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _group(
                  context,
                  title: 'دوربین های ورود',
                  icon: Icons.login_rounded,
                  accent: AppColors.primary,
                  cameras: entryCameras,
                  kcontroller: kcontroller,
                ),
                const SizedBox(height: 14),
                _group(
                  context,
                  title: 'دوربین های خروج',
                  icon: Icons.logout_rounded,
                  accent: AppColors.warning,
                  cameras: exitCameras,
                  kcontroller: kcontroller,
                ),
                const SizedBox(height: 14),
                _discovery(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _group(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accent,
    required List<dynamic> cameras,
    required knowPersonController kcontroller,
  }) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: title,
            icon: icon,
            accent: accent,
            trailing: Text(
              '${cameras.length.toString().toPersianDigit()} دوربین',
              style: AppTheme.numeric(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (cameras.isEmpty)
            const AppEmptyState(
              message: 'دوربینی در این بخش ثبت نشده است',
              icon: Icons.videocam_off_outlined,
            )
          else
            CameraGrid(
              cameras: cameras.cast(),
              kcontroller: kcontroller,
              onExpand: (camera) => _edit(context, camera),
            ),
        ],
      ),
    );
  }

  Widget _discovery(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'جستجوی دوربین در شبکه',
            icon: Icons.wifi_find_rounded,
            trailing: OutlinedButton.icon(
              onPressed: () => ccontroller.startDiscovery(),
              icon: const Icon(Icons.search_rounded, size: 15),
              label: const Text('جستجو'),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final found = ccontroller.searchCameras;
            if (found.isEmpty) {
              return const AppEmptyState(
                message: 'برای جستجو دکمه جستجو را بزنید',
                icon: Icons.radar_rounded,
                compact: true,
              );
            }
            return Column(
              children: [
                for (final item in found)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam_outlined,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          '${item['ip']}:${item['port']}',
                          style: AppTheme.numeric(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () {
                            showAdaptiveDialog(
                              context: context,
                              builder: (context) => AddOrEditCamera(
                                path: '/rt${ccontroller.cameras.length + 1}',
                                ccontroller: ccontroller,
                                context: context,
                                name: '',
                                ip: item['ip'].toString(),
                                cport: item['port'].toString(),
                                isRtsp: false,
                                gate: 'entre',
                                password: '',
                                rtsp: '',
                                rtspName: 'stream',
                                username: '',
                                isDiscovery: true,
                                isEditing: false,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 14),
                          label: const Text('افزودن'),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, dynamic camera) async {
    String passwordPlain = '';
    try {
      final stored = camera.password;
      if (stored != null && stored.isNotEmpty) {
        passwordPlain = utf8.decode(base64.decode(stored));
      }
    } catch (e) {
      appLog('camera password decode failed', e);
    }
    if (!context.mounted) return;
    await showAdaptiveDialog(
      context: context,
      builder: (context) => AddOrEditCamera(
        path: camera.path,
        ccontroller: ccontroller,
        context: context,
        name: camera.name ?? '',
        ip: camera.ip ?? '',
        cport: camera.port ?? '',
        rtsp: camera.rtspUrl ?? '',
        rtspName: camera.rtspName ?? '',
        username: camera.username ?? '',
        password: passwordPlain,
        isRtsp: camera.isRtsp ?? false,
        gate: camera.gate ?? 'entre',
        id: camera.id,
        isEditing: true,
        isDiscovery: false,
      ),
    );
  }
}
