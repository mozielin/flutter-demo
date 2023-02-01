import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hws_app/ui/pages/api_demo.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:secure_application/secure_application.dart';
import '../../cubit/bottom_nav_cubit.dart';
import '../../cubit/user_cubit.dart';
import '../../service/authenticate/auth.dart';
import '../pages/home.dart';
import '../widgets/alert/icons/error_icon.dart';
import '../widgets/alert/styles.dart';
import '../widgets/app_bar_gone.dart';
import '../widgets/bottom_nav_bar.dart';
import 'first_screen.dart';
import 'second_screen.dart';

class SkeletonScreen extends StatelessWidget {
  const SkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SecureApplication(
      nativeRemoveDelay: 800,
      // This callback method will be called when the app becomes available again
      // and its content was hidden with an overlay. We can provide logic to
      // unlock the content again. Here we can use any auth logic, for example
      // biometrics with the local_auth package.
      onNeedUnlock: (secureApplicationStateNotifier) {
        var user = BlocProvider.of<UserCubit>(context).state;
        AuthService().verifyToken(user.token)
            .then((res) {
          if (res['success']) {
            var token = res['token'];
            BlocProvider.of<UserCubit>(context).refreshToken(user, token);
            print("Token refresh : $token");
            secureApplicationStateNotifier!.unlock();
          } else {
            ///Alert token expired return to login
            Alert(
              context: context,
              style: AlertStyles().blockStyle(context),
              image: const ErrorIcon(),
              title: tr('alerts.token_expired_title'),
              desc: tr('alerts.token_expired_text'),
              buttons: [
                AlertStyles().getReturnLoginButton(context),
              ],
            ).show();
            BlocProvider.of<UserCubit>(context).clearUser();
          }
        }).onError((error, stackTrace) {
          BlocProvider.of<UserCubit>(context).clearUser();

        });
        return null;
      },
      child: _SecureApplicationContent(),
    );
  }
}

class _SecureApplicationContent extends StatefulWidget {
  const _SecureApplicationContent({super.key});

  @override
  State<_SecureApplicationContent> createState() =>
      _SecureApplicationContentState();
}

class _SecureApplicationContentState extends State<_SecureApplicationContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Enable the feautre. This will add overlay when our app goes background.
    SecureApplicationProvider.of(context)?.secure();
  }

  @override
  Widget build(BuildContext context) {
    const List<Widget> pageNavigation = <Widget>[
      Home(),
      SecondScreen(),
      ApiDemo(),
      FirstScreen(),
    ];
    // Wrap the sensitive part with SecureGate.
    // This will hide the sensitive part until we unlock the content.
    return SecureGate(
      blurr: 100,
      opacity: 0,
      // The content of this builder will be displayed after our app
      // comes back to foreground and its content was hidden with the overlay.
      lockedBuilder: (context, secureApplicationController) => Center(
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0, end: 1),
            builder: (_, value, __) => Transform.scale(
              scale: value,
              child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: null),
            ),
          ),
        ),
      ),
      child: BlocProvider<BottomNavCubit>(
          create: (BuildContext context) => BottomNavCubit(),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: const AppBarGone(),
            /// When switching between tabs this will fade the old
            /// layout out and the new layout in.
            body: BlocBuilder<BottomNavCubit, int>(
              builder: (BuildContext context, int state) {
                return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: pageNavigation.elementAt(state));
              },
            ),

            bottomNavigationBar: const BottomNavBar(),
            backgroundColor: Theme.of(context).colorScheme.background,
          )),
    );
  }
}
