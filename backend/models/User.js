const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const userSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String, default: '' },
  country: { type: String, default: 'India' },
  avatar: { type: String, default: '' },
  password: { type: String, required: true, minlength: 6, select: false },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  blocked: { type: Boolean, default: false },
  favorites: [{
    item: { type: mongoose.Schema.Types.ObjectId, refPath: 'favorites.itemType' },
    itemType: { type: String, enum: ['Destination', 'Hotel', 'Package'] }
  }]
}, { timestamps: true });
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});
userSchema.methods.matchPassword = function (p) { return bcrypt.compare(p, this.password); };
module.exports = mongoose.model('User', userSchema);
