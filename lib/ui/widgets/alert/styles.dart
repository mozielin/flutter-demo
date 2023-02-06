import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hws_app/config/theme.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AlertStyles {
  AlertStyle blockStyle(context) {
    return AlertStyle(
      isCloseButton: false,
      isOverlayTapDismiss: false,
      descStyle: const TextStyle(fontSize: 15),
      descTextAlign: TextAlign.center,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: const TextStyle(
        color: MetronicTheme.danger,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      alertAlignment: Alignment.center,
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      overlayColor: Colors.black54,
    );
  }

  AlertStyle dangerStyle(context) {
    return AlertStyle(
      isCloseButton: true,
      isOverlayTapDismiss: true,
      descStyle: const TextStyle(fontSize: 15),
      descTextAlign: TextAlign.center,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: const TextStyle(
        color: MetronicTheme.danger,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      alertAlignment: Alignment.center,
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      overlayColor: Colors.black54,
    );
  }

  AlertStyle warningStyle(context) {
    return AlertStyle(
      isCloseButton: true,
      isOverlayTapDismiss: true,
      descStyle: const TextStyle(fontSize: 15),
      descTextAlign: TextAlign.center,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: const TextStyle(
        color: MetronicTheme.warning,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      alertAlignment: Alignment.center,
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      overlayColor: Colors.black54,
    );
  }
  AlertStyle successStyle(context) {
    return AlertStyle(
      isCloseButton: true,
      isOverlayTapDismiss: true,
      descStyle: const TextStyle(fontSize: 15),
      descTextAlign: TextAlign.center,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: const TextStyle(
        color: MetronicTheme.success,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      alertAlignment: Alignment.center,
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      overlayColor: Colors.black54,
    );
  }

  DialogButton getReturnLoginButton(context) {
    return DialogButton(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Text(
        tr('alerts.return_login'),
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .apply(fontWeightDelta: 2, fontSizeDelta: -2),
      ),
      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
    );
  }

  DialogButton getConfirmButton(context) {
    return DialogButton(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Text(
        tr('alerts.confirm'),
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .apply(fontWeightDelta: 2, fontSizeDelta: -2),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  DialogButton getCancelButton(context) {
    return DialogButton(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Text(
        tr('alerts.cancel'),
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .apply(fontWeightDelta: 2, fontSizeDelta: -2),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  DialogButton getDoneButton(context, route) {
    return DialogButton(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Text(
        tr('alerts.confirm_done'),
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .apply(fontWeightDelta: 2, fontSizeDelta: -2),
      ),
      onPressed: (){
        Navigator.popAndPushNamed(context, route);
      },
    );
  }
}
