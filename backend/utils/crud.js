// Shared list/get/create/update/delete logic for Destination, Hotel, Package.
const escapeRegex = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
module.exports = (Model, { searchFields = ['name'], populate = '', sorts = {}, priceField = 'price', extraFilters = () => ({}) }) => ({
  list: async (req, res) => {
    try {
      const q = req.query, f = { ...extraFilters(q) };
      if (q.search) f.$or = searchFields.map((k) => ({ [k]: new RegExp(escapeRegex(q.search), 'i') }));
      if (q.minPrice || q.maxPrice) {
        f[priceField] = {};
        if (q.minPrice) f[priceField].$gte = Number(q.minPrice);
        if (q.maxPrice) f[priceField].$lte = Number(q.maxPrice);
      }
      if (q.rating) f.rating = { $gte: Number(q.rating) };
      const sort = sorts[q.sort] || { createdAt: -1 };
      const page = Math.max(1, Number(q.page) || 1), limit = Math.min(100, Number(q.limit) || 50);
      const [items, total] = await Promise.all([
        Model.find(f).populate(populate).sort(sort).skip((page - 1) * limit).limit(limit),
        Model.countDocuments(f)
      ]);
      res.json({ items, total, page });
    } catch (e) { res.status(500).json({ message: 'Failed to fetch data' }); }
  },
  get: async (req, res) => {
    try {
      const doc = await Model.findById(req.params.id).populate(populate);
      if (!doc) return res.status(404).json({ message: 'Not found' });
      res.json(doc);
    } catch (e) { res.status(400).json({ message: 'Invalid id' }); }
  },
  create: async (req, res) => {
    try { res.status(201).json(await Model.create(req.body)); }
    catch (e) { res.status(400).json({ message: e.message }); }
  },
  update: async (req, res) => {
    try {
      const doc = await Model.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
      if (!doc) return res.status(404).json({ message: 'Not found' });
      res.json(doc);
    } catch (e) { res.status(400).json({ message: e.message }); }
  },
  remove: async (req, res) => {
    try {
      const doc = await Model.findByIdAndDelete(req.params.id);
      if (!doc) return res.status(404).json({ message: 'Not found' });
      res.json({ message: 'Deleted' });
    } catch (e) { res.status(400).json({ message: 'Invalid id' }); }
  }
});
