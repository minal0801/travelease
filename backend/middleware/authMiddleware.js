const jwt = require('jsonwebtoken');
const User = require('../models/User');
exports.protect = async (req, res, next) => {
  try {
    const h = req.headers.authorization || '';
    if (!h.startsWith('Bearer ')) return res.status(401).json({ message: 'Not authorized' });
    const { id } = jwt.verify(h.split(' ')[1], process.env.JWT_SECRET);
    const user = await User.findById(id);
    if (!user) return res.status(401).json({ message: 'User no longer exists' });
    if (user.blocked) return res.status(403).json({ message: 'Account is blocked' });
    req.user = user;
    next();
  } catch (e) { res.status(401).json({ message: 'Invalid or expired token' }); }
};
