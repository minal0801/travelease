const mongoose = require('mongoose');
module.exports = mongoose.model('Destination', new mongoose.Schema({
  name: { type: String, required: true },
  country: { type: String, required: true },
  category: { type: String, enum: ['Beaches', 'Mountains', 'Cities', 'Adventure', 'Luxury', 'Cultural'], required: true },
  description: String,
  shortDescription: String,
  images: [String],
  price: { type: Number, required: true },
  rating: { type: Number, default: 0 },
  reviewCount: { type: Number, default: 0 },
  attractions: [String],
  thingsToDo: [String],
  bestTimeToVisit: String,
  travelTips: [String],
  popularity: { type: Number, default: 0 }
}, { timestamps: true }));
