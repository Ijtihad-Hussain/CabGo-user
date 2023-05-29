import 'package:cab_go_user/utils/brandDivider.dart';
import 'package:cab_go_user/utils/constants.dart';
import 'package:cab_go_user/utils/predictionTileWidget.dart';
import 'package:cab_go_user/utils/providerAppData.dart';
import 'package:cab_go_user/utils/requestHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'models/prediction.dart';

String? pickupAddress;
String? destinationAddress;

class SearchPage extends StatefulWidget {
  // String? pickupLocation;
  // String? destinationLocation;
  SearchPage();
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  // var destinationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  var focusDestination = FocusNode();

  bool focused = false;

  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  List<Prediction> destinationPredictionList = [];

  // void searchPlace(String placeName) async {
  //   if (placeName.length > 1) {
  //     String url =
  //         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&types=geocode&key=$apiKey';
  //     var response = await RequestHelper.getRequest(url);
  //
  //     if (response == 'failed') {
  //       return;
  //     }
  //     if (response['status'] == 'OK') {
  //       var predictionJson = response['predictions'];
  //       var thisList = (predictionJson as List)
  //           .map((e) => Prediction.fromJson(e))
  //           .toList();
  //
  //       setState(() {
  //         destinationPredictionList = thisList;
  //       });
  //     }
  //   }
  // }

  void searchPlace(String placeName) async {
    if (placeName.isEmpty) {
      return;
    }

    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&types=geocode&key=$apiKey';
    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      var predictionJson = response['predictions'];
      var thisList = (predictionJson as List)
          .map((e) => Prediction.fromJson(e))
          .toList();

      setState(() {

        destinationPredictionList = thisList;
      });
    }
  }

  @override
  void dispose() {
    // destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    pickupAddress = Provider.of<AppData>(context).pickupAddress?.placeName ?? '';
    pickupController.text = pickupAddress!;

    destinationAddress = Provider.of<AppData>(context).destinationAddress?.placeName ?? '';
    destinationController.text = destinationAddress!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 225.h,
              decoration: BoxDecoration(
                color: kLBlack,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 12.r,
                    spreadRadius: 0.5.r,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 48, bottom: 28, right: 24, left: 24),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5.h,
                      ),
                      Stack(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back)),
                          Center(
                            child: Text('setDest'.tr,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 14.h,
                      ),
                      Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/cab.png',
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(
                            width: 18.w,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: TextField(
                                  controller: pickupController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'pickL'.tr,
                                    fillColor: Colors.white30,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/destination.png',
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(
                            width: 18.w,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child:
                                TextField(
                                  // onChanged: (value) {
                                  //   searchPlace(value);
                                  // },
                                  onSubmitted: (value) {
                                    searchPlace(value);
                                  },
                                  focusNode: focusDestination,
                                  controller: destinationController,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'whereTo'.tr,
                                    fillColor: Colors.white30,
                                    filled: true,
                                    border: InputBorder.none,
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: kYellow),
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            (destinationPredictionList.length > 0)
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
              padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return destinationPredictionList != null
                            ? PredictionTileWidget(
                                prediction: destinationPredictionList[index],
                              )
                            : Container();
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          BrandDivider(),
                      itemCount: destinationPredictionList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
