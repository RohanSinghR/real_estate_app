const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/cards', (req, res) => {
  console.log('-------- GET /cards request received --------');
  console.log('Request query:', req.query);
  console.log('Original email from query:', req.query.email);
  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: 'Email is required' });
  }
  console.log('Fetching cards for email:', email);
  const query = 'SELECT * FROM Credit_Card WHERE email = ?';
  console.log('Running query:', query, 'with params:', [email]);
  
  db.query(query, [email], (err, results) => {
    if (err) {
      console.error('Database error when fetching cards:', err);
      return res.status(500).json({ error: 'Failed to fetch payment methods', details: err.message });
    }
    
    console.log(`Found ${results.length} cards for ${email}`);
    const formattedResults = results.map(card => {
      if (card.expiry_date instanceof Date) {
        card.expiry_date = card.expiry_date.toISOString().split('T')[0];
      }
      return card;
    });
    
    console.log('Returning formatted cards:', formattedResults);
    return res.status(200).json(formattedResults);
  });
});
router.post('/cards', (req, res) => {
  const { card_number, cvv, billing_address, expiry_date, email } = req.body;
  
  if (!card_number || !cvv || !billing_address || !expiry_date || !email) {
    return res.status(400).json({ 
      error: 'Missing required fields',
      receivedFields: { card_number: !!card_number, cvv: !!cvv, billing_address: !!billing_address, expiry_date: !!expiry_date, email: !!email }
    });
  }
  console.log('Adding new card:', { 
    card_number, 
    cvv: typeof cvv === 'string' ? parseInt(cvv, 10) : cvv, 
    billing_address, 
    expiry_date, 
    email 
  });
  const cvvInt = typeof cvv === 'string' ? parseInt(cvv, 10) : cvv;
  db.query(
    'SELECT * FROM Credit_Card WHERE card_number = ?',
    [card_number],
    (checkErr, checkResults) => {
      if (checkErr) {
        console.error('Database error when checking card:', checkErr);
        return res.status(500).json({ error: 'Failed to check if card exists', details: checkErr.message });
      }
      
      if (checkResults.length > 0) {
        return res.status(409).json({ error: 'Card already exists' });
      }
      const insertQuery = 'INSERT INTO Credit_Card (card_number, cvv, billing_address, expiry_date, email) VALUES (?, ?, ?, ?, ?)';
      const params = [card_number, cvvInt, billing_address, expiry_date, email];
      
      console.log('Running insert query:', insertQuery, 'with params:', params);
      
      db.query(insertQuery, params, (insertErr, result) => {
        if (insertErr) {
          console.error('Database error when inserting card:', insertErr);
          return res.status(500).json({ error: 'Failed to add payment method', details: insertErr.message });
        }
        
        console.log('Card added successfully for', email, 'Result:', result);
        return res.status(200).json({ message: 'Payment method added successfully' });
      });
    }
  );
});
router.put('/cards', (req, res) => {
  const { card_number, billing_address } = req.body;
  
  if (!card_number || !billing_address) {
    return res.status(400).json({ error: 'Card number and billing address are required' });
  }
  
  console.log('Updating card:', { card_number, billing_address });
  
  const updateQuery = 'UPDATE Credit_Card SET billing_address = ? WHERE card_number = ?';
  console.log('Running update query:', updateQuery, 'with params:', [billing_address, card_number]);
  
  db.query(updateQuery, [billing_address, card_number], (err, result) => {
    if (err) {
      console.error('Database error when updating card:', err);
      return res.status(500).json({ error: 'Failed to update payment method', details: err.message });
    }
    
    console.log('Update result:', result);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Card not found' });
    }
    
    console.log('Card updated successfully:', card_number);
    return res.status(200).json({ message: 'Payment method updated successfully' });
  });
});
router.delete('/cards', (req, res) => {
  const { card_number } = req.body;
  if (!card_number) {
    return res.status(400).json({ error: 'Card number is required' });
  }
  console.log('Deleting card:', card_number);
  const deleteQuery = 'DELETE FROM Credit_Card WHERE card_number = ?';
  console.log('Running delete query:', deleteQuery, 'with params:', [card_number]);
  db.query(deleteQuery, [card_number], (err, result) => {
    if (err) {
      console.error('Database error when deleting card:', err);
      return res.status(500).json({ error: 'Failed to delete payment method', details: err.message });
    }
    console.log('Delete result:', result);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Card not found' });
    }
    console.log('Card deleted successfully:', card_number);
    return res.status(200).json({ message: 'Payment method deleted successfully' });
  });
});

module.exports = router;