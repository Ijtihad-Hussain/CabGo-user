class Review {
  final String id;
  final String userName;
  final String driverId;
  final int rating;
  String comment = 'no comment';
  double tip = 0;

  Review({
    required this.id,
    required this.userName,
    required this.driverId,
    required this.rating,
    required this.comment,
    required this.tip,
  });
}
