const Booking = require('../models/Booking');
const Hotel = require('../models/Hotel');
const Package = require('../models/Package');
const TAX_RATE = 0.10;
const genId = () => 'TE' + Date.now().toString(36).toUpperCase() + Math.random().toString(36).slice(2, 5).toUpperCase();

exports.create = async (req, res) => {
  try {
    const { type, itemId, travelDate, returnDate, travelers = 1, rooms = 1, fullName, email, phone } = req.body;
    if (!['Hotel', 'Package'].includes(type)) return res.status(400).json({ message: 'Type must be Hotel or Package' });
    if (!travelDate || isNaN(new Date(travelDate))) return res.status(400).json({ message: 'Valid travel date is required' });
    if (new Date(travelDate) < new Date(new Date().toDateString())) return res.status(400).json({ message: 'Travel date cannot be in the past' });
    if (returnDate && new Date(returnDate) <= new Date(travelDate)) return res.status(400).json({ message: 'Return date must be after travel date' });
    if (!fullName || !email || !phone) return res.status(400).json({ message: 'Name, email and phone are required' });
    const t = Math.max(1, Number(travelers)), r = Math.max(1, Number(rooms));

    let item, subtotal, destName;
    if (type === 'Package') {
      item = await Package.findById(itemId).populate('destination', 'name');
      if (!item) return res.status(404).json({ message: 'Package not found' });
      subtotal = item.price * t; // price is per traveler — computed server-side, never trusted from client
    } else {
      item = await Hotel.findById(itemId).populate('destination', 'name');
      if (!item) return res.status(404).json({ message: 'Hotel not found' });
      if (!item.available) return res.status(400).json({ message: 'Hotel is not available' });
      if (!returnDate) return res.status(400).json({ message: 'Check-out date is required for hotels' });
      const nights = Math.max(1, Math.round((new Date(returnDate) - new Date(travelDate)) / 86400000));
      subtotal = item.pricePerNight * nights * r;
    }
    destName = item.destination?.name || '';
    const taxes = Math.round(subtotal * TAX_RATE);
    const booking = await Booking.create({
      bookingId: genId(), user: req.user._id, type, item: item._id, destinationName: destName, itemName: item.name,
      travelDate, returnDate, travelers: t, rooms: r, fullName, email, phone, subtotal, taxes, totalAmount: subtotal + taxes, status: 'Confirmed'
    });
    res.status(201).json(booking);
  } catch (e) { res.status(400).json({ message: e.message }); }
};

exports.my = async (req, res) => {
  const list = await Booking.find({ user: req.user._id }).sort({ createdAt: -1 });
  const today = new Date();
  // auto-mark past confirmed trips as completed
  for (const b of list) {
    if (b.status === 'Confirmed' && (b.returnDate || b.travelDate) < today) { b.status = 'Completed'; await b.save(); }
  }
  res.json(list);
};

exports.get = async (req, res) => {
  try {
    const b = await Booking.findById(req.params.id);
    if (!b) return res.status(404).json({ message: 'Booking not found' });
    if (String(b.user) !== String(req.user._id) && req.user.role !== 'admin') return res.status(403).json({ message: 'Forbidden' });
    res.json(b);
  } catch (e) { res.status(400).json({ message: 'Invalid id' }); }
};

exports.cancel = async (req, res) => {
  try {
    const b = await Booking.findById(req.params.id);
    if (!b) return res.status(404).json({ message: 'Booking not found' });
    if (String(b.user) !== String(req.user._id) && req.user.role !== 'admin') return res.status(403).json({ message: 'Forbidden' });
    if (['Cancelled', 'Completed'].includes(b.status)) return res.status(400).json({ message: `Booking already ${b.status.toLowerCase()}` });
    b.status = 'Cancelled';
    await b.save();
    res.json(b);
  } catch (e) { res.status(400).json({ message: 'Invalid id' }); }
};

// ---- Admin ----
exports.all = async (req, res) => {
  const f = {};
  if (req.query.status) f.status = req.query.status;
  if (req.query.search) {
    const r = new RegExp(req.query.search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    f.$or = [{ bookingId: r }, { fullName: r }, { itemName: r }, { email: r }];
  }
  res.json(await Booking.find(f).populate('user', 'name email').sort({ createdAt: -1 }));
};
exports.setStatus = async (req, res) => {
  const { status } = req.body;
  if (!['Pending', 'Confirmed', 'Cancelled', 'Completed'].includes(status)) return res.status(400).json({ message: 'Invalid status' });
  const b = await Booking.findByIdAndUpdate(req.params.id, { status }, { new: true });
  if (!b) return res.status(404).json({ message: 'Booking not found' });
  res.json(b);
};
