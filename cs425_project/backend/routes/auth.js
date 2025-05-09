const express = require('express');
const db = require('../db');
const router = express.Router();
router.get('/signup', (req, res) => {
  res.send('Signup endpoint is working. Use POST instead.');
});

router.post('/signup', (req, res) => {
  const {
    email,
    address,
    user_type,
    job_title,
    agency,
    contact_info,
    preferred_location,
    reward_points = 0,
    credit_card_number,
    credit_card_cvv,
    credit_card_expiry,
    credit_card_billing_address
  } = req.body;
  db.query(
    'INSERT INTO Users (email, address) VALUES (?, ?)',
    [email, address],
    (err, result) => {
      if (err) return res.status(500).json({ error: 'User insertion failed', details: err });
      db.query(
        'INSERT INTO Credit_Card (card_number, cvv, billing_address, expiry_date, email) VALUES (?, ?, ?, ?, ?)',
        [credit_card_number, credit_card_cvv, credit_card_billing_address, credit_card_expiry, email],
        (err2) => {
          if (err2) return res.status(500).json({ error: 'Credit card insertion failed', details: err2 });

          if (user_type === 'Agent') {
            db.query(
              'INSERT INTO Agent (phone_num, Job_role, Agency, email) VALUES (?, ?, ?, ?)',
              [contact_info, job_title, agency, email],
              (err3) => {
                if (err3) return res.status(500).json({ error: 'Agent insertion failed', details: err3 });
                return res.status(200).json({ message: 'Agent registered successfully' });
              }
            );
          } else {
            db.query(
              'INSERT INTO Renter (renter_details, preferred_location, reward_points, email) VALUES (?, ?, ?, ?)',
              [contact_info, preferred_location, reward_points, email],
              (err4) => {
                if (err4) return res.status(500).json({ error: 'Renter insertion failed', details: err4 });
                return res.status(200).json({ message: 'Renter registered successfully' });
              }
            );
          }
        }
      );
    }
  );
});

router.post('/login', (req, res) => {
  const { email } = req.body;

  db.query(
    'SELECT * FROM Users WHERE email = ?',
    [email],
    (err, results) => {
      if (err) return res.status(500).json({ error: 'Login query failed', details: err });

      if (results.length === 0) {
        return res.status(401).json({ message: 'No account associated with this email' });
      }

      return res.status(200).json({ message: 'Login successful', user: results[0] });
    }
  );
});

module.exports = router;
