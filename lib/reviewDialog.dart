import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import 'models/review.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String driverId;

  LeaveReviewScreen({required this.driverId});

  @override
  _LeaveReviewScreenState createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  int _rating = 3;

  void _submitReview() {
    final review = Review(
      id: UniqueKey().toString(),
      userName: FirebaseAuth.instance.currentUser!.displayName!,
      driverId: widget.driverId,
      rating: _rating,
      comment: _commentController.text,
      tip: double.tryParse(_tipController.text) ?? 0.0, // add tip value
    );
    FirebaseFirestore.instance.collection('reviews').doc(review.id).set({
      'userName': review.userName,
      'driverId': review.driverId,
      'rating': review.rating,
      'comment': review.comment,
      'tip': review.tip, // save tip value in Firestore
    }).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Leave a Review'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Rate your driver',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: SmoothStarRating(
                rating: _rating.toDouble(),
                size: 48.0,
                color: Theme.of(context).primaryColor,
                borderColor: Theme.of(context).primaryColor,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating.toInt();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter a comment',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _tipController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter a tip amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
