require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/database');

const app = express();
app.use(cors({ origin: process.env.CLIENT_ORIGIN === '*' ? true : process.env.CLIENT_ORIGIN }));
app.use(express.json({ limit: '2mb' }));

app.get('/api/health', (_, res) => res.json({ status: 'ok' }));
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/destinations', require('./routes/destinationRoutes'));
app.use('/api/hotels', require('./routes/hotelRoutes'));
app.use('/api/packages', require('./routes/packageRoutes'));
app.use('/api/bookings', require('./routes/bookingRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/reviews', require('./routes/reviewRoutes'));
app.use('/api/favorites', require('./routes/favoriteRoutes'));

app.use((req, res) => res.status(404).json({ message: 'Route not found' }));
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: 'Something went wrong' }); // never leak stack traces
});

connectDB().then(() => {
  const port = process.env.PORT || 5000;
  app.listen(port, () => console.log(`TravelEase API running on port ${port}`));
});
