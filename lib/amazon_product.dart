import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AmazonProduct extends StatelessWidget {
  final String productLink;
  final String imageSrc;

  AmazonProduct({required this.productLink, required this.imageSrc});

  void _launchURL() async {
    if (await canLaunchUrl(_productUri())) {
      await launchUrl(_productUri());
    } else {
      throw 'Could not launch $productLink';
    }
  }

  Uri _productUri() => Uri.parse(productLink);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Image.network(imageSrc),
    );
  }
}
