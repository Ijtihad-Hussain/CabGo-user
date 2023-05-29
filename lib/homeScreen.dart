import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cab_go_user/models/directionDetails.dart';
import 'package:cab_go_user/reviewDialog.dart';
import 'package:cab_go_user/searchPage.dart';
import 'package:cab_go_user/utils/constants.dart';
import 'package:cab_go_user/utils/helperMethods.dart';
import 'package:cab_go_user/utils/progressDialog.dart';
import 'package:cab_go_user/utils/providerAppData.dart';
import 'package:cab_go_user/widgets/drawer.dart';
import 'package:cab_go_user/widgets/requestingSheet.dart';
import 'package:cab_go_user/widgets/rideDetailsSheet.dart';
import 'package:cab_go_user/widgets/searchSheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'models/driver.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  // final String? userEmail;
  // final String? userPhone;
  // final String? photoURL;
  // // final String? pickupAddress;

  const HomeScreen({
    Key? key,
    this.userName,
    // this.userEmail,
    // this.userPhone,
    // this.photoURL,
    // this.pickupAddress,
  }) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  var pickLatLng;
  var destinationLatLng;

  double searchSheetHeight = (Platform.isIOS) ? 122.h : 120.h;
  double rideDetailsSheetHeight = 0; // (Platform.isIOS) ? 122 : 120;
  double requestingSheetHeight = 0;
  double tripSheetHeight = 0;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  var geoLocator = geo.Geolocator();
  geo.Position? currentPosition;
  DirectionDetails? tripDirectionDetails;

  bool drawCanOpen = true;

  DatabaseReference? rideRef;

  firestore.CollectionReference<Map<String, dynamic>>? rideRequests;

  firestore.DocumentReference<Map<String, dynamic>>? rideRequestRef;

  firestore.DocumentReference<Object?>? rideRequestDocRef;

  var rideStatus;

  String driverName = '';
  String driverId = '';

  Future<List<firestore.DocumentSnapshot>> getDrivers(double lat, lng) async {
    // Get a reference to the "drivers" collection in Firestore
    firestore.CollectionReference drivers =
        await firestore.FirebaseFirestore.instance.collection('drivers');

    // Create a query to retrieve drivers within the range
    firestore.Query query = await drivers.where('status', isEqualTo: 'online');


    // Execute the query and return the results
    firestore.QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  void setUpPositionLocator() async {
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    String address =
        await HelperMethods.findCordinateAddress(position, context);
  }

  // Future<void> _sendRideRequest() async {
  //   try{
  //     // Get a reference to the "ride_requests" collection in Firestore
  //     final rideRequests = _firestore.collection('rideRequests');
  //
  //     // Add a new document to the "ride_requests" collection with the ride request data
  //     final rideRequestDoc = await rideRequests.add({
  //       'name': _userName,
  //       'email': _userEmail,
  //       'phone': _userPhone,
  //       'pickup_address': pickupAddress,
  //       'destination_address': destinationAddress,
  //       'fair': offerPrice,
  //       'status': 'pending',
  //     });
  //
  //     // Get the document ID of the new ride request
  //     final requestId = rideRequestDoc.id;
  //
  //     // Query for all online drivers within a specified range (e.g. 10km)
  //     final onlineDriversSnapshot = await _firestore
  //         .collection('drivers')
  //         .where('status', isEqualTo: 'online')
  //         .get();
  //
  //     // Send a notification to each nearby driver
  //     for (final driverDoc in onlineDriversSnapshot.docs) {
  //       final driverData = driverDoc.data();
  //
  //       // Get the driver's FCM token
  //       final driverFcmToken = driverData['userId'];
  //
  //       // Construct the notification message
  //       final message = {
  //         'data': {
  //           'request_id': requestId,
  //           'type': 'ride_request',
  //         },
  //         'notification': {
  //           'title': 'New Ride Request',
  //           'body': 'A new ride request has been sent',
  //         },
  //         'android': {
  //           'priority': 'high',
  //           'channel_id': 'ride_request',
  //           'notification': {
  //             'sound': 'default',
  //             'icon': '@drawable/ic_notification',
  //           },
  //         },
  //         'token': driverFcmToken,
  //       };
  //
  //       // Send the notification to the driver
  //       await http.post(
  //         Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json',
  //           'Authorization': 'key=YOUR_SERVER_KEY',
  //         },
  //         body: jsonEncode(message),
  //       );
  //     }
  //
  //     // Display a success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Ride request sent'),
  //       ),
  //     );
  //     print('ride request notification sent successfuly');
  //   } catch(e){
  //     print('Error sending ride request $e');
  //   }
  // }

  // Future<void> sendRideRequestNotification(String name, String email, String phoneNumber, String fair, String pickupAddress, String destinationAddress,
  //     // GeoPoint userLocation
  //     ) async {
  //   // Get a reference to the "rideRequests" collection in Firestore
  //   final rideRequests = FirebaseFirestore.instance.collection('rideRequests');
  //
  //   // Get a reference to the Firebase Cloud Messaging instance
  //   final fcm = FirebaseMessaging.instance;
  //
  //   try {
  //     // Add a new document to the "rideRequests" collection with the ride request data
  //     final rideRequestDoc = await rideRequests.add({
  //       'name': name,
  //       'email': email,
  //       'phoneNumber': phoneNumber,
  //       'offered fair': fair,
  //       'pickupAddress': pickupAddress,
  //       'destinationAddress': destinationAddress,
  //       // 'userLocation': userLocation,
  //       'status': 'pending', // You can add additional fields here if needed
  //     });
  //
  //     // Get the document ID of the new ride request
  //     final requestId = rideRequestDoc.id;
  //
  //     // Query for all online drivers within the specified range
  //     final onlineDriversSnapshot = await FirebaseFirestore.instance
  //         .collection('drivers')
  //         .where('status', isEqualTo: 'online')
  //     //     .where('location', isGreaterThan: GeoPoint(
  //     //   userLocation.latitude - 0.18, // approx. 20km
  //     //   userLocation.longitude - 0.18, // approx. 20km
  //     // ))
  //     //     .where('location', isLessThan: GeoPoint(
  //     //   userLocation.latitude + 0.18, // approx. 20km
  //     //   userLocation.longitude + 0.18, // approx. 20km
  //     // ))
  //         .get();
  //
  //     // Send a notification to each nearby driver
  //     for (final driverDoc in onlineDriversSnapshot.docs) {
  //       print('driverDoc data ${driverDoc.data()}');
  //
  //
  //       // Get the driver's FCM token
  //       final driverFcmToken = driverDoc.data()['userId'];
  //       final ttl = int.tryParse(driverFcmToken);
  //
  //       // Construct the notification message
  //       final message = RemoteMessage(
  //         data: {
  //           'requestId': requestId,
  //           'type': 'rideRequest',
  //         },
  //         notification:  RemoteNotification(
  //           title: 'New ride request',
  //           body: '$name needs a ride',
  //         ),
  //         ttl: ttl,
  //       );
  //       // Send the notification to the driver
  //       // await fcm.sendMessage();
  //       FirebaseMessaging.onMessage.listen((message) {
  //         RemoteNotification? notification = message.notification;
  //         AndroidNotification? android = message.notification?.android;
  //       });
  //     }
  //
  //     print('Ride request notification sent successfully!');
  //   } catch (e) {
  //     print('Error sending ride request notification: $e');
  //   }
  // }

  void showDetailsSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsSheetHeight = (Platform.isIOS) ? 132.h : 126.h;
      mapBottomPadding = 136.h;
      drawCanOpen = false;
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isIOS) ? 122.h : 120.h;
      mapBottomPadding = 136.h;
      drawCanOpen = true;
    });
    // createRideRequest();
  }

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _photoUrl = '';

  late Timer _timer;
  bool _reloadBody = false;

  final TextEditingController _priceController = TextEditingController();
  double? offerPrice;

  void _updatePrice() {
    setState(() {
      offerPrice = double.parse(_priceController.text);
    });
  }

  void acceptRequest(String requestId) {
    FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({'status': 'accepted'}).then((_) {
      rideDetailsSheetHeight = 0;
      tripSheetHeight = 128.h;
      Navigator.of(context).pop();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> getRideStatus(BuildContext context) async {
    try {
      final DocumentSnapshot<
          Map<String, dynamic>>? rideRequestSnapshot = (await rideRequestDocRef
          ?.get()) as firestore.DocumentSnapshot<Map<String, dynamic>>?;
      if (rideRequestSnapshot != null && rideRequestSnapshot.exists) {
        final Map<String, dynamic> data = rideRequestSnapshot.data()!;
        rideStatus = data['status'];
        driverName = data['driverName'];
        driverId = data['driverId'];
      }
      print('get status success $rideStatus');
    } catch (e) {
      print('get status error $e');
    }
  }

  Future<void> _showRequestSentDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Sent'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your request has been sent successfully!'),
                SizedBox(height: 16.0),
                CircularProgressIndicator(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                tripSheetHeight = 128.h;
                rideDetailsSheetHeight= 0;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                deleteRequest();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _autoReloadPage(int seconds) async {
    // Wait for 5 seconds before reloading the page
    await Future.delayed(Duration(seconds: seconds));
    setState(() {
      _reloadBody = true;
    });
    getRideStatus(context);
  }


  @override
  void dispose() {
    _priceController.removeListener(_updatePrice);
    _priceController.dispose();
    super.dispose();
    _timer?.cancel();
  }

  @override
  void initState() {
    final User? user = _auth.currentUser;
    super.initState();
    // Start the timer to call _autoReloadPage every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _autoReloadPage(3); // Call the function with 5 seconds delay
    });

    HelperMethods.getCurrentUserInfo();
    _userName = user!.displayName ?? widget.userName ?? '';
    _userEmail = user!.email!;
    _userPhone = user!.phoneNumber ?? '';
    _photoUrl = user!.photoURL ??
        'https://cdn.pixabay.com/photo/2012/04/13/21/07/user-33638__480.png';
    _priceController.addListener(_updatePrice);
    offerPrice;
    pickupAddress;
    destinationAddress;
    _firebaseMessaging.subscribeToTopic('rideRequests');
    getRideStatus(context);
    print(rideStatus);
  }

  @override
  Widget build(BuildContext context) {
    // final Map<String, String>? args =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    //
    // final String pickupLocation = args?['pickup'] ?? 'empty';
    // final String destinationLocation = args?['destination'] ?? 'empty';
    // print('pickup$pickupLocation');

    final body = _reloadBody ? Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: mapBottomPadding),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          polylines: _polylines,
          markers: _Markers,
          circles: _Circles,
          initialCameraPosition: googlePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;

            setState(() {
              mapBottomPadding = 136.h;
            });
            setUpPositionLocator();
          },
        ),

        /// SearchSheet
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SearchSheet(
            height: searchSheetHeight,
            text: 'searchDest'.tr,
            ontap: () async {
              var response = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
              if (response == 'getDirection') {
                showDetailsSheet();
              }
            },
          ),
        ),

        /// RideDetails sheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: RideDetailsSheet(
            height: rideDetailsSheetHeight,
            text: (tripDirectionDetails != null)
                ? tripDirectionDetails!.distanceText!
                : '',
            textField: TextField(
              keyboardType: TextInputType.number,
              controller: _priceController,
              style: TextStyle(fontSize: 10.sp, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'fairOffered'.tr,
                labelStyle: TextStyle(color: Colors.white),
                prefixText: 'CHF ',
                prefixStyle:
                TextStyle(color: Colors.white60, fontSize: 10.sp),
                // prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kYellow),
                ),
              ),
            ),
            sendRequestWidget: Text(
              'sendRequest'.tr,
              style: TextStyle(color: Colors.black),
            ),
            ontap: () async {
              await _showRequestSentDialog(context);
              await sendRideRequest(_userName, _userEmail, _userPhone,
                  offerPrice!, pickupAddress!, destinationAddress!);
              await getRideStatus(context);
            },
          ),
        ),

        // tripSheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: tripSheetHeight,
          child: Container(
            color: kLBlack,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 5.w),
                          Text(
                            "Distance: ${(tripDirectionDetails != null)
                                ? tripDirectionDetails!.distanceText!
                                : ''}",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          SizedBox(width: 14.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  'Fare: CHF $offerPrice',
                                  style: TextStyle(color: Colors.blueAccent),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                    "Driver: $driverName",
                                  style: TextStyle(color: Colors.tealAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // SizedBox(
                      //   width: 66.w,
                      //   height: 30.h,
                      //   child: ElevatedButton(
                      //     style: ButtonStyle(
                      //       backgroundColor:
                      //       MaterialStateProperty.all(Colors.red),
                      //     ),
                      //     onPressed: () {
                      //       deleteRequest();
                      //       resetApp();
                      //     },
                      //     child: Text(
                      //       'Cancel',
                      //       style: TextStyle(fontSize: 10.sp),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: 80.w,
                        height: 30.h,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.greenAccent),
                          ),
                          onPressed: () {
                            getRideStatus(context);
                          },
                          child: Text(
                            rideStatus ?? 'status',
                            style: TextStyle(fontSize: 10.sp),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80.w,
                        height: 30.h,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(kYellow),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return LeaveReviewScreen(
                                    driverId: '$driverId',
                                );
                              },
                            );
                            resetApp();
                          },
                          child: Text(
                            'Rate Driver',
                            style: TextStyle(fontSize: 10.sp),
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
      ],
    ) : SizedBox.shrink();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: kLBlack,
      appBar: AppBar(
        backgroundColor: kDBlack,
        title: Center(child: Text('CabGo')),
        // Center(child: Text((drawCanOpen) ? 'letsRide'.tr : 'Confirm Ride')),
        leading: IconButton(
          icon: Icon((drawCanOpen) ? Icons.menu : Icons.arrow_back),
          onPressed: () {
            getDrivers(currentPosition!.latitude, currentPosition!.longitude);
            if (drawCanOpen) {
              scaffoldKey.currentState?.openDrawer();
            } else {
              resetApp();
            }
          },
        ),
      ),
      drawer: drawer(userName: _userName, photoUrl: _photoUrl),
      body: body,
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    pickLatLng = LatLng(pickup!.latitude!, pickup.longitude!);
    destinationLatLng = LatLng(destination!.latitude!, destination.longitude!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'wait'.tr),
    );
    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails!.encodedPoints!);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      _polylines.add(polyline);
    });

    // make polyline to fit into the map

    LatLngBounds bounds;
    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest:
            LatLng(destinationLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
      );
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
        northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: const CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12.r,
      center: pickLatLng,
      fillColor: Colors.greenAccent,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destination'),
      strokeColor: Colors.purple,
      strokeWidth: 3,
      radius: 12.r,
      center: destinationLatLng,
      fillColor: Colors.purpleAccent,
    );

    setState(() {
      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
  }

  Future<void> sendRideRequest(String name, String email, String phoneNumber,
      double fair, String pickupAddress, String destinationAddress) async {
    // Get a reference to the "rideRequests" collection in Firestore
    firestore.CollectionReference rideRequestsCollection =
        firestore.FirebaseFirestore.instance.collection('rideRequests');

    try {
      // Create a new document within the "rideRequests" collection using a DocumentReference
      rideRequestDocRef = rideRequestsCollection.doc();
      String? requestId = rideRequestDocRef?.id;

      // Set the data for the new ride request document
      await rideRequestDocRef?.set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'offered fair': fair,
        'pickupAddress': pickupAddress,
        'destinationAddress': destinationAddress,
        // 'pickLatLng': pickLatLng,
        // 'destinationLatLng': destinationLatLng,
        'status': 'pending', // You can add additional fields here if needed
        'requestId': requestId, // Set the UID of the currently logged in user
        'createdAt': firestore.FieldValue
            .serverTimestamp(), // Set the timestamp of when the ride request was created
      });

      print('Ride request sent successfully!');
    } catch (e) {
      print('Error sending ride request: $e');
    }
  }

  deleteRequest() {
    rideRequestDocRef?.delete();
    print('request deleted');
  }

  Future<void> updateRideRequestStatus(String status) async {
    try {
      await rideRequestDocRef?.update({'status': status});
      print('Ride request status updated successfully!');
    } catch (e) {
      print('Error updating ride request status: $e');
    }
  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      rideDetailsSheetHeight = 0;
      tripSheetHeight = 0;
      requestingSheetHeight = 0;
      searchSheetHeight = 122.h;
      mapBottomPadding = 136.h;
      drawCanOpen = true;
    });
    setUpPositionLocator();
  }
}
