const mongoose = require('mongoose');
module.exports = mongoose.model('Package', new mongoose.Schema({
  name: { type: String, required: true },
  destination: { type: mongoose.Schema.Types.ObjectId, ref: 'Destination', required: true },
  description: String,
  images: [String],
  days: { type: Number, required: true },
  nights: { type: Number, required: true },
  price: { type: Number, required: true },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  itinerary: [{ day: Number, title: String, details: String }],
  included: [String],
  excluded: [String]
}, { timestamps: true }));
