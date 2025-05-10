const express = require('express');
const db = require('../db');
const router = express.Router();

router.post('/signup', (req, res) => {
  const {
    name,
    email,
    address,
    password_hash,
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

  db.query('SELECT * FROM Users WHERE email = ?', [email], (checkErr, checkResult) => {
    if (checkErr) {
      return res.status(500).json({ error: 'Database error', details: checkErr });
    }
    
    if (checkResult.length > 0) {
      return res.status(409).json({ error: 'Email exists' });
    }
    const normalizedType = user_type.toLowerCase().trim();
    console.log('user type received:', user_type);
    console.log('normalized type:', normalizedType);

    db.query(
      'INSERT INTO Users (name, email, address, password_hash, user_type) VALUES (?, ?, ?, ?, ?)',
      [name, email, address, password_hash, normalizedType],
      (err, result) => {
        if (err) return res.status(500).json({ error: 'User insertion failed', details: err });

        if (normalizedType === 'agent') {
          db.query(
            'INSERT INTO Agent (phone_num, Job_role, Agency, email) VALUES (?, ?, ?, ?)',
            [contact_info, job_title, agency, email],
            (err3) => {
              if (err3) return res.status(500).json({ error: 'Agent insertion failed', details: err3 });
              return res.status(200).json({ message: 'Agent registered successfully' });
            }
          );
        } else if (normalizedType === 'renter') {
          db.query(
            'INSERT INTO Credit_Card (card_number, cvv, billing_address, expiry_date, email) VALUES (?, ?, ?, ?, ?)',
            [credit_card_number, credit_card_cvv, credit_card_billing_address, credit_card_expiry, email],
            (err2) => {
              if (err2) return res.status(500).json({ error: 'Credit card insertion failed', details: err2 });

              db.query(
                'INSERT INTO Renter (preferred_location, reward_points, email) VALUES (?, ?, ?)',
                [preferred_location, reward_points, email],
                (err4) => {
                  if (err4) return res.status(500).json({ error: 'Renter insertion failed', details: err4 });
                  return res.status(200).json({ message: 'Renter registered successfully' });
                }
              );
            }
          );
        } else {
          return res.status(400).json({ error: 'Invalid user_type value received' });
        }
      }
    );
  });
});

router.post('/login', (req, res) => {
  const { email, password_hash } = req.body;
  console.log('Login attempt:');
  console.log('Email:', email);
  console.log('Password Hash:', password_hash);

  db.query(
    'SELECT * FROM Users WHERE email = ? AND password_hash = ?',
    [email, password_hash],
    (err, results) => {
      if (err) return res.status(500).json({ error: 'Login failed', details: err });

      if (results.length === 0) {
        return res.status(401).json({ message: 'Invalid email or password' });
      }
      const user = results[0];
      console.log('User found:', user);
      
      return res.status(200).json({ 
        message: 'Login successful', 
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          user_type: user.user_type
        } 
      });
    }
  );
});

module.exports = router;