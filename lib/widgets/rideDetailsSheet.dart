import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/constants.dart';

class RideDetailsSheet extends StatefulWidget {
  final double? height;
  final VoidCallback? ontap;
  final String? text;
  final Widget? sendRequestWidget;
  final TextField? textField;

  RideDetailsSheet({Key? key, this.height, this.ontap, this.text, this.textField,this.sendRequestWidget})
      : super(key: key);

  @override
  State<RideDetailsSheet> createState() => _RideDetailsSheetState();
}

class _RideDetailsSheetState extends State<RideDetailsSheet> {

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      // vsync: this,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeIn,
      child: Container(
        decoration: BoxDecoration(
          color: kLBlack,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.r), topRight: Radius.circular(15.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15.r,
              spreadRadius: 0.5.r,
              offset: Offset(0.7, 0.7),
            ),
          ],
        ),
        height: widget.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: kDBlack,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/cab.png',
                          height: 50.h,
                          width: 50.w,
                        ),
                        SizedBox(
                          width: 16.w,
                        ),
                        Column(
                          children: [
                            Text(
                              'Cab',
                              style:
                                  TextStyle(fontSize: 14.sp, color: Colors.white),
                            ),
                            // Text((tripDirectionDetails != null) ? '\$${HelperMethods.estimateFares(tripDirectionDetails!)}' : '', style: TextStyle(fontSize: 11),),
                          ],
                        ),
                        Expanded(child: Container()),
                        Text(
                          widget.text!,
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: widget.textField!,
                    ),
                    SizedBox(width: 5.w),
                    TextButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(kYellow),
                      ),
                      onPressed: widget.ontap,
                      child: widget.sendRequestWidget!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
