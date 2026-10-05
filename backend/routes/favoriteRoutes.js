const r = require('express').Router();
const c = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');
r.get('/', protect, c.getFavorites);
r.post('/', protect, c.addFavorite);
r.delete('/:id', protect, c.removeFavorite);
module.exports = r;
