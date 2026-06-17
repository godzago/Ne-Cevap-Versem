class ApiConstants {
  // TODO: Proxy Backend URL'nizi buraya ekleyin (Firebase Cloud Functions veya kendi Node.js sunucunuz)
  static const String baseUrl = 'https://api.necevapvereyim.com/v1';
  
  // API Endpoint'leri
  static const String generateResponseEndpoint = '/generate-response';
  
  // Zaman Aşımları (Timeouts)
  static const int connectTimeout = 15000; // 15 saniye
  static const int receiveTimeout = 15000; // 15 saniye
}
