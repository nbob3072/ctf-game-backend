const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'ctf_game',
  user: 'bob',
  password: 'postgres'
});

const flags = [
  // Lambertville, NJ (5 flags)
  {name: 'Bridge Street Books', desc: 'Historic bookstore in charming river town', lat: 40.3659, lon: -74.9429, city: 'Lambertville, NJ'},
  {name: 'Delaware River Towpath', desc: 'Scenic canal path along the Delaware', lat: 40.3698, lon: -74.9445, city: 'Lambertville, NJ'},
  {name: 'Lambertville Station', desc: 'Historic train station turned restaurant', lat: 40.3642, lon: -74.9421, city: 'Lambertville, NJ'},
  {name: 'Golden Nugget Market', desc: 'Treasure hunters paradise', lat: 40.3625, lon: -74.9438, city: 'Lambertville, NJ'},
  {name: 'Coryell Street Art', desc: 'Gallery district hub', lat: 40.3668, lon: -74.9412, city: 'Lambertville, NJ'},
  
  // Princeton, NJ (7 flags)
  {name: 'Nassau Hall', desc: 'Historic Princeton University building', lat: 40.3487, lon: -74.6594, city: 'Princeton, NJ'},
  {name: 'Princeton Battlefield', desc: 'Revolutionary War site', lat: 40.3234, lon: -74.6812, city: 'Princeton, NJ'},
  {name: 'Morven Museum', desc: 'Former governors mansion', lat: 40.3456, lon: -74.6589, city: 'Princeton, NJ'},
  {name: 'Palmer Square', desc: 'Downtown Princeton plaza', lat: 40.3498, lon: -74.6598, city: 'Princeton, NJ'},
  {name: 'Princeton Cemetery', desc: 'Historic burial ground', lat: 40.3523, lon: -74.6612, city: 'Princeton, NJ'},
  {name: 'Lake Carnegie', desc: 'Rowing lake and recreation', lat: 40.3412, lon: -74.6234, city: 'Princeton, NJ'},
  {name: 'Institute Woods', desc: 'Nature preserve and trails', lat: 40.3298, lon: -74.6445, city: 'Princeton, NJ'},
  
  // New Brunswick, NJ (7 flags)
  {name: 'Rutgers Old Queens', desc: 'Historic Rutgers building', lat: 40.4998, lon: -74.4459, city: 'New Brunswick, NJ'},
  {name: 'George Street Theater', desc: 'Downtown performance venue', lat: 40.4968, lon: -74.4479, city: 'New Brunswick, NJ'},
  {name: 'New Brunswick Station', desc: 'Major transit hub', lat: 40.4958, lon: -74.4512, city: 'New Brunswick, NJ'},
  {name: 'Buccleuch Park', desc: 'Historic mansion and parkland', lat: 40.4892, lon: -74.4389, city: 'New Brunswick, NJ'},
  {name: 'Zimmerli Art Museum', desc: 'University art collection', lat: 40.4989, lon: -74.4423, city: 'New Brunswick, NJ'},
  {name: 'Johnson Park', desc: 'Riverfront park and trails', lat: 40.4756, lon: -74.4298, city: 'New Brunswick, NJ'},
  {name: 'Landing Lane Park', desc: 'Raritan River access', lat: 40.4912, lon: -74.4234, city: 'New Brunswick, NJ'}
];

async function addFlags() {
  const client = await pool.connect();
  try {
    let added = 0;
    for (const flag of flags) {
      const result = await client.query(
        `INSERT INTO flags (name, description, location, latitude, longitude, points, city, difficulty, is_active) 
         VALUES ($1, $2, ST_SetSRID(ST_MakePoint($4, $3), 4326)::geography, $3, $4, 100, $5, 'medium', true) 
         RETURNING id, name, city`,
        [flag.name, flag.desc, flag.lat, flag.lon, flag.city]
      );
      console.log(`✓ ${flag.city}: ${flag.name} (ID: ${result.rows[0].id})`);
      added++;
    }
    console.log(`\n🎯 Successfully added ${added} flags!`);
    console.log(`   • Lambertville, NJ: 5 flags`);
    console.log(`   • Princeton, NJ: 7 flags`);
    console.log(`   • New Brunswick, NJ: 7 flags`);
    
    // Count total flags
    const count = await client.query('SELECT COUNT(*) FROM flags');
    console.log(`\n📊 Total flags in database: ${count.rows[0].count}`);
  } finally {
    client.release();
    await pool.end();
  }
}

addFlags().catch(console.error);
