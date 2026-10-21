import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/consts.dart';
import '../utils/controller.dart';
import 'app_logo.dart';

/// One entry of the application navigation.
class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.target,
    this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;

  /// Label of the tab this destination activates (see `tabsFor(role)`).
  final String target;
}

/// Navigation destinations available for the current role.
List<NavDestination> navDestinationsFor(String currentRole) {
  final all = <NavDestination>[
    const NavDestination(
      label: 'داشبورد',
      icon: Icons.space_dashboard_outlined,
      activeIcon: Icons.space_dashboard_rounded,
      target: 'خانه',
    ),
    const NavDestination(
      label: 'گزارش‌ها',
      icon: Icons.query_stats_outlined,
      activeIcon: Icons.query_stats_rounded,
      target: 'گزارشات',
    ),
    const NavDestination(
      label: 'دوربین',
      icon: Icons.videocam_outlined,
      activeIcon: Icons.videocam_rounded,
      target: 'دوربین',
    ),
    const NavDestination(
      label: 'پلاک‌ها',
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number_rounded,
      target: 'افراد',
    ),
    const NavDestination(
      label: 'تنظیمات',
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune_rounded,
      target: 'تنظیمات',
    ),
  ];

  final tabs = tabsFor(currentRole);
  return all.where((d) => tabs.contains(d.target)).toList();
}

/// Index of the tab with the given Persian label (`null` when the role has no
/// such tab).
int? tabIndexFor(String tabLabel, String currentRole) {
  final index = tabsFor(currentRole).indexOf(tabLabel);
  return index == -1 ? null : index;
}

/// Floating navigation rail used on wide screens.
class AppNavRail extends StatelessWidget {
  const AppNavRail({super.key, this.onSelected});

  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final mcontroller = Get.find<mainPageConroller>();
    final destinations = navDestinationsFor(role);

    return Container(
      width: 94,
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 14, bottom: 10),
              child: AppMark(size: 26),
            ),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: AppColors.border,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  for (final destination in destinations)
                    Obx(
                      () => _RailItem(
                        destination: destination,
                        selected: _isSelected(mcontroller, destination),
                        onTap: () {
                          final index =
                              tabIndexFor(destination.target, role);
                          if (index == null) return;
                          mcontroller.navitaionIndex.value = index;
                          onSelected?.call(index);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isSelected(
      mainPageConroller mcontroller, NavDestination destination) {
    final labels = tabsFor(role);
    final index = mcontroller.navitaionIndex.value;
    if (index < 0 || index >= labels.length) return false;
    return labels[index] == destination.target;
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected
                    ? (destination.activeIcon ?? destination.icon)
                    : destination.icon,
                size: 20,
                color: color,
              ),
              const SizedBox(height: 5),
              Text(
                destination.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation bar used on phones.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.onSelected});

  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final mcontroller = Get.find<mainPageConroller>();
    final destinations = navDestinationsFor(role);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (final destination in destinations)
                Expanded(
                  child: Obx(
                    () => _BottomItem(
                      destination: destination,
                      selected: _isSelected(mcontroller, destination),
                      onTap: () {
                        final index =
                            tabIndexFor(destination.target, role);
                        if (index == null) return;
                        mcontroller.navitaionIndex.value = index;
                        onSelected?.call(index);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isSelected(
      mainPageConroller mcontroller, NavDestination destination) {
    final labels = tabsFor(role);
    final index = mcontroller.navitaionIndex.value;
    if (index < 0 || index >= labels.length) return false;
    return labels[index] == destination.target;
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : Colors.transparent,
                ),
                boxShadow: [
                  if (selected)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 14,
                      spreadRadius: -4,
                    ),
                ],
              ),
              child: Icon(
                selected
                    ? (destination.activeIcon ?? destination.icon)
                    : destination.icon,
                size: 19,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small caption style shared by the navigation elements.
class NavCaption extends StatelessWidget {
  const NavCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.numeric(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      ),
    );
  }
}
