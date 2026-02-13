const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'ctf_game',
  user: 'bob',
  password: 'postgres'
});

const flags = [
  // Specific Princeton locations requested
  {name: 'Princeton Public Library', desc: 'Community library and cultural center', lat: 40.3497, lon: -74.6585, city: 'Princeton, NJ'},
  {name: 'Nomad Pizza', desc: 'Wood-fired artisan pizza', lat: 40.3519, lon: -74.6573, city: 'Princeton, NJ'},
  {name: 'The Bent Spoon', desc: 'Artisan ice cream and confections', lat: 40.3497, lon: -74.6592, city: 'Princeton, NJ'}
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
    console.log(`\n🎯 Successfully added ${added} Princeton flags!`);
    
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
