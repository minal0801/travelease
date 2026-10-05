const Destination = require('../models/Destination');
module.exports = require('../utils/crud')(Destination, {
  searchFields: ['name', 'country', 'description'],
  sorts: { popular: { popularity: -1 }, priceLow: { price: 1 }, priceHigh: { price: -1 }, rating: { rating: -1 } },
  extraFilters: (q) => {
    const f = {};
    if (q.country) f.country = q.country;
    if (q.category) f.category = q.category;
    return f;
  }
});
