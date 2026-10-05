List<String> _strs(dynamic v) => (v as List? ?? []).map((e) => e.toString()).toList();
double _d(dynamic v) => (v ?? 0).toDouble();
String _id(dynamic v) => v is Map ? (v['_id'] ?? '').toString() : (v ?? '').toString();
String _name(dynamic v) => v is Map ? (v['name'] ?? '').toString() : '';

class AppUser {
  final String id, name, email, phone, country, avatar, role;
  AppUser({required this.id, required this.name, required this.email, this.phone = '', this.country = '', this.avatar = '', this.role = 'user'});
  bool get isAdmin => role == 'admin';
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
      id: (j['id'] ?? j['_id'] ?? '').toString(), name: j['name'] ?? '', email: j['email'] ?? '',
      phone: j['phone'] ?? '', country: j['country'] ?? '', avatar: j['avatar'] ?? '', role: j['role'] ?? 'user');
}

class Destination {
  final String id, name, country, category, description, shortDescription, bestTimeToVisit;
  final List<String> images, attractions, thingsToDo, travelTips;
  final double price, rating;
  final int reviewCount;
  Destination({required this.id, required this.name, required this.country, required this.category, this.description = '', this.shortDescription = '',
    this.bestTimeToVisit = '', this.images = const [], this.attractions = const [], this.thingsToDo = const [], this.travelTips = const [],
    this.price = 0, this.rating = 0, this.reviewCount = 0});
  String get image => images.isNotEmpty ? images.first : '';
  factory Destination.fromJson(Map<String, dynamic> j) => Destination(
      id: j['_id'], name: j['name'] ?? '', country: j['country'] ?? '', category: j['category'] ?? '', description: j['description'] ?? '',
      shortDescription: j['shortDescription'] ?? '', bestTimeToVisit: j['bestTimeToVisit'] ?? '', images: _strs(j['images']),
      attractions: _strs(j['attractions']), thingsToDo: _strs(j['thingsToDo']), travelTips: _strs(j['travelTips']),
      price: _d(j['price']), rating: _d(j['rating']), reviewCount: j['reviewCount'] ?? 0);
}

class RoomType {
  final String type; final double price; final int capacity;
  RoomType(this.type, this.price, this.capacity);
}

class Hotel {
  final String id, name, location, category, description, destinationId, destinationName;
  final int stars, reviewCount;
  final double rating, pricePerNight;
  final List<String> images, amenities;
  final List<RoomType> rooms;
  final bool available;
  Hotel({required this.id, required this.name, this.location = '', this.category = '', this.description = '', this.destinationId = '', this.destinationName = '',
    this.stars = 3, this.reviewCount = 0, this.rating = 0, this.pricePerNight = 0, this.images = const [], this.amenities = const [], this.rooms = const [], this.available = true});
  String get image => images.isNotEmpty ? images.first : '';
  factory Hotel.fromJson(Map<String, dynamic> j) => Hotel(
      id: j['_id'], name: j['name'] ?? '', location: j['location'] ?? '', category: j['category'] ?? '', description: j['description'] ?? '',
      destinationId: _id(j['destination']), destinationName: _name(j['destination']), stars: j['stars'] ?? 3, reviewCount: j['reviewCount'] ?? 0,
      rating: _d(j['rating']), pricePerNight: _d(j['pricePerNight']), images: _strs(j['images']), amenities: _strs(j['amenities']),
      available: j['available'] ?? true,
      rooms: (j['rooms'] as List? ?? []).map((r) => RoomType(r['type'] ?? '', _d(r['price']), r['capacity'] ?? 2)).toList());
}

class ItineraryDay { final int day; final String title, details; ItineraryDay(this.day, this.title, this.details); }

class TravelPackage {
  final String id, name, description, destinationId, destinationName;
  final int days, nights, reviewCount;
  final double price, rating;
  final List<String> images, included, excluded;
  final List<ItineraryDay> itinerary;
  TravelPackage({required this.id, required this.name, this.description = '', this.destinationId = '', this.destinationName = '', this.days = 1, this.nights = 0,
    this.reviewCount = 0, this.price = 0, this.rating = 0, this.images = const [], this.included = const [], this.excluded = const [], this.itinerary = const []});
  String get image => images.isNotEmpty ? images.first : '';
  String get duration => '$days Days / $nights Nights';
  factory TravelPackage.fromJson(Map<String, dynamic> j) => TravelPackage(
      id: j['_id'], name: j['name'] ?? '', description: j['description'] ?? '', destinationId: _id(j['destination']), destinationName: _name(j['destination']),
      days: j['days'] ?? 1, nights: j['nights'] ?? 0, reviewCount: j['reviewCount'] ?? 0, price: _d(j['price']), rating: _d(j['rating']),
      images: _strs(j['images']), included: _strs(j['included']), excluded: _strs(j['excluded']),
      itinerary: (j['itinerary'] as List? ?? []).map((i) => ItineraryDay(i['day'] ?? 0, i['title'] ?? '', i['details'] ?? '')).toList());
}

class Booking {
  final String id, bookingId, type, itemId, itemName, destinationName, status, fullName, email, phone, userName;
  final DateTime? travelDate, returnDate, createdAt;
  final int travelers, rooms;
  final double subtotal, taxes, totalAmount;
  Booking({required this.id, required this.bookingId, required this.type, this.itemId = '', this.itemName = '', this.destinationName = '', this.status = 'Pending',
    this.fullName = '', this.email = '', this.phone = '', this.travelDate, this.returnDate, this.createdAt, this.travelers = 1, this.rooms = 1,
    this.subtotal = 0, this.taxes = 0, this.totalAmount = 0, this.userName = ''});
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
      id: j['_id'], bookingId: j['bookingId'] ?? '', type: j['type'] ?? '', itemId: _id(j['item']), itemName: j['itemName'] ?? '',
      destinationName: j['destinationName'] ?? '', status: j['status'] ?? 'Pending', fullName: j['fullName'] ?? '', email: j['email'] ?? '', phone: j['phone'] ?? '',
      travelDate: DateTime.tryParse(j['travelDate'] ?? ''), returnDate: DateTime.tryParse(j['returnDate'] ?? ''), createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
      travelers: j['travelers'] ?? 1, rooms: j['rooms'] ?? 1, subtotal: _d(j['subtotal']), taxes: _d(j['taxes']), totalAmount: _d(j['totalAmount']),
      userName: _name(j['user']));
}

class Review {
  final String id, userName, userAvatar, comment, itemName; final int rating; final DateTime? createdAt;
  Review({required this.id, required this.userName, this.userAvatar = '', required this.comment, this.itemName = '', required this.rating, this.createdAt});
  factory Review.fromJson(Map<String, dynamic> j) => Review(
      id: j['_id'], userName: _name(j['user']), userAvatar: j['user'] is Map ? (j['user']['avatar'] ?? '') : '', comment: j['comment'] ?? '',
      itemName: _name(j['item']), rating: j['rating'] ?? 0, createdAt: DateTime.tryParse(j['createdAt'] ?? ''));
}

class Favorite {
  final String id, itemType; final Map<String, dynamic> item;
  Favorite(this.id, this.itemType, this.item);
  String get itemId => item['_id'];
  String get name => item['name'] ?? '';
  String get image => (item['images'] as List? ?? []).isNotEmpty ? item['images'][0] : '';
  factory Favorite.fromJson(Map<String, dynamic> j) => Favorite(j['_id'], j['itemType'], Map<String, dynamic>.from(j['item']));
}
