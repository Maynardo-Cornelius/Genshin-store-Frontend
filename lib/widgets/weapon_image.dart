import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/image_helper.dart';

class WeaponImage extends StatelessWidget {
  final String? image;
  final double? width;
  final double? height;
  final BoxFit fit;

  const WeaponImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) return _placeholder();

    final url = ImageHelper.getImageUrl(image);
    if (url == null) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.white10,
      child: const Icon(Icons.shield, color: Colors.white24, size: 40),
    );
  }
}