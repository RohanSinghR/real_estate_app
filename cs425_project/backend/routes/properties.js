const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/apartments', (req, res) => {
  const query = `
    SELECT p.*, a.num_rooms, a.square_footage, a.building_type, n.neighborhood_id, 
           n.nearby_schools, n.crime_rate, ag.email as agentEmail, ag.phone_num, ag.Agency
    FROM property p
    JOIN Apartment a ON p.property_id = a.property_id
    JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN Agent ag ON p.email = ag.email
    WHERE p.type = 'Apartment'
  `;
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(results);
  });
});

router.get('/houses', (req, res) => {
  const query = `
    SELECT p.*, h.num_rooms, h.square_footage, n.neighborhood_id, 
           n.nearby_schools, n.crime_rate, ag.email as agentEmail, ag.phone_num, ag.Agency
    FROM property p
    JOIN House h ON p.property_id = h.property_id
    JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN Agent ag ON p.email = ag.email
    WHERE p.type = 'House'
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(results);
  });
});

router.get('/commercial', (req, res) => {
  const query = `
    SELECT p.*, c.square_footage, c.type_of_business, n.neighborhood_id, 
           n.nearby_schools, n.crime_rate, ag.email as agentEmail, ag.phone_num, ag.Agency
    FROM property p
    JOIN Commercial_buildings c ON p.property_id = c.property_id
    JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN Agent ag ON p.email = ag.email
    WHERE p.type = 'Commercial_buildings'
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(results);
  });
});

