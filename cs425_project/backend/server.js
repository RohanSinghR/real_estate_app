const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/auth');
const cardRoutes = require('./routes/cards');
const propertyRoutes = require('./routes/properties');
const bookingRoutes = require('./routes/booking');
const renterRoutes = require('./routes/renter');
const app = express();
app.get('/', (req, res) => {
  res.send('Backend is running successfully on Render!');
});
app.use(cors());
app.use(bodyParser.json());
app.use('/api', authRoutes);
app.use('/api', cardRoutes);
app.use('/api', propertyRoutes);
app.use('/api',bookingRoutes);
app.use('/api', renterRoutes);
app.listen(3000, () => {
  console.log('Backend running at http://localhost:3000');
});