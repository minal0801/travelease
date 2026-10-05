const Package = require('../models/Package');
module.exports = require('../utils/crud')(Package, {
  searchFields: ['name', 'description'],
  populate: 'destination',
  sorts: { priceLow: { price: 1 }, priceHigh: { price: -1 }, rating: { rating: -1 } },
  extraFilters: (q) => {
    const f = {};
    if (q.destination) f.destination = q.destination;
    if (q.days) f.days = Number(q.days);
    return f;
  }
});