router.get('/vacation', (req, res) => {
  const query = `
    SELECT p.*, v.num_rooms, v.square_footage, n.neighborhood_id, 
           n.nearby_schools, n.crime_rate, ag.email as agentEmail, ag.phone_num, ag.Agency
    FROM property p
    JOIN Vacation_homes v ON p.property_id = v.property_id
    JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN Agent ag ON p.email = ag.email
    WHERE p.type = 'Vacation_homes'
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(results);
  });
});

router.get('/land', (req, res) => {
  const query = `
    SELECT p.*, l.area, n.neighborhood_id, 
           n.nearby_schools, n.crime_rate, ag.email as agentEmail, ag.phone_num, ag.Agency
    FROM property p
    JOIN Land l ON p.property_id = l.property_id
    JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN Agent ag ON p.email = ag.email
    WHERE p.type = 'Land'
  `;
  db.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    res.json(results);
  });
});

router.get('/properties', (req, res) => {
  const query = `
    SELECT 
      p.property_id, p.price, p.type, p.availability, p.description, p.city, p.state,
      n.neighborhood_id, n.nearby_schools, n.crime_rate, 
      ag.email as agentEmail, ag.phone_num, ag.Agency,
      -- House specific fields
      h.num_rooms as house_rooms, h.square_footage as house_sqft,
      -- Apartment specific fields
      a.num_rooms as apt_rooms, a.square_footage as apt_sqft, a.building_type,
      -- Commercial building specific fields
      c.square_footage as commercial_sqft, c.type_of_business,
      -- Vacation home specific fields
      v.num_rooms as vacation_rooms, v.square_footage as vacation_sqft,
      -- Land specific fields
      l.area
    FROM property p
    JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN Agent ag ON p.email = ag.email
    LEFT JOIN House h ON (p.property_id = h.property_id AND p.type = 'House')
    LEFT JOIN Apartment a ON (p.property_id = a.property_id AND p.type = 'Apartment')
    LEFT JOIN Commercial_buildings c ON (p.property_id = c.property_id AND p.type = 'Commercial_buildings')
    LEFT JOIN Vacation_homes v ON (p.property_id = v.property_id AND p.type = 'Vacation_homes')
    LEFT JOIN Land l ON (p.property_id = l.property_id AND p.type = 'Land')
  `;
  db.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching properties:', err);
      return res.status(500).json({ error: err.message });
    }
    const transformedProperties = results.map(item => {
      const title = item.description?.split('.')[0] || 'Property';
      const property = {
        property_id: item.property_id,
        title: title,
        price: item.price,
        availability: item.availability ? new Date(item.availability).toISOString().split('T')[0] : null,
        city: item.city,
        state: item.state,
        squareFootage: 0, 
        details: item.description,
        agentEmail: item.agentEmail,
        neighborhood: `Neighborhood ID: ${item.neighborhood_id}`,
        nearby_schools: item.nearby_schools,
        crime_rate: item.crime_rate
      };
      switch(item.type) {
        case 'House':
          property.type = 'House';
          property.image = 'images/5.jpeg';
          property.bedrooms = item.house_rooms || 0;
          property.bathrooms = Math.ceil((item.house_rooms || 1) / 2);
          property.squareFootage = item.house_sqft || 0;
          break;
        case 'Apartment':
          property.type = 'Apartment';
          property.image = 'images/2.jpeg';
          property.rooms = item.apt_rooms || 0;
          property.squareFootage = item.apt_sqft || 0;
          property.buildingType = item.building_type || 'Standard';
          break;
        case 'Commercial_buildings':
          property.type = 'Commercial';
          property.image = 'images/3.jpeg';
          property.squareFootage = item.commercial_sqft || 0;
          property.businessType = item.type_of_business || 'Office';
          break;
        case 'Vacation_homes':
          property.type = 'Vacation Home';
          property.image = 'images/1.jpeg';
          property.rooms = item.vacation_rooms || 0;
          property.squareFootage = item.vacation_sqft || 0;
          break;
        case 'Land':
          property.type = 'Land';
          property.image = 'images/6.jpeg';
          const acres = (item.area || 0) / 43560;
          property.area = `${acres.toFixed(2)} acres`;
          property.squareFootage = item.area || 0;
          break;
        default:
          property.type = 'Unknown';
          property.image = 'images/1.jpeg';
      }
      return property;
    });
    res.json(transformedProperties);
  });
});

router.get('/agent-properties', (req, res) => {
  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: 'Agent email is required' });
  }
  db.query('SELECT * FROM Agent WHERE email = ?', [email], (agentErr, agentResults) => {
    if (agentErr) {
      console.error('Error checking agent:', agentErr);
      return res.status(500).json({ error: agentErr.message });
    } 
    if (agentResults.length === 0) {
      return res.status(403).json({ error: 'Only agents can view their properties' });
    }
    const query = `
      SELECT 
        p.*, n.neighborhood_id, n.nearby_schools, n.crime_rate, 
        ag.email as agentEmail, ag.phone_num, ag.Agency,
        -- House specific fields
        h.num_rooms as house_rooms, h.square_footage as house_sqft,
        -- Apartment specific fields
        a.num_rooms as apt_rooms, a.square_footage as apt_sqft, a.building_type,
        -- Commercial building specific fields
        c.square_footage as commercial_sqft, c.type_of_business,
        -- Vacation home specific fields
        v.num_rooms as vacation_rooms, v.square_footage as vacation_sqft,
        -- Land specific fields
        l.area
      FROM property p
      JOIN neighborhood n ON p.neighborhood_id = n.neighborhood_id
      JOIN Agent ag ON p.email = ag.email
      LEFT JOIN House h ON (p.property_id = h.property_id AND p.type = 'House')
      LEFT JOIN Apartment a ON (p.property_id = a.property_id AND p.type = 'Apartment')
      LEFT JOIN Commercial_buildings c ON (p.property_id = c.property_id AND p.type = 'Commercial_buildings')
      LEFT JOIN Vacation_homes v ON (p.property_id = v.property_id AND p.type = 'Vacation_homes')
      LEFT JOIN Land l ON (p.property_id = l.property_id AND p.type = 'Land')
      WHERE p.email = ?
    `;
    
    db.query(query, [email], (err, results) => {
      if (err) {
        console.error('Error fetching agent properties:', err);
        return res.status(500).json({ error: err.message });
      }
      const transformedProperties = results.map(item => {
        const property = {
          property_id: item.property_id,
          title: item.description?.split('.')[0] || 'Property',
          price: item.price,
          availability: item.availability ? new Date(item.availability).toISOString().split('T')[0] : null,
          city: item.city,
          state: item.state,
          squareFootage: 0,
          details: item.description,
          agentEmail: item.agentEmail,
          neighborhood: `Neighborhood ID: ${item.neighborhood_id}`,
          nearby_schools: item.nearby_schools,
          crime_rate: item.crime_rate
        };
        switch(item.type) {
          case 'House':
            property.type = 'House';
            property.image = 'images/5.jpeg';
            property.bedrooms = item.house_rooms || 0;
            property.bathrooms = Math.ceil((item.house_rooms || 1) / 2);
            property.squareFootage = item.house_sqft || 0;
            break;
          case 'Apartment':
            property.type = 'Apartment';
            property.image = 'images/2.jpeg';
            property.rooms = item.apt_rooms || 0;
            property.squareFootage = item.apt_sqft || 0;
            property.buildingType = item.building_type || 'Standard';
            break;
          case 'Commercial_buildings':
            property.type = 'Commercial';
            property.image = 'images/3.jpeg';
            property.squareFootage = item.commercial_sqft || 0;
            property.businessType = item.type_of_business || 'Office';
            break;
          case 'Vacation_homes':
            property.type = 'Vacation Home';
            property.image = 'images/1.jpeg';
            property.rooms = item.vacation_rooms || 0;
            property.squareFootage = item.vacation_sqft || 0;
            break;
          case 'Land':
            property.type = 'Land';
            property.image = 'images/6.jpeg';
            const acres = (item.area || 0) / 43560;
            property.area = `${acres.toFixed(2)} acres`;
            property.squareFootage = item.area || 0;
            break;
          default:
            property.type = 'Unknown';
            property.image = 'images/1.jpeg';
        }
        return property;
      });
      res.json(transformedProperties);
    });
  });
});

router.post('/properties', async (req, res) => {
  try {
    const { 
      property_id,
      type, price, city, state, description, availability, email,
      neighborhood_id = 1,
      num_rooms, square_footage, building_type, type_of_business, area
    } = req.body;
    if (!property_id || !type || !price || !city || !state || !description || !email) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const [agentResults] = await db.promise().query('SELECT * FROM Agent WHERE email = ?', [email]);
    if (agentResults.length === 0) {
      return res.status(403).json({ error: 'Only agents can add properties' });
    }
    const [existingProperty] = await db.promise().query(
      'SELECT * FROM property WHERE property_id = ?',
      [property_id]
    );
    if (existingProperty.length > 0) {
      return res.status(400).json({ error: 'Property ID already exists. Please use a different ID.' });
    }
    await db.promise().query('START TRANSACTION');
    const dbType = type === 'Commercial' ? 'Commercial_buildings' : 
                   type === 'Vacation Home' ? 'Vacation_homes' : type;
    const [propertyResult] = await db.promise().query(
      'INSERT INTO property (property_id, price, type, availability, description, city, state, neighborhood_id, email) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [property_id, price, dbType, availability, description, city, state, neighborhood_id, email]
    );
    if (type === 'House') {
      await db.promise().query(
        'INSERT INTO House (num_rooms, square_footage, property_id) VALUES (?, ?, ?)',
        [num_rooms || 3, square_footage || 1500, property_id]
      );
    } else if (type === 'Apartment') {
      await db.promise().query(
        'INSERT INTO Apartment (num_rooms, square_footage, building_type, property_id) VALUES (?, ?, ?, ?)',
        [num_rooms || 2, square_footage || 1000, building_type || 'Standard', property_id]
      );
    } else if (type === 'Commercial') {
      await db.promise().query(
        'INSERT INTO Commercial_buildings (square_footage, type_of_business, property_id) VALUES (?, ?, ?)',
        [square_footage || 5000, type_of_business || 'Office', property_id]
      );
    } else if (type === 'Vacation Home') {
      await db.promise().query(
        'INSERT INTO Vacation_homes (num_rooms, square_footage, property_id) VALUES (?, ?, ?)',
        [num_rooms || 4, square_footage || 2000, property_id]
      );
    } else if (type === 'Land') {
      await db.promise().query(
        'INSERT INTO Land (area, property_id) VALUES (?, ?)',
        [area || 10000, property_id]
      );
    }
    await db.promise().query('COMMIT');
    res.status(201).json({ 
      success: true, 
      property_id,
      message: 'Property added successfully'
    });
  } catch (error) {
    await db.promise().query('ROLLBACK');
    console.error('Error adding property:', error);
    res.status(500).json({ error: error.message });
  }
});
router.put('/properties/:property_id', async (req, res) => {
  try {
    const { property_id } = req.params;
    const { 
      type, price, city, state, description, availability, email,
      num_rooms, square_footage, building_type, type_of_business, area
    } = req.body;
    if (!property_id) {
      return res.status(400).json({ error: 'Property ID is required' });
    }
    const [properties] = await db.promise().query(
      'SELECT * FROM property WHERE property_id = ?',
      [property_id]
    );
    if (properties.length === 0) {
      return res.status(404).json({ error: 'Property not found' });
    }
    const currentProperty = properties[0];
    if (email !== currentProperty.email) {
      return res.status(403).json({ error: 'You can only update your own properties' });
    }
    await db.promise().query('START TRANSACTION');
    const updateFields = [];
    const updateValues = [];
    if (price) {
      updateFields.push('price = ?');
      updateValues.push(price);
    } 
    if (city) {
      updateFields.push('city = ?');
      updateValues.push(city);
    }
    if (state) {
      updateFields.push('state = ?');
      updateValues.push(state);
    }
    if (description) {
      updateFields.push('description = ?');
      updateValues.push(description);
    }
    if (availability) {
      updateFields.push('availability = ?');
      updateValues.push(availability);
    }
    if (updateFields.length > 0) {
      updateValues.push(property_id);
      await db.promise().query(
        `UPDATE property SET ${updateFields.join(', ')} WHERE property_id = ?`,
        updateValues
      );
    }
    const currentType = currentProperty.type;
    if (currentType === 'House') {
      if (num_rooms || square_footage) {
        const houseFields = [];
        const houseValues = [];
        if (num_rooms) {
          houseFields.push('num_rooms = ?');
          houseValues.push(num_rooms);
        }
        if (square_footage) {
          houseFields.push('square_footage = ?');
          houseValues.push(square_footage);
        }
        if (houseFields.length > 0) {
          houseValues.push(property_id);
          await db.promise().query(
            `UPDATE House SET ${houseFields.join(', ')} WHERE property_id = ?`,
            houseValues
          );
        }
      }
    } else if (currentType === 'Apartment') {
      if (num_rooms || square_footage || building_type) {
        const aptFields = [];
        const aptValues = [];
        if (num_rooms) {
          aptFields.push('num_rooms = ?');
          aptValues.push(num_rooms);
        } 
        if (square_footage) {
          aptFields.push('square_footage = ?');
          aptValues.push(square_footage);
        }
        if (building_type) {
          aptFields.push('building_type = ?');
          aptValues.push(building_type);
        }
        if (aptFields.length > 0) {
          aptValues.push(property_id);
          await db.promise().query(
            `UPDATE Apartment SET ${aptFields.join(', ')} WHERE property_id = ?`,
            aptValues
          );
        }
      }
    } else if (currentType === 'Commercial_buildings') {
      if (square_footage || type_of_business) {
        const commFields = [];
        const commValues = [];
        if (square_footage) {
          commFields.push('square_footage = ?');
          commValues.push(square_footage);
        }
        if (type_of_business) {
          commFields.push('type_of_business = ?');
          commValues.push(type_of_business);
        }
        if (commFields.length > 0) {
          commValues.push(property_id);
          await db.promise().query(
            `UPDATE Commercial_buildings SET ${commFields.join(', ')} WHERE property_id = ?`,
            commValues
          );
        }
      }
    } else if (currentType === 'Vacation_homes') {
      if (num_rooms || square_footage) {
        const vacFields = [];
        const vacValues = [];
        if (num_rooms) {
          vacFields.push('num_rooms = ?');
          vacValues.push(num_rooms);
        }
        if (square_footage) {
          vacFields.push('square_footage = ?');
          vacValues.push(square_footage);
        }
        if (vacFields.length > 0) {
          vacValues.push(property_id);
          await db.promise().query(
            `UPDATE Vacation_homes SET ${vacFields.join(', ')} WHERE property_id = ?`,
            vacValues
          );
        }
      }
    } else if (currentType === 'Land') {
      if (area) {
        await db.promise().query(
          'UPDATE Land SET area = ? WHERE property_id = ?',
          [area, property_id]
        );
      }
    }
    await db.promise().query('COMMIT');
    res.status(200).json({ 
      success: true, 
      property_id,
      message: 'Property updated successfully'
    });
  } catch (error) {
    await db.promise().query('ROLLBACK');
    console.error('Error updating property:', error);
    res.status(500).json({ error: error.message });
  }
});
router.delete('/properties/:property_id', async (req, res) => {
  try {
    const { property_id } = req.params;
    const { email, force_delete } = req.query;
    if (!property_id) {
      return res.status(400).json({ error: 'Property ID is required' });
    }
    if (!email) {
      return res.status(400).json({ error: 'Agent email is required' });
    }
    const [properties] = await db.promise().query(
      'SELECT * FROM property WHERE property_id = ?',
      [property_id]
    );
    if (properties.length === 0) {
      return res.status(404).json({ error: 'Property not found' });
    }
    const currentProperty = properties[0];
    if (email !== currentProperty.email) {
      return res.status(403).json({ error: 'You can only delete your own properties' });
    }
    const [bookings] = await db.promise().query(
      'SELECT * FROM Booking WHERE property_id = ?',
      [property_id]
    );
    if (bookings.length > 0 && force_delete !== 'true') {
      return res.status(400).json({ 
        error: 'Cannot delete property with existing bookings. Remove all bookings first.',
        has_bookings: true,
        booking_count: bookings.length
      });
    }
    await db.promise().query('START TRANSACTION');
    
    try {
      if (force_delete === 'true' && bookings.length > 0) {
        await db.promise().query('DELETE FROM Booking WHERE property_id = ?', [property_id]);
        console.log(`Deleted ${bookings.length} bookings for property ${property_id}`);
      }
      const currentType = currentProperty.type;
      if (currentType === 'House') {
        await db.promise().query('DELETE FROM House WHERE property_id = ?', [property_id]);
      } else if (currentType === 'Apartment') {
        await db.promise().query('DELETE FROM Apartment WHERE property_id = ?', [property_id]);
      } else if (currentType === 'Commercial_buildings') {
        await db.promise().query('DELETE FROM Commercial_buildings WHERE property_id = ?', [property_id]);
      } else if (currentType === 'Vacation_homes') {
        await db.promise().query('DELETE FROM Vacation_homes WHERE property_id = ?', [property_id]);
      } else if (currentType === 'Land') {
        await db.promise().query('DELETE FROM Land WHERE property_id = ?', [property_id]);
      }
      await db.promise().query('DELETE FROM property WHERE property_id = ?', [property_id]);
      await db.promise().query('COMMIT');
      res.status(200).json({ 
        success: true, 
        message: force_delete === 'true' && bookings.length > 0 
          ? `Property and ${bookings.length} bookings deleted successfully` 
          : 'Property deleted successfully'
      });
    } catch (error) {
      await db.promise().query('ROLLBACK');
      throw error;
    }
  } catch (error) {
    console.error('Error deleting property:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/check-agent', (req, res) => {
  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: 'Email is required' });
  }
  db.query('SELECT * FROM Users WHERE email = ? AND user_type = "agent"', [email], (err, results) => {
    if (err) {
      console.error('Error checking agent status:', err);
      return res.status(500).json({ error: err.message });
    }
    res.json({
      isAgent: results.length > 0,
      userDetails: results.length > 0 ? results[0] : null
    });
  });
});

router.get('/users/type', (req, res) => {
  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: 'Email parameter is required' });
  }
  db.query('SELECT user_type FROM Users WHERE email = ?', [email], (err, results) => {
    if (err) {
      console.error('Error checking user type:', err);
      return res.status(500).json({ error: err.message });
    }
    if (results.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({
      user_type: results[0].user_type,
      email: email
    });
  });
});

module.exports = router;