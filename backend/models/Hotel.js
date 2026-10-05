const mongoose = require('mongoose');
module.exports = mongoose.model('Hotel', new mongoose.Schema({
  name: { type: String, required: true },
  destination: { type: mongoose.Schema.Types.ObjectId, ref: 'Destination', required: true },
  location: String,
  category: { type: String, enum: ['Budget', 'Standard', 'Luxury', 'Resort'], default: 'Standard' },
  stars: { type: Number, min: 1, max: 5, default: 3 },
  description: String,
  images: [String],
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  pricePerNight: { type: Number, required: true },
  amenities: [String],
  rooms: [{ type: { type: String }, price: Number, capacity: Number }],
  available: { type: Boolean, default: true }
}, { timestamps: true }));
