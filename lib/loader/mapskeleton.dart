import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class MapSkeletonLoader extends StatelessWidget {
  const MapSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(seconds: 2), // Make the shimmer animation slower
      child: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            // Fake app bar
            Container(
              height: 56,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Stack(
                children: [
                  // Fake map background
                  Container(color: Colors.grey[100]),
                  // Fake map elements
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: 200,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                  // Fake markers
                  Positioned(
                    top: 50,
                    left: 50,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 50,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 150,
                    left: 100,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
