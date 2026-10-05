class AppConfig {
  // Override at build time: flutter run -d chrome --dart-define=API_URL=https://your-api/api
  static const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5000/api');
}
const categories = ['Beaches', 'Mountains', 'Cities', 'Adventure', 'Luxury', 'Cultural'];
const hotelCategories = ['Budget', 'Standard', 'Luxury', 'Resort'];
const amenityOptions = ['WiFi', 'Pool', 'Spa', 'Breakfast', 'Gym', 'Restaurant', 'AC', 'Airport Pickup'];
const placeholderImage = 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=1400&q=80';
