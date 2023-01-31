import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/cubit/theme_cubit.dart';
import 'package:hws_app/cubit/user_cubit.dart';
import 'package:hws_app/ui/widgets/alert/alert_icons.dart';
import 'package:ionicons/ionicons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uiblock/uiblock.dart';

import '../../config/theme.dart';
import '../../data/models/user.dart';
import '../../service/authenticate/auth.dart';
import 'alert/icons/error_icon.dart';
import 'alert/styles.dart';
import 'auth/logout_button.dart';

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
                child: LogoutButton(
                  onPressed: () async {
                    _onLogoutButtonsPressed(context);
                    // ArtDialogResponse response = await ArtSweetAlert.show(
                    //     barrierDismissible: false,
                    //     context: context,
                    //     artDialogArgs: ArtDialogArgs(
                    //         denyButtonText: tr('alerts.cancel'),
                    //         title: tr('alerts.logout_confirm_title'),
                    //         text: tr('alerts.logout_confirm_text'),
                    //         confirmButtonText: tr('alerts.confirm'),
                    //         type: ArtSweetAlertType.warning
                    //     )
                    // );
                  },
                ),
              ),
            ],
          );
        }
    );
  }

  // Alert with multiple and custom buttons
  _onLogoutButtonsPressed(context) {
    Alert(
      context: context,
      style: AlertStyles().warningStyle(context),
      image: const WarningIcon(),
      title: tr('alerts.logout_confirm_title'),
      desc: tr('alerts.logout_confirm_text'),
      buttons: [
        DialogButton(
          onPressed: () async {
            bool logout = await AuthService().logout();
            if(logout){
              BlocProvider.of<UserCubit>(context).clearUser();
              //Navigator.pushNamed(context, '/login');
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
            return;
          },
          color: BlocProvider.of<ThemeCubit>(context).state.themeMode == ThemeMode.dark ? Theme.of(context).colorScheme.surface : MetronicTheme.primary,
          child: Text(
            tr('alerts.confirm'),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: BlocProvider.of<ThemeCubit>(context).state.themeMode == ThemeMode.dark ? Theme.of(context).colorScheme.surface : MetronicTheme.light_dark,
          child: Text(
            tr('alerts.cancel'),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ],
    ).show();
  }
}
