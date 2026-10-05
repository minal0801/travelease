const Hotel = require('../models/Hotel');
module.exports = require('../utils/crud')(Hotel, {
  searchFields: ['name', 'location'],
  populate: 'destination',
  priceField: 'pricePerNight',
  sorts: { priceLow: { pricePerNight: 1 }, priceHigh: { pricePerNight: -1 }, rating: { rating: -1 } },
  extraFilters: (q) => {
    const f = {};
    if (q.destination) f.destination = q.destination;
    if (q.category) f.category = q.category;
    if (q.location) f.location = new RegExp(q.location.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');
    if (q.amenities) f.amenities = { $all: q.amenities.split(',') };
    return f;
  }
});
