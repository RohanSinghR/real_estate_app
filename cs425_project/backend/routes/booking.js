const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const router = express.Router();

router.use(bodyParser.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'your_user',
  password: 'your_password',
  database: 'your_database'
});

router.post('/api/book', (req, res) => {
  const {
    email,
    property_id,
    card_number,
    payment_method,
    date
  } = req.body;

  const query = `
    INSERT INTO Booking (payment_method, date, property_id, email, card_number)
    VALUES (?, ?, ?, ?, ?)
  `;

  db.execute(query, [payment_method, date, property_id, email, card_number], (err, results) => {
    if (err) {
      console.error('Booking insert error:', err);
      return res.status(500).json({ message: 'Failed to insert booking' });
    }
    res.status(200).json({ message: 'Booking added successfully' });
  });
});

router.get('/api/bookings', (req, res) => {
  const email = req.query.email;
  if (!email) return res.status(400).json({ message: 'Email is required' });

  const query = `
    SELECT b.*, p.city, p.state, p.description, p.price, p.availability
    FROM Booking b
    JOIN property p ON b.property_id = p.property_id
    WHERE b.email = ?
  `;

  db.execute(query, [email], (err, results) => {
    if (err) {
      console.error('Error fetching bookings:', err);
      return res.status(500).json({ message: 'Failed to fetch bookings' });
    }
    res.status(200).json(results);
  });
});

module.exports = router;
