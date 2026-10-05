const jwt = require('jsonwebtoken');
const User = require('../models/User');
const sign = (id) => jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES || '7d' });
const emailRe = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const out = (u) => ({ id: u._id, name: u.name, email: u.email, phone: u.phone, country: u.country, avatar: u.avatar, role: u.role });

exports.register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    if (!name || !email || !password) return res.status(400).json({ message: 'Name, email and password are required' });
    if (!emailRe.test(email)) return res.status(400).json({ message: 'Invalid email' });
    if (password.length < 6) return res.status(400).json({ message: 'Password must be at least 6 characters' });
    if (await User.findOne({ email: email.toLowerCase() })) return res.status(409).json({ message: 'Email already registered' });
    const user = await User.create({ name, email, phone, password }); // role is never taken from the request
    res.status(201).json({ token: sign(user._id), user: out(user) });
  } catch (e) { res.status(500).json({ message: 'Registration failed' }); }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'Email and password are required' });
    const user = await User.findOne({ email: String(email).toLowerCase() }).select('+password');
    if (!user || !(await user.matchPassword(password))) return res.status(401).json({ message: 'Invalid email or password' });
    if (user.blocked) return res.status(403).json({ message: 'Account is blocked' });
    res.json({ token: sign(user._id), user: out(user) });
  } catch (e) { res.status(500).json({ message: 'Login failed' }); }
};
exports.out = out;
