import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class LogoutButton extends StatefulWidget {
  final Function onPressed;
  const LogoutButton(
      {super.key, required this.onPressed});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  @override

  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        widget.onPressed();
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
    );
  }
}
