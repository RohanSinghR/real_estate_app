const express = require('express');
const router = express.Router();
const db = require('../db');
router.get('/properties/:type', (req, res) => {
  const { type } = req.params;
  
  console.log(`Fetching properties of type: ${type}`);
  const query = `
    SELECT 
      p.*,
      n.crime_rate,
      n.nearby_schools,
      a.phone_num,
      a.Job_role,
      a.Agency,
      u.name as agent_name
    FROM 
      property p
    JOIN 
      neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN 
      Agent a ON p.email = a.email
    JOIN
      Users u ON a.email = u.email
    WHERE 
      p.type = ?
  `;
  
  db.query(query, [type], (err, properties) => {
    if (err) {
      console.error(`Error fetching ${type} properties:`, err);
      return res.status(500).json({ error: 'Failed to fetch properties' });
    }
    
    console.log(`Found ${properties.length} ${type} properties`);
    if (properties.length > 0) {
      const propertyIds = properties.map(p => p.property_id);
      const placeholders = propertyIds.map(() => '?').join(',');
      const typeQuery = `
        SELECT * FROM ${type} WHERE property_id IN (${placeholders})
      `;
      
      db.query(typeQuery, propertyIds, (err, typeDetails) => {
        if (err) {
          console.error(`Error fetching ${type} details:`, err);
          return res.json(properties);
        }
        const typeDetailsMap = {};
        typeDetails.forEach(detail => {
          typeDetailsMap[detail.property_id] = detail;
        });

        const enrichedProperties = properties.map(property => {
          const details = typeDetailsMap[property.property_id] || {};
          return { ...property, ...details };
        });
        
        res.json(enrichedProperties);
      });
    } else {
      res.json([]);
    }
  });
});

router.get('/property/:id', (req, res) => {
  const propertyId = parseInt(req.params.id);
  
  console.log(`Fetching property with ID: ${propertyId}`);
  
  const query = `
    SELECT 
      p.*,
      n.name as neighborhood_name,
      a.name as agent_name
    FROM 
      property p
    JOIN 
      neighborhood n ON p.neighborhood_id = n.neighborhood_id
    JOIN 
      Agent a ON p.email = a.email
    WHERE 
      p.property_id = ?
  `;
  
  db.query(query, [propertyId], (err, results) => {
    if (err) {
      console.error('Error fetching property:', err);
      return res.status(500).json({ error: 'Failed to fetch property' });
    }
    
    if (results.length === 0) {
      return res.status(404).json({ error: 'Property not found' });
    }
    const property = results[0];
    const type = property.type;
    
    const typeQuery = `
      SELECT * FROM ${type} WHERE property_id = ?
    `;
    
    db.query(typeQuery, [propertyId], (err, typeResults) => {
      if (err) {
        console.error('Error fetching property type details:', err);
        return res.json(property);
      }
      const completeProperty = {
        ...property,
        ...(typeResults.length > 0 ? typeResults[0] : {})
      };
      
      res.json(completeProperty);
    });
  });
});

router.get('/basic-properties/:type', (req, res) => {
  const { type } = req.params;
  
  console.log(`Fetching basic properties of type: ${type}`);
  const query = "SELECT * FROM property WHERE type = ?";
  
  db.query(query, [type], (err, results) => {
    if (err) {
      console.error(`Error fetching ${type} properties:`, err);
      return res.status(500).json({ error: 'Failed to fetch properties' });
    }
    
    console.log(`Found ${results.length} ${type} properties (basic)`);
    res.json(results);
  });
});

module.exports = router;