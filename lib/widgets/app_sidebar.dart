import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_colors.dart';
import '../utils/consts.dart';
import '../utils/controller.dart';
import 'app_logo.dart';

/// A single entry of the sidebar navigation tree.
class SidebarItem {
  const SidebarItem({
    required this.label,
    this.icon,
    this.target,
    this.children = const [],
    this.expandable = false,
    this.onSelect,
  });

  final String label;
  final IconData? icon;

  /// Label of the tab this entry activates (see `tabsFor(role)`).
  final String? target;

  final List<SidebarItem> children;
  final bool expandable;

  /// Extra action executed after navigation (used by the settings sections).
  final VoidCallback? onSelect;
}

/// Dark-teal sidebar used as a fixed panel on wide screens and as a drawer on
/// phones.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    this.onNavigate,
    this.showCloseButton = false,
  });

  final VoidCallback? onNavigate;
  final bool showCloseButton;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  Timer? _clock;
  late DateTime _now;

  /// Sections that are expanded by default.
  final Set<String> _expanded = {'تنظیمات کاربر'};

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mcontroller = Get.find<mainPageConroller>();
    final items = _buildItems();

    return Material(
      color: AppColors.sidebar,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sidebar, AppColors.sidebarDeep],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 18),
                Container(height: 1, color: AppColors.sidebarBorder),
                const SizedBox(height: 10),
                for (final item in items)
                  Obx(() => _SidebarTile(
                        item: item,
                        activeTarget: _activeTarget(mcontroller),
                        expanded: _expanded.contains(item.label),
                        onToggle: () => setState(() {
                          if (!_expanded.remove(item.label)) {
                            _expanded.add(item.label);
                          }
                        }),
                        onSelect: (child) {
                          if (child.target != null) {
                            final index = _indexFor(child.target!);
                            if (index != null) {
                              mcontroller.navitaionIndex.value = index;
                            }
                          }
                          child.onSelect?.call();
                          widget.onNavigate?.call();
                        },
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ header

  Widget _header() {
    final jalali = Jalali.fromDateTime(_now);
    final date = '${jalali.year}/${jalali.month}/${jalali.day}';
    final time =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DiespiEmblem(size: 46),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'دیدبان سیستم پایش پلاک',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sidebarText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(
                    child: Text(
                      'Parking Live',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showCloseButton)
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close, color: AppColors.sidebarMuted),
                tooltip: 'بستن',
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.sidebarBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 13,
                color: AppColors.sidebarMuted,
              ),
              const SizedBox(width: 6),
              // Date and time are separate LTR runs so the order stays
              // "date time" inside the RTL sidebar.
              Text(
                date.toPersianDigit(),
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.sidebarMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time.toPersianDigit(),
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.sidebarMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------- items

  List<SidebarItem> _buildItems() {
    final items = <SidebarItem>[];

    items.add(const SidebarItem(
      label: 'داشبورد',
      icon: Icons.dashboard_outlined,
      target: 'خانه',
    ));
    items.add(const SidebarItem(
      label: 'گزارش‌ها',
      icon: Icons.assessment_outlined,
      target: 'گزارشات',
    ));
    items.add(const SidebarItem(
      label: 'لیست پلاک',
      icon: Icons.confirmation_number_outlined,
      target: 'افراد',
    ));

    if (_indexFor('دوربین') != null) {
      items.add(const SidebarItem(
        label: 'دوربین‌ها',
        icon: Icons.videocam_outlined,
        expandable: true,
        children: [
          SidebarItem(
            label: 'لیست دوربین‌ها',
            icon: Icons.videocam_outlined,
            target: 'دوربین',
          ),
        ],
      ));
    }

    if (_indexFor('تنظیمات') != null) {
      items.add(SidebarItem(
        label: 'تنظیمات کاربر',
        icon: Icons.folder_outlined,
        expandable: true,
        children: [
          SidebarItem(
            label: 'کاربران',
            icon: Icons.group_outlined,
            target: 'تنظیمات',
            onSelect: _openSettingsSection('کاربران'),
          ),
          SidebarItem(
            label: 'سطح دسترسی',
            icon: Icons.admin_panel_settings_outlined,
            target: 'تنظیمات',
            onSelect: _openSettingsSection('سطح دسترسی'),
          ),
        ],
      ));

      items.add(SidebarItem(
        label: 'اطلاعات پایه',
        icon: Icons.folder_outlined,
        expandable: true,
        children: [
          SidebarItem(
            label: 'تنظیمات عمومی',
            icon: Icons.tune_outlined,
            target: 'تنظیمات',
            onSelect: _openSettingsSection('عمومی'),
          ),
          SidebarItem(
            label: 'درباره سامانه',
            icon: Icons.info_outline,
            target: 'تنظیمات',
            onSelect: _openSettingsSection('درباره'),
          ),
        ],
      ));
    }

    return items;
  }

  /// Opens the settings screen on the requested section.
  VoidCallback _openSettingsSection(String section) {
    return () {
      if (!Get.isRegistered<settingController>()) return;
      final s = Get.find<settingController>();
      switch (section) {
        case 'کاربران':
        case 'سطح دسترسی':
          s.isUsers.value = true;
          s.isGeneral.value = false;
          s.isInfo.value = false;
          break;
        case 'عمومی':
          s.isGeneral.value = true;
          s.isUsers.value = false;
          s.isInfo.value = false;
          break;
        case 'درباره':
          s.isInfo.value = true;
          s.isUsers.value = false;
          s.isGeneral.value = false;
          break;
      }
    };
  }

  // ------------------------------------------------------------------ helpers

  /// Index of the tab with the given Persian label, `null` when the current
  /// role has no such tab.
  int? _indexFor(String tabLabel) {
    final labels = tabsFor(role);
    final index = labels.indexOf(tabLabel);
    return index == -1 ? null : index;
  }

  String? _activeTarget(mainPageConroller mcontroller) {
    final labels = tabsFor(role);
    final index = mcontroller.navitaionIndex.value;
    if (index < 0 || index >= labels.length) return null;
    return labels[index];
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.activeTarget,
    required this.expanded,
    required this.onToggle,
    required this.onSelect,
  });

  final SidebarItem item;
  final String? activeTarget;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(SidebarItem) onSelect;

  @override
  Widget build(BuildContext context) {
    final isActive = item.target != null && item.target == activeTarget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row(context, isActive: isActive),
        if (item.expandable && expanded)
          Padding(
            padding: const EdgeInsets.only(right: 18, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in item.children)
                  _row(context, child: child),
              ],
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, {bool isActive = false, SidebarItem? child}) {
    final entry = child ?? item;
    final active = entry.target != null && entry.target == activeTarget;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active
            ? AppColors.primary.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (entry.expandable && child == null) {
              onToggle();
              if (entry.target != null) onSelect(entry);
              return;
            }
            onSelect(entry);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                if (entry.icon != null) ...[
                  Icon(
                    entry.icon,
                    size: child == null ? 17 : 14,
                    color: active
                        ? AppColors.primary
                        : AppColors.sidebarMuted,
                  ),
                  const SizedBox(width: 9),
                ],
                Expanded(
                  child: Text(
                    entry.label,
                    style: TextStyle(
                      fontSize: child == null ? 12.5 : 11.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? Colors.white
                          : AppColors.sidebarText,
                    ),
                  ),
                ),
                if (entry.expandable && child == null)
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_left,
                    size: 17,
                    color: AppColors.sidebarMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
