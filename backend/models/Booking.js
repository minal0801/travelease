const mongoose = require('mongoose');
module.exports = mongoose.model('Booking', new mongoose.Schema({
  bookingId: { type: String, unique: true },
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type: { type: String, enum: ['Hotel', 'Package'], required: true },
  item: { type: mongoose.Schema.Types.ObjectId, refPath: 'type', required: true },
  destinationName: String,
  itemName: String,
  travelDate: { type: Date, required: true },
  returnDate: Date,
  travelers: { type: Number, default: 1, min: 1 },
  rooms: { type: Number, default: 1, min: 1 },
  fullName: String, email: String, phone: String,
  subtotal: Number, taxes: Number, totalAmount: Number,
  status: { type: String, enum: ['Pending', 'Confirmed', 'Cancelled', 'Completed'], default: 'Confirmed' }
}, { timestamps: true }));
