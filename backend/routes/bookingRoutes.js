const r = require('express').Router();
const c = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');
const admin = require('../middleware/adminMiddleware');
r.post('/', protect, c.create);
r.get('/my', protect, c.my);
r.get('/', protect, admin, c.all);               // admin: all bookings
r.put('/:id/cancel', protect, c.cancel);
r.put('/:id/status', protect, admin, c.setStatus);
r.get('/:id', protect, c.get);
module.exports = r;
