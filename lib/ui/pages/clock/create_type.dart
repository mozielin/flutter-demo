import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../config/theme.dart';
import '../../../cubit/theme_cubit.dart';

class ClockCreateType {
  typeBox(context) {
    return
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              const Padding(padding: EdgeInsets.all(5)),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                      shadowColor:
                                          Theme.of(context).colorScheme.shadow,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : MetronicTheme.light_success,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/create_clock',
                                              arguments: {'type': 'no_case'}
                                          );
                                        },
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Text(
                                              tr("clock.create_type.no_case_title"),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.primary:MetronicTheme.success,
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
                                      shadowColor:
                                          Theme.of(context).colorScheme.shadow,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : MetronicTheme.light_primary,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/create_clock',
                                              arguments: {'type': 'has_case'}
                                          );
                                        },
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Text(
                                              tr("clock.create_type.case_title"),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.primary:MetronicTheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Text(
                                              tr("clock.create_type.case_desc"),
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
                                      shadowColor:
                                          Theme.of(context).colorScheme.shadow,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : MetronicTheme.light_warning,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: ListTile(
                                        onTap: () {
                                          //context.read<BottomNavCubit>().updateIndex(4);
                                          Navigator.pushNamed(
                                              context, '/file_demo');
                                        },
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Icon(Ionicons.images_outline,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            Text(
                                              'File Demo',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .apply(
                                                      fontWeightDelta: 2,
                                                      fontSizeDelta: -2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      shadowColor:
                                          Theme.of(context).colorScheme.shadow,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Theme.of(context)
                                              .colorScheme
                                              .background
                                          : MetronicTheme.light_info,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/clock_demo');
                                        },
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(12))),
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Icon(Ionicons.time_outline,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            Text(
                                              'Clock Demo',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .apply(
                                                      fontWeightDelta: 2,
                                                      fontSizeDelta: -2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary
                          : MetronicTheme.light_dark,
                      child: Icon(
                        Ionicons.close_outline,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).textTheme.titleLarge!.color
                            : MetronicTheme.dark,
                      ),
                    ),
                  ],
                ),
              );
            });
  }
}
