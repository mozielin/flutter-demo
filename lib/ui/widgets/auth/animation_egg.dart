
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AnimationEgg extends StatefulWidget {
  const AnimationEgg({Key? key, required this.stopScaleAnimation, required this.apiEnable}) : super(key: key);
  final bool stopScaleAnimation;
  final bool apiEnable;
  @override
  State<AnimationEgg> createState() => _AnimationEggState();
}

class _AnimationEggState extends State<AnimationEgg> {
  double _loadingBallSize = 1;

  @override
  Widget build(BuildContext context) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0, end: _loadingBallSize),
        onEnd: () {
          if (!widget.stopScaleAnimation) {
            setState(() {
              if (_loadingBallSize == 1) {
                _loadingBallSize = 1.5;
              } else {
                _loadingBallSize = 1;
              }
            });
          } else {
            if(widget.apiEnable){
              developer.log('ApiEnable...');
            }else{
              developer.log('ApiDisable...');
            }
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          }
        },
        builder: (_, value, __) => Transform.scale(
          scale: value,
          child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: !widget.stopScaleAnimation
                    ? Theme.of(context).colorScheme.primary
                    : null,
                shape: BoxShape.circle,
              ),
              child: null),
        ),
      ),
    );
  }
}
