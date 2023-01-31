// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:hws_app/config/theme.dart';
import 'package:hws_app/ui/pages/common/format_thousandths.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProgressBarCard extends StatelessWidget {
  const ProgressBarCard({super.key,
    required this.barName,
    required this.subNumber,
    required this.totalNumber,
    required this.barIcon,
  });

  final barName;
  final subNumber;
  final totalNumber;
  final barIcon;

  Color getBarColor() {
    final prenterage = subNumber / totalNumber;
    Color barColor = MetronicTheme.danger;

    if (prenterage > 0.75) {
      barColor = MetronicTheme.success;
    } else if (prenterage > 0.5) {
      barColor = MetronicTheme.primary;
    } else if (prenterage > 0.25) {
      barColor = MetronicTheme.warning;
    }

    return barColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow,
      color: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '・',
                      style: TextStyle(color: getBarColor()),
                    ),
                    Text(
                      barName,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall!.color),
                    ),
                  ],
                ),
                Icon(
                  barIcon,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .color
                      ?.withOpacity(0.3),
                  size: 40,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 5,
              left: 15,
              right: 15,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '\$ ${FormatThousandths(subNumber)}',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
          LinearPercentIndicator(
            animation: true,
            lineHeight: 6.0,
            percent: subNumber / totalNumber,
            barRadius: const Radius.circular(16),
            progressColor: getBarColor(),
          )
        ],
      ),
    );
  }
}