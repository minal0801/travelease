const User = require('../models/User');
const Destination = require('../models/Destination');
const Hotel = require('../models/Hotel');
const Package = require('../models/Package');
const Booking = require('../models/Booking');
const Review = require('../models/Review');
const { out } = require('./authController');
const models = { Destination, Hotel, Package };

exports.getProfile = (req, res) => res.json(out(req.user));

exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, country, avatar, currentPassword, newPassword } = req.body;
    const user = await User.findById(req.user._id).select('+password');
    if (name) user.name = name;
    if (phone !== undefined) user.phone = phone;
    if (country !== undefined) user.country = country;
    if (avatar !== undefined) user.avatar = avatar;
    if (newPassword) {
      if (newPassword.length < 6) return res.status(400).json({ message: 'New password must be at least 6 characters' });
      if (!currentPassword || !(await user.matchPassword(currentPassword)))
        return res.status(400).json({ message: 'Current password is incorrect' });
      user.password = newPassword;
    }
    await user.save();
    res.json(out(user));
  } catch (e) { res.status(400).json({ message: e.message }); }
};

// ---- Favorites ----
exports.getFavorites = async (req, res) => {
  const user = await User.findById(req.user._id).populate('favorites.item');
  res.json(user.favorites.filter((f) => f.item).map((f) => ({ _id: f._id, itemType: f.itemType, item: f.item })));
};
exports.addFavorite = async (req, res) => {
  try {
    const { itemId, itemType } = req.body;
    if (!models[itemType]) return res.status(400).json({ message: 'Invalid item type' });
    if (!(await models[itemType].exists({ _id: itemId }))) return res.status(404).json({ message: 'Item not found' });
    const user = await User.findById(req.user._id);
    if (user.favorites.some((f) => String(f.item) === String(itemId))) return res.status(409).json({ message: 'Already in favorites' });
    user.favorites.push({ item: itemId, itemType });
    await user.save();
    res.status(201).json({ message: 'Added to favorites' });
  } catch (e) { res.status(400).json({ message: 'Could not add favorite' }); }
};
// :id may be the favorite entry id OR the item id
exports.removeFavorite = async (req, res) => {
  const user = await User.findById(req.user._id);
  const before = user.favorites.length;
  user.favorites = user.favorites.filter((f) => String(f._id) !== req.params.id && String(f.item) !== req.params.id);
  if (user.favorites.length === before) return res.status(404).json({ message: 'Favorite not found' });
  await user.save();
  res.json({ message: 'Removed from favorites' });
};

// ---- Admin ----
exports.listUsers = async (req, res) => {
  const f = {};
  if (req.query.search) {
    const r = new RegExp(req.query.search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    f.$or = [{ name: r }, { email: r }];
  }
  res.json(await User.find(f).sort({ createdAt: -1 }));
};
exports.getUser = async (req, res) => {
  const u = await User.findById(req.params.id);
  if (!u) return res.status(404).json({ message: 'User not found' });
  const bookings = await Booking.find({ user: u._id }).sort({ createdAt: -1 });
  res.json({ user: out(u), blocked: u.blocked, createdAt: u.createdAt, bookings });
};
exports.toggleBlock = async (req, res) => {
  const u = await User.findById(req.params.id);
  if (!u) return res.status(404).json({ message: 'User not found' });
  if (u.role === 'admin') return res.status(400).json({ message: 'Cannot block an admin' });
  u.blocked = !u.blocked;
  await u.save();
  res.json({ blocked: u.blocked });
};
exports.stats = async (req, res) => {
  const [users, destinations, hotels, packages, bookings, revenueAgg, byStatus, monthly] = await Promise.all([
    User.countDocuments(), Destination.countDocuments(), Hotel.countDocuments(), Package.countDocuments(), Booking.countDocuments(),
    Booking.aggregate([{ $match: { status: { $ne: 'Cancelled' } } }, { $group: { _id: null, total: { $sum: '$totalAmount' } } }]),
    Booking.aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]),
    Booking.aggregate([
      { $match: { status: { $ne: 'Cancelled' } } },
      { $group: { _id: { $dateToString: { format: '%Y-%m', date: '$createdAt' } }, revenue: { $sum: '$totalAmount' }, count: { $sum: 1 } } },
      { $sort: { _id: 1 } }, { $limit: 12 }
    ])
  ]);
  res.json({ users, destinations, hotels, packages, bookings, revenue: revenueAgg[0]?.total || 0, byStatus, monthly });
};
// admin review list / delete
exports.listReviews = async (req, res) =>
  res.json(await Review.find().populate('user', 'name email').populate('item', 'name').sort({ createdAt: -1 }));
exports.deleteReview = async (req, res) => {
  const r = await Review.findByIdAndDelete(req.params.id);
  if (!r) return res.status(404).json({ message: 'Review not found' });
  await require('./reviewController').recalc(r.itemType, r.item);
  res.json({ message: 'Deleted' });
};
