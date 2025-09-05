class ApiConstants {
  static const String baseUrl = 'https://v6.exchangerate-api.com/v6';
  // Note: In a production app, this should be stored securely
  static const String apiKey = '8522a5a17f2e13af536be634'; // Replace with your actual API key
  
  static String getLatestRatesUrl(String baseCurrency) {
    return '$baseUrl/$apiKey/latest/$baseCurrency';
  }
  
  static String getPairConversionUrl(String fromCurrency, String toCurrency, double amount) {
    return '$baseUrl/$apiKey/pair/$fromCurrency/$toCurrency/$amount';
  }
}
