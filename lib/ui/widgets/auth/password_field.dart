import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController passwordController;
  final bool fadePassword;
  final String errorText;
  final bool invalid;

  const PasswordField(
      {super.key,
      required this.passwordController,
      required this.fadePassword,
        required this.errorText,
        required this.invalid});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  double bottomAnimationValue = 0;
  double opacityAnimationValue = 0;
  late TextEditingController passwordController;
  bool obscure = true;
  FocusNode node = FocusNode();
  @override
  void initState() {
    passwordController = widget.passwordController;
    node.addListener(() {
      if (!node.hasFocus) {
        setState(() {
          bottomAnimationValue = 0;
          opacityAnimationValue = 0;
        });
      } else {
        setState(() {
          bottomAnimationValue = 1;
          opacityAnimationValue = 1;
        });
        if (passwordController.text.isEmpty) {
          setState(() {
            bottomAnimationValue = 1;
          });
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300),
          tween: Tween(begin: 0, end: widget.fadePassword ? 0 : 1),
          builder: ((_, value, __) => Opacity(
                opacity: value,
                child: TextFormField(
                  controller: passwordController,
                  focusNode: node,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Ionicons.lock_closed_outline, color: Theme.of(context).colorScheme.primary),
                    hintText: tr('auth.password'),
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                    errorText: widget.invalid ? widget.errorText : null,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      child:
                      new Icon(obscure ? Ionicons.eye_outline : Ionicons.eye_off_outline, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  obscureText: obscure,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        bottomAnimationValue = 0;
                        opacityAnimationValue = 0;
                      });
                    } else {
                      if (bottomAnimationValue == 0) {
                        setState(() {
                          bottomAnimationValue = 1;
                          opacityAnimationValue = 1;
                        });
                      }
                    }
                  },
                ),
              )),
        ),
      ],
    );
  }
}
