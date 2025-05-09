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

  const normalizedType = user_type.trim().toLowerCase();
  console.log('user_type received:', user_type);

  db.query(
    'INSERT INTO Users (name, email, address, password_hash, user_type) VALUES (?, ?, ?, ?, ?)',
    [name, email, address, password_hash, user_type],
    (err, result) => {
      if (err) return res.status(500).json({ error: 'User insertion failed', details: err });

      db.query(
        'INSERT INTO Credit_Card (card_number, cvv, billing_address, expiry_date, email) VALUES (?, ?, ?, ?, ?)',
        [credit_card_number, credit_card_cvv, credit_card_billing_address, credit_card_expiry, email],
        (err2) => {
          if (err2) return res.status(500).json({ error: 'Credit card insertion failed', details: err2 });

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
              'INSERT INTO Renter (renter_details, preferred_location, reward_points, email) VALUES (?, ?, ?, ?)',
              [contact_info, preferred_location, reward_points, email],
              (err4) => {
                if (err4) return res.status(500).json({ error: 'Renter insertion failed', details: err4 });
                return res.status(200).json({ message: 'Renter registered successfully' });
              }
            );
          } else {
            return res.status(400).json({ error: 'Invalid user_type value received' });
          }
        }
      );
    }
  );
});
