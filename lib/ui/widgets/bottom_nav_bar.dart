import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../config/theme.dart';
import '../../cubit/bottom_nav_cubit.dart';
import '../../cubit/theme_cubit.dart';
import '../pages/clock/create_type.dart';
import 'clock/card_hole_clipper.dart';

class BottomNavBar extends StatelessWidget {
  /// It is okay not to use a const constructor here.
  /// Using const breaks updating of selected BottomNavigationBarItem.
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController dialogController = ScrollController();
    final themeMode = BlocProvider.of<ThemeCubit>(context).state.themeMode;
    return Card(
      margin: const EdgeInsets.only(top: 1, right: 4, left: 4),
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: BlocBuilder<BottomNavCubit, int>(
          builder: (BuildContext context, int state) {
        return BottomNavigationBar(
          currentIndex: state,
          onTap: (int index) {
            if (index != 2) {
              context.read<BottomNavCubit>().updateIndex(index);
            } else { //登錄工時
              ClockCreateType().typeBox(context);
            }
          },
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).textTheme.bodySmall!.color,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.bar_chart_outline),
              label: tr('bottom_nav_first'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.apps_outline),
              label: tr('bottom_nav_app'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.cloud_upload_outline),
              label: tr('bottom_nav_clock'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.paper_plane_outline),
              label: tr('bottom_nav_api'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.settings_outline),
              label: tr('bottom_setting'),
            ),
          ],
        );
      }),
    );
  }
}
