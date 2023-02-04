import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';

class AccountField extends StatefulWidget {
  final bool fadeAccount;
  final TextEditingController accountController;
  final String errorText;
  late bool invalid;

  AccountField(
      {super.key, required this.accountController, required this.fadeAccount, required this.errorText, required this.invalid});

  @override
  State<AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<AccountField>
    with SingleTickerProviderStateMixin {
  double bottomAnimationValue = 0;
  double opacityAnimationValue = 0;
  EdgeInsets paddingAnimationValue = EdgeInsets.only(top: 22);

  late TextEditingController accountController;
  late AnimationController _animationController;
  late Animation<Color?> _animation;
  FocusNode node = FocusNode();

  @override
  void initState() {
    accountController = widget.accountController;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    final tween = ColorTween(begin: Colors.grey.withOpacity(0), end: Colors.indigoAccent);

    _animation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();

    node.addListener(() {
      if (node.hasFocus) {
        setState(() {
          bottomAnimationValue = 1;
        });
      } else {
        setState(() {
          bottomAnimationValue = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300),
          tween: Tween(begin: 0, end: widget.fadeAccount ? 0 : 1),
          builder: ((_, value, __) => Opacity(
                opacity: value,
                child: TextFormField(
                  controller: accountController,
                  focusNode: node,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Ionicons.person_circle_outline, color: Theme.of(context).colorScheme.primary),
                    hintText: tr('auth.enumber'),
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                    errorText: widget.invalid ? widget.errorText : null,
                    suffixIcon: SizedBox(width:30, child: AnimatedPadding(
                      curve: Curves.easeIn,
                      duration: Duration(milliseconds: 500),
                      padding: paddingAnimationValue,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: widget.fadeAccount ? 0 : 1),
                        duration: Duration(milliseconds: 700),
                        builder: ((context, value, child) => Opacity(
                          opacity: value,
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0)
                                  .copyWith(bottom: 0),
                              child: Icon(Ionicons.checkmark_outline,
                                  size: 27,
                                  color: _animation.value // _animation.value,
                              ),
                            ),
                          ),
                        )),
                      ),
                    ),),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      if (isValidAccount(value)) {
                        setState(() {
                          bottomAnimationValue = 0;
                          opacityAnimationValue = 1;
                          paddingAnimationValue = EdgeInsets.only(top: 0);
                        });
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                        setState(() {
                          bottomAnimationValue = 1;
                          opacityAnimationValue = 0;
                          paddingAnimationValue = EdgeInsets.only(top: 22);
                        });
                      }
                    } else {
                      setState(() {
                        bottomAnimationValue = 0;
                      });
                    }
                  },
                  inputFormatters: [
                    _UpperCaseTextFormatter(),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  bool isValidAccount(String account) {
    ///工號
    return RegExp(r'^H?([A-Z]{2})-(([a-zA-Z\-0-9]){3,})$').hasMatch(account);
    ///Email Verify
    // return RegExp(
    //         r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
    //     .hasMatch(account);
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}