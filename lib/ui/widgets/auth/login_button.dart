import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class LoginButton extends StatefulWidget {
  final Function onTap;
  final Function onAnimatinoEnd;
  final double elementsOpacity;
  const LoginButton(
      {super.key,
      required this.onTap,
      required this.onAnimatinoEnd,
      required this.elementsOpacity});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 1, end: widget.elementsOpacity),
      onEnd: () async {
        widget.onAnimatinoEnd();
      },
      builder: (_, value, __) => GestureDetector(
        onTap: () {
          widget.onTap();
        },
        child: Opacity(
          opacity: value,
          child: Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Ionicons.log_in_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10,),
                Text(
                  tr('auth.login'),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .apply(fontWeightDelta: 2, fontSizeDelta: -2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
