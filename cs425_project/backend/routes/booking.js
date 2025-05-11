const express = require('express');
const router = express.Router();
const db = require('../db');
router.post('/book', (req, res) => {
    const { email, property_id, card_number, payment_method, date } = req.body;
    console.log('Booking request received:', { email, property_id, card_number, payment_method, date });
    db.beginTransaction(err => {
        if (err) {
            console.error('Error starting transaction:', err);
            return res.status(500).json({ error: err.message });
        }
        db.query('SELECT * FROM Users WHERE email = ?', [email], (userErr, userResults) => {
            if (userErr) {
                return db.rollback(() => {
                    console.error('Error checking user:', userErr);
                    res.status(500).json({ error: userErr.message });
                });
            }      
            const userExists = userResults.length > 0;
            const createUserIfNeeded = (callback) => {
                if (!userExists) {
                    db.query(
                        'INSERT INTO Users (name, email, address, password_hash, user_type) VALUES (?, ?, ?, ?, ?)',
                        ['Test User', email, '123 Test St', 'password123', 'renter'],
                        callback
                    );
                } else {
                    callback(null);
                }
            };
            createUserIfNeeded((createUserErr) => {
                if (createUserErr) {
                    return db.rollback(() => {
                        console.error('Error creating user:', createUserErr);
                        res.status(500).json({ error: createUserErr.message });
                    });
                }
                db.query('SELECT * FROM Renter WHERE email = ?', [email], (renterErr, renterResults) => {
                    if (renterErr) {
                        return db.rollback(() => {
                            console.error('Error checking renter:', renterErr);
                            res.status(500).json({ error: renterErr.message });
                        });
                    }
                    const renterExists = renterResults.length > 0;
                    const createRenterIfNeeded = (callback) => {
                        if (!renterExists) {
                            db.query(
                                'INSERT INTO Renter (email, preferred_location, reward_points) VALUES (?, ?, ?)',
                                [email, 'Chicago', 0],
                                callback
                            );
                        } else {
                            callback(null);
                        }
                    };
                    createRenterIfNeeded((createRenterErr) => {
                        if (createRenterErr) {
                            return db.rollback(() => {
                                console.error('Error creating renter:', createRenterErr);
                                res.status(500).json({ error: createRenterErr.message });
                            });
                        }  
                        db.query('SELECT * FROM Credit_Card WHERE card_number = ?', [card_number], (cardErr, cardResults) => {
                            if (cardErr) {
                                return db.rollback(() => {
                                    console.error('Error checking card:', cardErr);
                                    res.status(500).json({ error: cardErr.message });
                                });
                            }
                            const cardExists = cardResults.length > 0;
                            const createCardIfNeeded = (callback) => {
                                if (!cardExists) {
                                    db.query(
                                        'INSERT INTO Credit_Card (card_number, cvv, billing_address, expiry_date, email) VALUES (?, ?, ?, ?, ?)',
                                        [card_number, 123, '123 Billing St', '2026-12-31', email],
                                        callback
                                    );
                                } else {
                                    callback(null);
                                }
                            };
                            createCardIfNeeded((createCardErr) => {
                                if (createCardErr) {
                                    return db.rollback(() => {
                                        console.error('Error creating card:', createCardErr);
                                        res.status(500).json({ error: createCardErr.message });
                                    });
                                }
                                db.query('SELECT * FROM Booking WHERE email = ? AND property_id = ?', [email, property_id], (bookingErr, bookingResults) => {
                                    if (bookingErr) {
                                        return db.rollback(() => {
                                            console.error('Error checking existing booking:', bookingErr);
                                            res.status(500).json({ error: bookingErr.message });
                                        });
                                    }
                                    if (bookingResults.length > 0) {
                                        db.commit(commitErr => {
                                            if (commitErr) {
                                                return db.rollback(() => {
                                                    console.error('Error committing transaction:', commitErr);
                                                    res.status(500).json({ error: commitErr.message });
                                                });
                                            }
                                            res.status(200).json({
                                                success: true,
                                                booking_id: bookingResults[0].booking_id,
                                                message: 'You have already booked this property'
                                            });
                                        });
                                        return;
                                    }
                                    const booking_id = Math.floor(100000 + Math.random() * 900000);
                                    const insertQuery = 'INSERT INTO Booking (booking_id, payment_method, date, property_id, email, card_number) VALUES (?, ?, ?, ?, ?, ?)';
                                    db.query(insertQuery, [booking_id, payment_method, date, property_id, email, card_number], (insertErr) => {
                                        if (insertErr) {
                                            return db.rollback(() => {
                                                console.error('Error creating booking:', insertErr);
                                                if (insertErr.code === 'ER_DUP_ENTRY') {
                                                    const new_booking_id = booking_id + 1000;
                                                    db.query(insertQuery, [new_booking_id, payment_method, date, property_id, email, card_number], (retryErr) => {
                                                        if (retryErr) {
                                                            return db.rollback(() => {
                                                                console.error('Error on retry booking:', retryErr);
                                                                res.status(500).json({ error: 'Could not create booking after multiple attempts' });
                                                            });
                                                        }
                                                        db.commit(commitErr => {
                                                            if (commitErr) {
                                                                return db.rollback(() => {
                                                                    console.error('Error committing transaction on retry:', commitErr);
                                                                    res.status(500).json({ error: commitErr.message });
                                                                });
                                                            }
                                                            console.log('Booking created successfully on retry:', new_booking_id);
                                                            res.status(200).json({ success: true, booking_id: new_booking_id });
                                                        });
                                                    });
                                                    return;
                                                }
                                                res.status(500).json({ error: insertErr.message });
                                            });
                                        }
                                        db.commit(commitErr => {
                                            if (commitErr) {
                                                return db.rollback(() => {
                                                    console.error('Error committing transaction:', commitErr);
                                                    res.status(500).json({ error: commitErr.message });
                                                });
                                            }
                                            console.log('Booking created successfully:', booking_id);
                                            res.status(200).json({ success: true, booking_id });
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    });
});
async function ensureCardExists(email, card_number) {
    return new Promise((resolve, reject) => {
        const checkQuery = 'SELECT card_number FROM Credit_Card WHERE card_number = ?';
        db.query(checkQuery, [card_number], (err, results) => {
            if (err) {
                console.error('Error checking card:', err);
                return reject(err);
            }     
            if (results.length > 0) {
                return resolve(true);
            }
            const createCardQuery = `
                INSERT INTO Credit_Card (card_number, cvv, billing_address, expiry_date, email)
                VALUES (?, ?, ?, ?, ?)
            `;
            db.query(createCardQuery, [
                card_number,
                123,
                '123 Billing St',
                '2026-12-31',
                email
            ], (createErr) => {
                if (createErr) {
                    console.error('Error creating card:', createErr);
                    return reject(createErr);
                }
                resolve(true);
            });
        });
    });
}

router.get('/bookings', (req, res) => {
    const { email } = req.query;
    if (!email) {
        return res.status(400).json({ error: 'Email parameter is required' });
    }  
    console.log('Fetching bookings for email:', email);
    const query = `
        SELECT b.booking_id, b.payment_method, b.date, 
               p.property_id, p.price, p.type, p.availability, p.description, p.city as location, p.state,
               n.neighborhood_id, 
               a.email as agentEmail,
               CASE 
                   WHEN p.type = 'House' THEN h.num_rooms
                   WHEN p.type = 'Apartment' THEN ap.num_rooms
                   WHEN p.type = 'Vacation_homes' THEN v.num_rooms
                   ELSE NULL
               END as numRooms,
               CASE 
                   WHEN p.type = 'House' THEN h.square_footage
                   WHEN p.type = 'Apartment' THEN ap.square_footage
                   WHEN p.type = 'Commercial_buildings' THEN c.square_footage
                   WHEN p.type = 'Vacation_homes' THEN v.square_footage
                   ELSE NULL
               END as squareFootage,
               CASE 
                   WHEN p.type = 'Land' THEN l.area 
                   ELSE NULL
               END as area,
               CASE 
                   WHEN p.type = 'Apartment' THEN ap.building_type
                   ELSE NULL
               END as building_type,
               CASE 
                   WHEN p.type = 'Commercial_buildings' THEN c.type_of_business
                   ELSE NULL
               END as type_of_business
        FROM Booking b
        JOIN property p ON b.property_id = p.property_id
        JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
        JOIN Agent a ON p.email = a.email
        LEFT JOIN House h ON (p.property_id = h.property_id AND p.type = 'House')
        LEFT JOIN Apartment ap ON (p.property_id = ap.property_id AND p.type = 'Apartment')
        LEFT JOIN Commercial_buildings c ON (p.property_id = c.property_id AND p.type = 'Commercial_buildings')
        LEFT JOIN Vacation_homes v ON (p.property_id = v.property_id AND p.type = 'Vacation_homes')
        LEFT JOIN Land l ON (p.property_id = l.property_id AND p.type = 'Land')
        WHERE b.email = ?
    `;
    
    db.query(query, [email], (err, results) => {
        if (err) {
            console.error('Error fetching bookings:', err);
            return res.status(500).json({ error: err.message });
        }
        console.log(`Found ${results.length} bookings`);
        const bookings = results.map(item => {
            const name = item.description ? item.description.split('.')[0] : 'Property';      
            return {
                booking_id: item.booking_id,
                property_id: item.property_id,
                name: name,
                location: item.location || 'Unknown',
                state: item.state || 'Unknown',
                price: item.price || 0,
                availability: item.date ? new Date(item.date).toISOString().split('T')[0] : 'Unknown',
                neighborhood: `Neighborhood ID: ${item.neighborhood_id}`,
                agentEmail: item.agentEmail || 'No agent',
                numRooms: item.numRooms || null,
                squareFootage: item.squareFootage || null,
                area: item.area || null,
                building_type: item.building_type || null,
                type_of_business: item.type_of_business || null,
                description: item.description || 'No description available',
                image: getImagePathForProperty(item.type)
            };
        });
        res.status(200).json(bookings);
    });
});

router.delete('/bookings/:bookingId', (req, res) => {
    const { bookingId } = req.params;
    console.log(`Deleting booking ID: ${bookingId}`);
    const query = 'DELETE FROM Booking WHERE booking_id = ?';
    db.query(query, [bookingId], (err, result) => {
        if (err) {
            console.error('Error deleting booking:', err);
            return res.status(500).json({ error: err.message });
        }
        if (result.affectedRows === 0) {
            console.log('No booking found with that ID');
            return res.status(404).json({ error: 'Booking not found' });
        }
        console.log('Booking deleted successfully');
        res.status(200).json({ success: true });
    });
});

function getImagePathForProperty(type) {
    switch(type) {
        case 'House': return 'images/5.jpeg';
        case 'Apartment': return 'images/2.jpeg';
        case 'Commercial_buildings': return 'images/3.jpeg';
        case 'Vacation_homes': return 'images/1.jpeg';
        case 'Land': return 'images/6.jpeg';
        default: return 'images/1.jpeg';
    }
}

router.get('/user/card', (req, res) => {
    const { email } = req.query; 
    if (!email) {
        return res.status(400).json({ error: 'Email parameter is required' });
    }  
    const query = `
        SELECT card_number 
        FROM Credit_Card 
        WHERE email = ? 
        LIMIT 1
    `;
    db.query(query, [email], (err, results) => {
        if (err) {
            console.error('Error fetching card:', err);
            return res.status(500).json({ error: err.message });
        }   
        if (results.length === 0) {
            return res.status(200).json({ card_number: '1234-5678-9012-3456' });
        }
   
        res.status(200).json(results[0]);
    });
});
module.exports = router;