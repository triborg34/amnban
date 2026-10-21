import 'dart:convert';

import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_camera.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:amnban/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Cameras management screen.
///
/// Cameras are grouped by direction (ورود / خروج) and each card shows the
/// latest detection of that camera.
class CameraScreen extends StatelessWidget {
  CameraScreen({
    super.key,
  });

  cameraController ccontroller = Get.find<cameraController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          const SizedBox(height: 16),
          Obx(() {
            final kcontroller = Get.find<knowPersonController>();
            final dcontroller = Get.find<databaseController>();

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
                  title: 'دوربین های ورود',
                  icon: Icons.login,
                  cameras: entryCameras,
                  entries: dcontroller.entries,
                  kcontroller: kcontroller,
                ),
                const SizedBox(height: 16),
                _group(
                  title: 'دوربین های خروج',
                  icon: Icons.logout,
                  cameras: exitCameras,
                  entries: dcontroller.entries,
                  kcontroller: kcontroller,
                ),
                const SizedBox(height: 16),
                _discovery(context),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Expanded(
            child: AppSectionTitle(
              title: 'مدیریت دوربین ها',
              icon: Icons.videocam_outlined,
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
            icon: const Icon(Icons.add, size: 16),
            label: const Text('افزودن دوربین جدید'),
          ),
        ],
      ),
    );
  }

  Widget _group({
    required String title,
    required IconData icon,
    required List<dynamic> cameras,
    required List<dynamic> entries,
    required knowPersonController kcontroller,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionTitle(
            title: title,
            icon: icon,
            trailing: Text(
              '${cameras.length.toString().toPersianDigit()} دوربین',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 14),
          if (cameras.isEmpty)
            const AppEmptyState(
              message: 'دوربینی در این بخش ثبت نشده است',
              icon: Icons.videocam_off_outlined,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 3
                    : constraints.maxWidth >= 640
                        ? 2
                        : 1;
                final cardWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (int index = 0; index < cameras.length; index++)
                      SizedBox(
                        width: cardWidth,
                        child: _CameraCard(
                          camera: cameras[index],
                          index: index,
                          ccontroller: ccontroller,
                          entries: entries,
                          kcontroller: kcontroller,
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _discovery(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionTitle(
            title: 'جستجوی دوربین در شبکه',
            icon: Icons.wifi_find_outlined,
            trailing: OutlinedButton.icon(
              onPressed: () => ccontroller.startDiscovery(),
              icon: const Icon(Icons.search, size: 15),
              label: const Text('جستجو'),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final found = ccontroller.searchCameras;
            if (found.isEmpty) {
              return const AppEmptyState(
                message: 'برای جستجو دکمه جستجو را بزنید',
                icon: Icons.radar,
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
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam_outlined,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          '${item['ip']}:${item['port']}',
                          style: const TextStyle(
                            fontFamily: 'arial',
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
                          icon: const Icon(Icons.add, size: 14),
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
}

class _CameraCard extends StatelessWidget {
  const _CameraCard({
    required this.camera,
    required this.index,
    required this.ccontroller,
    required this.entries,
    required this.kcontroller,
  });

  final dynamic camera;
  final int index;
  final cameraController ccontroller;
  final List<dynamic> entries;
  final knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    final latest = _latestFor(entries, camera.path);
    final status = latest == null
        ? DetectionStatus.unrecognized
        : statusForEntry(latest, kcontroller);
    final imageUrl = latest == null
        ? ''
        : pbFileUrlOf('database', latest.id, latest.scrnPath);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InfoChip(
                      label: '${camera.name ?? 'دوربین'}  •  ${camera.ip ?? '-'}',
                      icon: Icons.videocam_outlined,
                      dense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'ویرایش',
                ),
                IconButton(
                  onPressed: () => _delete(context),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.danger),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF10201F),
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final previewHeight = (constraints.maxWidth * 9 / 16)
                    .clamp(120.0, 240.0)
                    .toDouble();
                return Container(
                  height: previewHeight,
                  alignment: Alignment.center,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.videocam_off_outlined,
                          color: Colors.white38, size: 28)
                      : SafeNetImage(
                          url: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    latest?.eTime ?? '-',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: StatusChip(
                      status: status,
                      dense: true,
                      label: latest == null ? 'بدون تردد' : null,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: latest == null
                        ? const Text('-',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textMuted))
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: EntryPlate(
                              entry: latest,
                              height: 30,
                              showIranLabel: false,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  dynamic _latestFor(List<dynamic> source, String? path) {
    if (path == null || path.isEmpty) return null;
    for (final e in source) {
      if (e.rtpath == path) return e;
    }
    return null;
  }

  Future<void> _edit(BuildContext context) async {
    final data = camera;
    String passwordPlain = '';
    try {
      final stored = data.password;
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
        path: data.path,
        ccontroller: ccontroller,
        context: context,
        name: data.name ?? '',
        ip: data.ip ?? '',
        cport: data.port ?? '',
        rtsp: data.rtspUrl ?? '',
        rtspName: data.rtspName ?? '',
        username: data.username ?? '',
        password: passwordPlain,
        isRtsp: data.isRtsp ?? false,
        gate: data.gate ?? 'entre',
        id: data.id,
        isEditing: true,
        isDiscovery: false,
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final id = camera.id;
    if (id == null || id.isEmpty) return;
    try {
      await pb
          .collection('cameras')
          .delete(id)
          .timeout(const Duration(seconds: 15));
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Camera Number $id is Deleted')),
      );
    } catch (e) {
      appLog('delete camera failed', e);
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('خطا در حذف دوربین')),
      );
    }
  }
}
