import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';

class ReviewPage extends StatefulWidget {
  final String restaurantName;
  final String restaurantImage;

  const ReviewPage({
    Key? key,
    required this.restaurantName,
    required this.restaurantImage,
  }) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 4.0;
  final TextEditingController _commentController = TextEditingController();

  Future<void> submitReview() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/reviews/create-review-flutter/',
        {
          'restaurant_name': widget.restaurantName,
          'rating': _rating.toInt().toString(),
          'comment': _commentController.text,
        },
      );

      if (response['status'] == 'success') {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        _commentController.clear();
        setState(() {
          _rating = 4.0;
          fetchReviews();
        });
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan review: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<List<Review>> fetchReviews() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/reviews/get-restaurant-reviews/${Uri.encodeComponent(widget.restaurantName)}/',
      );
      
      if (response is String) {
        throw Exception('Invalid response format');
      }
      
      List<Review> reviews = [];
      for (var d in response) {
        if (d != null) {
          reviews.add(Review.fromJson(d));
        }
      }
      return reviews;
    } catch (e) {
      if (!context.mounted) return [];
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat review: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.restaurantName}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tambahkan gambar restoran di sini
            Container(
              width: double.infinity,
              height: 200, // Sesuaikan tinggi gambar
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.restaurantImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Form Review
            Text(
              'Beri Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Tulis Review Anda',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 45),
              ),
              child: Text('Submit Review'),
            ),
            
            SizedBox(height: 24),
            
            // Daftar Review
            Text(
              'Semua Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            FutureBuilder<List<Review>>(
              future: fetchReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading reviews'));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada review untuk restoran ini',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final review = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person),
                                SizedBox(width: 8),
                                Text(
                                  review.fields.user,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(
                                  review.fields.rating,
                                  (index) => Icon(Icons.star, 
                                    color: Colors.amber, 
                                    size: 16
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(review.fields.comment),
                            SizedBox(height: 4),
                            Text(
                              review.fields.createdAt.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}