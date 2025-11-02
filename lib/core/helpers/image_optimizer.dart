class ImageOptimizer {
  /// Mengoptimalkan URL Supabase Storage.
  /// Mengembalikan URL asli jika bukan URL Supabase atau jika terjadi error.
  static String getOptimizedUrl(
    String? originalUrl, {
    int width = 800, // Lebar default
    int quality = 80, // Kualitas default
  }) {
    // Kembalikan string kosong jika URL asli null atau kosong
    if (originalUrl == null || originalUrl.isEmpty) {
      return '';
    }

    // Hanya optimalkan jika ini adalah URL Supabase Storage
    if (originalUrl.contains('.supabase.co/storage/v1/object/public/')) {
      try {
        // Gunakan Uri.parse untuk menangani URL yang mungkin sudah punya query params
        final uri = Uri.parse(originalUrl);
        final queryParameters = Map<String, String>.from(uri.queryParameters);

        // Tambahkan/timpa parameter transformasi
        queryParameters['width'] = width.toString();
        queryParameters['quality'] = quality.toString();
        
        // Buat ulang Uri dengan parameter baru
        final newUri = uri.replace(queryParameters: queryParameters);
        return newUri.toString();
      } catch (e) {
        // Jika parsing gagal (URL tidak valid), kembalikan URL asli
        return originalUrl;
      }
    }

    // Jika bukan URL Supabase (misal: Avatar Google), kembalikan URL asli
    return originalUrl;
  }
}