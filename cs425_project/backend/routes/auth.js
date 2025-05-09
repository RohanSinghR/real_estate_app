const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/signup', (req, res) => {
  res.send('Signup endpoint is working. Use POST instead.');
});

router.post('/signup', (req, res) => {
  const {
    name, email, address, user_type, password_hash,
    job_title, agency, contact_info,
    move_in_date, preferred_location, budget,
    credit_card_name, credit_card_number, credit_card_cvv,
    credit_card_exp_month, credit_card_exp_year
  } = req.body;

  db.query(
    'INSERT INTO users (name, email, address, password_hash, user_type) VALUES (?, ?, ?, ?, ?)',
    [name, email, address, password_hash, user_type],
    (err, result) => {
      if (err) return res.status(500).json({ error: err });

      const user_id = result.insertId;

      if (user_type === 'Agent') {
        db.query(
          'INSERT INTO agents (user_id, job_title, agency, contact_info) VALUES (?, ?, ?, ?)',
          [user_id, job_title, agency, contact_info],
          (err2) => {
            if (err2) return res.status(500).json({ error: err2 });
            res.status(200).json({ message: 'Agent registered successfully' });
          }
        );
      } else {
        db.query(
          'INSERT INTO renters (user_id, move_in_date, preferred_location, budget, credit_card_name, credit_card_number, credit_card_cvv, credit_card_exp_month, credit_card_exp_year) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [user_id, move_in_date, preferred_location, budget, credit_card_name, credit_card_number, credit_card_cvv, credit_card_exp_month, credit_card_exp_year],
          (err3) => {
            if (err3) return res.status(500).json({ error: err3 });
            res.status(200).json({ message: 'Renter registered successfully' });
          }
        );
      }
    }
  );
});

router.post('/login', (req, res) => {
  const { email, password_hash } = req.body;
  console.log('Login attempt from:', email);
  db.query(
    'SELECT * FROM users WHERE email = ? AND password_hash = ?',
    [email, password_hash],
    (err, results) => {
      if (err) return res.status(500).json({ error: err });

      if (results.length === 0) {
        console.log('Login failed: no matching credentials');
        return res.status(401).json({ message: 'Invalid credentials' });
      }

      const user = results[0];

      db.query(
        'INSERT INTO login_logs (user_id) VALUES (?)',
        [user.id],
        (err2) => {
          if (err2) console.error('Failed to log login event:', err2);
          res.status(200).json({ message: 'Login successful', user });
        }
      );
    }
  );
});

module.exports = router;
