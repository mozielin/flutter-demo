import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../config/theme.dart';
import '../../cubit/bottom_nav_cubit.dart';
import 'clock/card_hole_clipper.dart';

class BottomNavBar extends StatelessWidget {
  /// It is okay not to use a const constructor here.
  /// Using const breaks updating of selected BottomNavigationBarItem.
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController dialogController = ScrollController();
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
            } else {
              //todo:子亘搬到別的地方
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(padding: EdgeInsets.all(25)),
                          ClipPath(
                            child: Card(
                              shadowColor: Theme.of(context).colorScheme.shadow,
                              color: Theme.of(context).colorScheme.surface,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              child: ListTile(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                                title: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    const Padding(padding: EdgeInsets.all(5)),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(tr("clock.appbar.create")),
                                              ],
                                            ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 20,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .color,
                                    ),
                                    SizedBox(
                                      height: 500,
                                      child: GridView.count(
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 1,
                                        childAspectRatio: 4 / 1.15,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(10),
                                        children: [
                                          Card(
                                            shadowColor: Theme.of(context).colorScheme.shadow,
                                            color: MetronicTheme.light_success,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12))),
                                            child: ListTile(
                                              onTap: (){
                                                Navigator.pushNamed(context, '/create_clock', arguments: {'type':'no_case'});
                                              },
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                                              title: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                    tr("clock.create_type.no_case_title"),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: MetronicTheme.success,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    tr("clock.create_type.no_case_desc"),
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Card(
                                            // elevation: 2,
                                            shadowColor: Theme.of(context).colorScheme.shadow,
                                            color: MetronicTheme.light_primary,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12))),
                                            child: ListTile(
                                              onTap: (){
                                                Navigator.pushNamed(context, '/hive_demo');
                                              },
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                                              title: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Icon(Ionicons.server_outline, color: Theme.of(context).colorScheme.primary),
                                                  Text(
                                                    'Hive Demo',
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Card(
                                            shadowColor: Theme.of(context).colorScheme.shadow,
                                            color: MetronicTheme.light_warning,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12))),
                                            child: ListTile(
                                              onTap: (){
                                                //context.read<BottomNavCubit>().updateIndex(4);
                                                Navigator.pushNamed(context, '/file_demo');
                                              },
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                                              title: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Icon(Ionicons.images_outline, color: Theme.of(context).colorScheme.primary),
                                                  Text(
                                                    'File Demo',
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Card(
                                            shadowColor: Theme.of(context).colorScheme.shadow,
                                            color: MetronicTheme.light_info,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12))),
                                            child: ListTile(
                                              onTap: (){
                                                Navigator.pushNamed(context, '/clock_demo');
                                              },
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                                              title: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  Icon(Ionicons.time_outline, color: Theme.of(context).colorScheme.primary),
                                                  Text(
                                                    'Clock Demo',
                                                    textAlign: TextAlign.center,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // child: ListView(
                                      //   controller: dialogController,
                                      //   padding: EdgeInsets.all(10),
                                      //   children: [
                                      //     Card(
                                      //       shadowColor: Theme.of(context).colorScheme.shadow,
                                      //       color: MetronicTheme.light_success,
                                      //       shape: const RoundedRectangleBorder(
                                      //           borderRadius: BorderRadius.all(Radius.circular(12))),
                                      //       child: ListTile(
                                      //         onTap: (){
                                      //           Navigator.pushNamed(context, '/clock_demo');
                                      //         },
                                      //         shape: const RoundedRectangleBorder(
                                      //             borderRadius: BorderRadius.all(Radius.circular(12))),
                                      //         title: Column(
                                      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //           children: <Widget>[
                                      //             Icon(Ionicons.time_outline, color: Theme.of(context).colorScheme.primary),
                                      //             Text(
                                      //               'Clock Demo',
                                      //               textAlign: TextAlign.center,
                                      //               overflow: TextOverflow.ellipsis,
                                      //               style: Theme.of(context)
                                      //                   .textTheme
                                      //                   .titleMedium!
                                      //                   .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     const Padding(padding: EdgeInsets.only(top:25)),
                                      //     Card(
                                      //       elevation: 2,
                                      //       shadowColor: Theme.of(context).colorScheme.shadow,
                                      //       color: MetronicTheme.light_primary,
                                      //       shape: const RoundedRectangleBorder(
                                      //           borderRadius: BorderRadius.all(Radius.circular(12))),
                                      //       child: ListTile(
                                      //         onTap: (){
                                      //           Navigator.pushNamed(context, '/clock_demo');
                                      //         },
                                      //         shape: const RoundedRectangleBorder(
                                      //             borderRadius: BorderRadius.all(Radius.circular(12))),
                                      //         title: Column(
                                      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //           children: <Widget>[
                                      //             Icon(Ionicons.time_outline, color: Theme.of(context).colorScheme.primary),
                                      //             Text(
                                      //               'Clock Demo',
                                      //               textAlign: TextAlign.center,
                                      //               overflow: TextOverflow.ellipsis,
                                      //               style: Theme.of(context)
                                      //                   .textTheme
                                      //                   .titleMedium!
                                      //                   .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Padding(padding: EdgeInsets.all(5)),
                          FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            backgroundColor: MetronicTheme.light_dark,
                            child: const Icon(
                              Ionicons.close_outline,
                              color: MetronicTheme.dark,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
              print('test');
            }
          },
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).textTheme.bodySmall!.color,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.home_outline),
              label: tr('bottom_nav_first'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Ionicons.information_circle_outline),
              label: tr('bottom_nav_second'),
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
              icon: const Icon(Ionicons.server_outline),
              label: tr('bottom_nav_hive'),
            ),
          ],
        );
      }),
    );
  }
}
