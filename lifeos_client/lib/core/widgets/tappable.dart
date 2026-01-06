import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Tappable extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final double lowerBound;
  const Tappable({
    Key? key,
    required this.child,
    required this.onTap,
    this.lowerBound = 0.9,
  }) : super(key: key);

  @override
  _TappableState createState() => _TappableState();
}

class _TappableState extends State<Tappable> with TickerProviderStateMixin {
  double squareScaleA = 1;
  late AnimationController _controllerA;
  @override
  void initState() {
    _controllerA = AnimationController(
      vsync: this,
      lowerBound: widget.lowerBound,
      upperBound: 1.0,
      value: 1,
      duration: Duration(milliseconds: 100),
    );
    _controllerA.addListener(() {
      setState(() {
        squareScaleA = _controllerA.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _controllerA.reverse();
        SystemSound.play(SystemSoundType.click);
        widget.onTap();
      },
      onTapDown: (dp) {
        _controllerA.reverse();
      },
      onTapUp: (dp) {
        Timer(Duration(milliseconds: 150), () {
          _controllerA.fling();
        });
      },
      onTapCancel: () {
        _controllerA.fling();
      },
      child: Transform.scale(scale: squareScaleA, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controllerA.dispose();
    super.dispose();
  }
}
