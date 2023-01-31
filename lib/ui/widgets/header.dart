import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/cubit/user_cubit.dart';
import 'package:ionicons/ionicons.dart';
import 'package:uiblock/uiblock.dart';

import '../../service/authenticate/auth.dart';
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
                    ArtDialogResponse response = await ArtSweetAlert.show(
                        barrierDismissible: false,
                        context: context,
                        artDialogArgs: ArtDialogArgs(
                            denyButtonText: tr('alerts.cancel'),
                            title: tr('alerts.logout_confirm_title'),
                            text: tr('alerts.logout_confirm_text'),
                            confirmButtonText: tr('alerts.confirm'),
                            type: ArtSweetAlertType.warning
                        )
                    );

                    if(response==null) {
                      return;
                    }

                    if(response.isTapConfirmButton) {
                      UIBlock.block(context);
                      bool logout = await AuthService().logout();
                      UIBlock.unblock(context);
                      if(logout){
                        BlocProvider.of<UserCubit>(context).clearUser();
                        //Navigator.pushNamed(context, '/login');
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                      return;
                    }
                  },
                ),
              ),
            ],
          );
        }
    );
  }
}
