import 'package:classmate/config/app_config.dart';

class ImageHelper {
  /// Constructs a full image URL by prepending the image server URL
  /// to relative paths. Returns the URL as-is if it's already absolute.
  static String getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    
    // If the URL already contains a protocol, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Otherwise, prepend the image server URL
    return '${AppConfig.imageServer}$imageUrl';
  }

  /// Constructs a full image URL with a custom fallback
  static String getFullImageUrlWithFallback(String? imageUrl, String fallbackUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return fallbackUrl;
    }
    
    // If the URL already contains a protocol, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Otherwise, prepend the image server URL
    return '${AppConfig.imageServer}$imageUrl';
  }
}
