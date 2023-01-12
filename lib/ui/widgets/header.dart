import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/cubit/user_cubit.dart';
import 'package:ionicons/ionicons.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
        builder: (BuildContext context, UserState user){
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2, top: 48, bottom: 24),
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .apply(fontWeightDelta: 2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2, top: 48, bottom: 24),
                child: TextButton.icon(
                  onPressed: () {
                    ///clear hydrated bloc state
                    BlocProvider.of<UserCubit>(context).clearUser();
                  },
                  icon:Icon(Ionicons.log_out_outline, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
}
