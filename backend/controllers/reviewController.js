const Review = require('../models/Review');
const models = { Destination: require('../models/Destination'), Hotel: require('../models/Hotel'), Package: require('../models/Package') };

const recalc = async (itemType, item) => {
  const [agg] = await Review.aggregate([
    { $match: { itemType, item: new (require('mongoose').Types.ObjectId)(String(item)) } },
    { $group: { _id: null, avg: { $avg: '$rating' }, n: { $sum: 1 } } }
  ]);
  await models[itemType].findByIdAndUpdate(item, { rating: agg ? Math.round(agg.avg * 10) / 10 : 0, reviewCount: agg ? agg.n : 0 });
};
exports.recalc = recalc;

exports.create = async (req, res) => {
  try {
    const { itemId, itemType, rating, comment } = req.body;
    if (!models[itemType]) return res.status(400).json({ message: 'Invalid item type' });
    if (!rating || rating < 1 || rating > 5) return res.status(400).json({ message: 'Rating must be 1-5' });
    if (!comment || !comment.trim()) return res.status(400).json({ message: 'Comment is required' });
    if (!(await models[itemType].exists({ _id: itemId }))) return res.status(404).json({ message: 'Item not found' });
    const review = await Review.create({ user: req.user._id, itemType, item: itemId, rating, comment: comment.trim() });
    await recalc(itemType, itemId);
    res.status(201).json(await review.populate('user', 'name avatar'));
  } catch (e) { res.status(400).json({ message: e.message }); }
};
exports.forItem = async (req, res) => {
  try {
    res.json(await Review.find({ item: req.params.itemId }).populate('user', 'name avatar').sort({ createdAt: -1 }));
  } catch (e) { res.status(400).json({ message: 'Invalid id' }); }
};
// homepage testimonials
exports.latest = async (req, res) =>
  res.json(await Review.find().populate('user', 'name avatar').populate('item', 'name').sort({ rating: -1, createdAt: -1 }).limit(6));
