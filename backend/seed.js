require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Destination = require('./models/Destination');
const Hotel = require('./models/Hotel');
const Package = require('./models/Package');
const Booking = require('./models/Booking');
const Review = require('./models/Review');

const img = (id) => `https://images.unsplash.com/${id}?auto=format&fit=crop&w=1400&q=80`;
const D = (name, country, category, price, rating, pop, photo, short, attractions, todo, best, tips) => ({
  name, country, category, price, rating, popularity: pop, shortDescription: short,
  description: `${short} ${name} is one of the most loved destinations for travellers, offering memorable experiences, warm hospitality and unforgettable scenery.`,
  images: photo.map(img), attractions, thingsToDo: todo, bestTimeToVisit: best, travelTips: tips
});

const destinations = [
  D('Goa', 'India', 'Beaches', 8999, 4.7, 98, ['photo-1512343879784-a960bf40e7f2', 'photo-1507525428034-b723cf961d3e'], 'Sun, sand and vibrant nightlife on India\'s western coast.', ['Baga Beach', 'Fort Aguada', 'Basilica of Bom Jesus'], ['Water sports', 'Beach shacks', 'Old Goa heritage walk'], 'November to February', ['Rent a scooter for local travel', 'Book beach-side stays early in December']),
  D('Manali', 'India', 'Mountains', 7499, 4.6, 90, ['photo-1626621341517-bbf3d9990a23', 'photo-1506905925346-21bda4d32df4'], 'Snow-capped peaks, pine forests and adventure in Himachal Pradesh.', ['Solang Valley', 'Rohtang Pass', 'Hadimba Temple'], ['Skiing', 'Paragliding', 'River rafting'], 'March to June, December to February', ['Carry warm clothes', 'Rohtang Pass needs a permit']),
  D('Kashmir', 'India', 'Mountains', 12999, 4.9, 92, ['photo-1595815771614-ade9d652a65d', 'photo-1506905925346-21bda4d32df4'], 'Paradise on earth with houseboats, gardens and Himalayan views.', ['Dal Lake', 'Gulmarg', 'Pahalgam'], ['Shikara ride', 'Gondola ride', 'Mughal gardens tour'], 'April to October', ['Try local Wazwan cuisine', 'Check local advisories before travel']),
  D('Jaipur', 'India', 'Cultural', 6999, 4.5, 85, ['photo-1477587458883-47145ed94245', 'photo-1599661046289-e31897846e41'], 'The Pink City of palaces, forts and royal heritage.', ['Amber Fort', 'Hawa Mahal', 'City Palace'], ['Fort tours', 'Bazaar shopping', 'Elephant-free village visits'], 'October to March', ['Bargain in local markets', 'Start sightseeing early to avoid heat']),
  D('Bali', 'Indonesia', 'Beaches', 34999, 4.8, 95, ['photo-1537996194471-e657df975ab4', 'photo-1518548419970-58e3b4079ab2'], 'Tropical island of temples, rice terraces and surf beaches.', ['Uluwatu Temple', 'Ubud Monkey Forest', 'Tegallalang Rice Terraces'], ['Surfing', 'Temple visits', 'Spa and wellness'], 'April to October', ['Rent a scooter carefully', 'Dress modestly at temples']),
  D('Dubai', 'UAE', 'Luxury', 45999, 4.7, 96, ['photo-1512453979798-5ea266f8880c', 'photo-1518684079-3c830dcef090'], 'Futuristic skyline, luxury shopping and desert adventures.', ['Burj Khalifa', 'Palm Jumeirah', 'Dubai Mall'], ['Desert safari', 'Skyscraper visits', 'Luxury shopping'], 'November to March', ['Summers are extremely hot', 'Metro is the cheapest way to travel']),
  D('Paris', 'France', 'Cities', 79999, 4.8, 97, ['photo-1502602898657-3e91760cbb34', 'photo-1499856871958-5b9627545d1a'], 'The city of love, art, fashion and iconic landmarks.', ['Eiffel Tower', 'Louvre Museum', 'Notre-Dame'], ['Seine river cruise', 'Museum hopping', 'Cafe culture'], 'April to June, September to October', ['Buy a museum pass', 'Beware of pickpockets near tourist spots']),
  D('Singapore', 'Singapore', 'Cities', 52999, 4.7, 88, ['photo-1525625293386-3f8f99389edd', 'photo-1565967511849-76a60a516170'], 'A clean, green city-state blending cultures, food and technology.', ['Marina Bay Sands', 'Gardens by the Bay', 'Sentosa'], ['Night safari', 'Hawker centre food trail', 'Sentosa beaches'], 'February to April', ['Use the MRT', 'Carry an umbrella year-round']),
  D('Leh Ladakh', 'India', 'Adventure', 16999, 4.8, 89, ['photo-1581793745862-99fde7fa73d2', 'photo-1506905925346-21bda4d32df4'], 'High-altitude desert, monasteries and legendary road trips.', ['Pangong Lake', 'Nubra Valley', 'Khardung La'], ['Bike trips', 'Monastery visits', 'Camping'], 'May to September', ['Acclimatise for 2 days on arrival', 'Carry cash - ATMs are unreliable']),
  D('Udaipur', 'India', 'Luxury', 9999, 4.6, 82, ['photo-1595658658481-d53d3f999875', 'photo-1477587458883-47145ed94245'], 'The City of Lakes with grand palaces and romantic sunsets.', ['City Palace', 'Lake Pichola', 'Jag Mandir'], ['Boat ride', 'Palace tours', 'Rooftop dining'], 'September to March', ['Book lake-view rooms in advance', 'Try the local Rajasthani thali'])
];

