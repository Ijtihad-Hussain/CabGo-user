import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/brandDivider.dart';
import '../utils/constants.dart';

class drawer extends StatelessWidget {
  final String? photoUrl;
  drawer({
    super.key,
    required String userName,
    this.photoUrl
  }) : _userName = userName;

  final String _userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            Container(
              height: 160,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    CircleAvatar(backgroundImage:NetworkImage(photoUrl!),radius: 25,),
                    const SizedBox(
                      width: 8,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _userName,
                            style: const TextStyle(fontSize: 20),
                          ),
                          // const SizedBox(
                          //   height: 5,
                          // ),
                          // const Text('View Profile'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BrandDivider(),
            const SizedBox(
              height: 10,
            ),
            // const ListTile(
            //   leading: Icon(Icons.card_giftcard),
            //   title: Text(
            //     'Free Rides',
            //     style: kDrawerItemStyle,
            //   ),
            // ),
            // const ListTile(
            //   leading: Icon(Icons.payment),
            //   title: Text(
            //     'Payments',
            //     style: kDrawerItemStyle,
            //   ),
            // ),
            // const ListTile(
            //   leading: Icon(Icons.history),
            //   title: Text(
            //     'Ride History',
            //     style: kDrawerItemStyle,
            //   ),
            // ),
            // const ListTile(
            //   leading: Icon(Icons.help_center),
            //   title: Text(
            //     'Support',
            //     style: kDrawerItemStyle,
            //   ),
            // ),
            // const ListTile(
            //   leading: Icon(Icons.access_time_filled),
            //   title: Text(
            //     'About',
            //     style: kDrawerItemStyle,
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                'Logout',
                style: kDrawerItemStyle.copyWith(
                  color: Colors.red,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to Login Screen
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}