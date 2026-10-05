const mongoose = require('mongoose');
module.exports = mongoose.model('Review', new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  itemType: { type: String, enum: ['Destination', 'Hotel', 'Package'], required: true },
  item: { type: mongoose.Schema.Types.ObjectId, refPath: 'itemType', required: true },
  rating: { type: Number, min: 1, max: 5, required: true },
  comment: { type: String, required: true, maxlength: 1000 }
}, { timestamps: true }));