const room = (type, price, capacity) => ({ type, price, capacity });
const hotelDefs = [
  ['Taj Fort Aguada Resort', 'Goa', 'Candolim, Goa', 'Resort', 5, 12500, 4.7, ['WiFi', 'Pool', 'Spa', 'Breakfast', 'Beach Access']],
  ['Baga Beach Inn', 'Goa', 'Baga, Goa', 'Budget', 3, 3200, 4.1, ['WiFi', 'Breakfast', 'AC']],
  ['Snow Valley Resorts', 'Manali', 'Old Manali', 'Standard', 4, 5500, 4.4, ['WiFi', 'Heater', 'Breakfast', 'Mountain View']],
  ['Houseboat Nageen', 'Kashmir', 'Dal Lake, Srinagar', 'Luxury', 4, 7800, 4.8, ['WiFi', 'Breakfast', 'Lake View', 'Shikara Ride']],
  ['Rambagh Palace', 'Jaipur', 'Bhawani Singh Road, Jaipur', 'Luxury', 5, 24000, 4.9, ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Airport Pickup']],
  ['Ubud Jungle Villa', 'Bali', 'Ubud, Bali', 'Resort', 5, 9800, 4.8, ['WiFi', 'Pool', 'Spa', 'Breakfast']],
  ['Burj View Hotel', 'Dubai', 'Downtown Dubai', 'Luxury', 5, 18500, 4.7, ['WiFi', 'Pool', 'Gym', 'Restaurant', 'Airport Pickup']],
  ['Le Petit Paris', 'Paris', 'Latin Quarter, Paris', 'Standard', 4, 15500, 4.5, ['WiFi', 'Breakfast', 'AC']],
  ['Marina Bay Suites', 'Singapore', 'Marina Bay', 'Luxury', 5, 21000, 4.8, ['WiFi', 'Pool', 'Gym', 'Spa', 'Restaurant']],
  ['Lake Pichola Haveli', 'Udaipur', 'Lake Pichola, Udaipur', 'Luxury', 4, 8900, 4.6, ['WiFi', 'Lake View', 'Breakfast', 'Restaurant'] ]
];

const pkgDefs = [
  ['Goa Escape', 'Goa', 4, 12999, 4.8, 'Sun-soaked beaches, water sports and vibrant nightlife.'],
  ['Manali Snow Adventure', 'Manali', 5, 14999, 4.6, 'Snow, mountains and thrilling adventure activities.'],
  ['Kashmir Paradise', 'Kashmir', 6, 24999, 4.9, 'Houseboat stay, Gulmarg gondola and Mughal gardens.'],
  ['Royal Rajasthan - Jaipur', 'Jaipur', 4, 11999, 4.5, 'Forts, palaces and bazaars of the Pink City.'],
  ['Bali Bliss', 'Bali', 6, 54999, 4.8, 'Temples, beaches, rice terraces and spa retreats.'],
  ['Dubai Delight', 'Dubai', 5, 62999, 4.7, 'Skyline, desert safari and luxury shopping.'],
  ['Paris Romance', 'Paris', 6, 129999, 4.8, 'Eiffel Tower, Seine cruise and museum trails.'],
  ['Ladakh Road Trip', 'Leh Ladakh', 7, 32999, 4.8, 'Pangong, Nubra and high-altitude passes.']
];

(async () => {
  await mongoose.connect(process.env.MONGO_URI);
  await Promise.all([User, Destination, Hotel, Package, Booking, Review].map((m) => m.deleteMany({})));

  const admin = await User.create({ name: 'Admin', email: 'admin@travelease.com', password: 'Admin@123', role: 'admin', phone: '9999999999' });
  const users = await User.create([
    { name: 'Aarav Patel', email: 'aarav@example.com', password: 'User@123', phone: '9876543210' },
    { name: 'Priya Sharma', email: 'priya@example.com', password: 'User@123', phone: '9876500011' },
    { name: 'Rohan Mehta', email: 'rohan@example.com', password: 'User@123', phone: '9876500022' }
  ]);

  const dests = await Destination.create(destinations);
  const byName = Object.fromEntries(dests.map((d) => [d.name, d]));

  const hotels = await Hotel.create(hotelDefs.map(([name, dest, location, category, stars, price, rating, amenities]) => ({
    name, destination: byName[dest]._id, location, category, stars, pricePerNight: price, rating, amenities,
    description: `${name} offers a comfortable and memorable stay in ${location}, with excellent service and great amenities.`,
    images: byName[dest].images,
    rooms: [room('Standard', price, 2), room('Deluxe', Math.round(price * 1.4), 3), room('Suite', Math.round(price * 2), 4)],
    available: true
  })));

  const packages = await Package.create(pkgDefs.map(([name, dest, days, price, rating, desc]) => ({
    name, destination: byName[dest]._id, days, nights: days - 1, price, rating, description: desc, images: byName[dest].images,
    itinerary: [
      { day: 1, title: 'Arrival and hotel check-in', details: `Arrive in ${dest}, transfer to hotel and relax.` },
      { day: 2, title: 'Local sightseeing', details: `Visit the top attractions of ${dest} with a local guide.` },
      { day: 3, title: 'Adventure and leisure', details: 'Enjoy signature activities and free time for shopping.' },
      { day: days, title: 'Departure', details: 'Breakfast, check-out and transfer to the airport/station.' }
    ].filter((v, i, a) => a.findIndex((x) => x.day === v.day) === i),
    included: ['Hotel accommodation', 'Daily breakfast', 'Airport/station transfers', 'Sightseeing'],
    excluded: ['Personal expenses', 'Flights', 'Travel insurance']
  })));

  const comments = [
    ['Destination', 'Goa', 5, 'Amazing beaches and great food. Perfect for a friends trip!'],
    ['Destination', 'Manali', 4, 'Beautiful snow views. Roads can be crowded in peak season.'],
    ['Destination', 'Kashmir', 5, 'Truly heaven on earth. The houseboat was unforgettable.'],
    ['Destination', 'Jaipur', 4, 'Rich culture and stunning forts. Carry sunscreen!'],
    ['Destination', 'Bali', 5, 'Loved the temples and rice terraces. Very relaxing.'],
    ['Destination', 'Paris', 5, 'Magical city, the Eiffel Tower at night is a must.'],
    ['Hotel', 'Taj Fort Aguada Resort', 5, 'Superb service and a beautiful sea-facing room.'],
    ['Hotel', 'Rambagh Palace', 5, 'Felt like royalty. Worth every rupee.'],
    ['Package', 'Goa Escape', 5, 'Well organised trip, hotel and transfers were on time.'],
    ['Package', 'Kashmir Paradise', 5, 'Great itinerary and a very friendly driver-guide.']
  ];
  const find = (type, name) => (type === 'Destination' ? byName[name] : type === 'Hotel' ? hotels.find((h) => h.name === name) : packages.find((p) => p.name === name));
  await Review.create(comments.map(([type, name, rating, comment], i) => ({ user: users[i % users.length]._id, itemType: type, item: find(type, name)._id, rating, comment })));

  const pk = packages[0];
  await Booking.create({
    bookingId: 'TESEED001', user: users[0]._id, type: 'Package', item: pk._id, destinationName: 'Goa', itemName: pk.name,
    travelDate: new Date(Date.now() + 20 * 864e5), returnDate: new Date(Date.now() + 23 * 864e5), travelers: 2, rooms: 1,
    fullName: users[0].name, email: users[0].email, phone: users[0].phone, subtotal: pk.price * 2, taxes: Math.round(pk.price * 0.2), totalAmount: pk.price * 2 + Math.round(pk.price * 0.2), status: 'Confirmed'
  });

  console.log(`Seeded: ${dests.length} destinations, ${hotels.length} hotels, ${packages.length} packages, ${comments.length} reviews`);
  console.log('Admin login -> admin@travelease.com / Admin@123');
  console.log('User login  -> aarav@example.com / User@123');
  await mongoose.disconnect();
})().catch((e) => { console.error(e); process.exit(1); });
