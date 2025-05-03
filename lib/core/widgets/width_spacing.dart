import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WidthSpacing extends StatelessWidget {
  const WidthSpacing (this.width,{super.key});
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width?.h ?? 0);
  }
}
