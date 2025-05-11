const express = require('express');
const router = express.Router();
const db = require('../db');

router.post('/renter', (req, res) => {
  const { email, preferred_location, reward_points } = req.body;

  if (!email || !preferred_location || reward_points == null) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  const sql = `
    INSERT INTO Renter (email, preferred_location, reward_points)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE preferred_location = ?, reward_points = ?
  `;

  db.query(
    sql,
    [email, preferred_location, reward_points, preferred_location, reward_points],
    (err, result) => {
      if (err) {
        console.error('DB insert error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ message: 'Renter data saved/updated successfully' });
    }
  );
});

module.exports = router;
