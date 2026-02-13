const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'ctf_game',
  user: 'bob',
  password: 'postgres'
});

const flags = [
  // Additional Princeton flags (7 more)
  {name: 'Marquand Park', desc: 'Arboretum and garden preserve', lat: 40.3323, lon: -74.6567, city: 'Princeton, NJ'},
  {name: 'Princeton University Chapel', desc: 'Gothic revival architecture', lat: 40.3469, lon: -74.6553, city: 'Princeton, NJ'},
  {name: 'Prospect House', desc: 'Historic university mansion', lat: 40.3478, lon: -74.6612, city: 'Princeton, NJ'},
  {name: 'Delaware & Raritan Canal', desc: 'Historic towpath trail', lat: 40.3389, lon: -74.6523, city: 'Princeton, NJ'},
  {name: 'Stony Brook Park', desc: 'Nature trails and stream', lat: 40.3645, lon: -74.6734, city: 'Princeton, NJ'},
  {name: 'Princeton Station', desc: 'Historic train depot', lat: 40.3193, lon: -74.6556, city: 'Princeton, NJ'},
  {name: 'Mountain Lakes Preserve', desc: 'Nature reserve and trails', lat: 40.3756, lon: -74.6845, city: 'Princeton, NJ'}
];

async function addFlags() {
  const client = await pool.connect();
  try {
    let added = 0;
    for (const flag of flags) {
      const result = await client.query(
        `INSERT INTO flags (name, description, location, latitude, longitude, points, city, difficulty, is_active) 
         VALUES ($1, $2, ST_SetSRID(ST_MakePoint($4, $3), 4326)::geography, $3, $4, 100, $5, 'medium', true) 
         RETURNING id, name`,
        [flag.name, flag.desc, flag.lat, flag.lon, flag.city]
      );
      console.log(`✓ ${flag.name} (ID: ${result.rows[0].id})`);
      added++;
    }
    console.log(`\n🎯 Successfully added ${added} more Princeton flags!`);
    
    // Count Princeton flags
    const count = await client.query("SELECT COUNT(*) FROM flags WHERE city = 'Princeton, NJ'");
    console.log(`📊 Total Princeton flags: ${count.rows[0].count}`);
    
    // Count total flags
    const total = await client.query('SELECT COUNT(*) FROM flags');
    console.log(`📊 Total flags in database: ${total.rows[0].count}`);
  } finally {
    client.release();
    await pool.end();
  }
}

addFlags().catch(console.error);
