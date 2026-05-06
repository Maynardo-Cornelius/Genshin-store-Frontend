class ImageHelper {
  static String? getImageUrl(String? image) {
    if (image == null) return null;
    if (image.startsWith('http')) return image;
    return 'http://10.0.2.2:3000/uploads/$image';
  }
}