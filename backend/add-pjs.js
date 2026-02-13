const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'ctf_game',
  user: 'bob',
  password: 'postgres'
});

const flags = [
  {name: "PJ's Pancake House", desc: 'Classic breakfast and brunch spot', lat: 40.3502, lon: -74.6601, city: 'Princeton, NJ'}
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
    console.log(`\n🎯 Successfully added ${added} flag!`);
    
    const count = await client.query("SELECT COUNT(*) FROM flags WHERE city = 'Princeton, NJ'");
    console.log(`📊 Total Princeton flags: ${count.rows[0].count}`);
    
    const total = await client.query('SELECT COUNT(*) FROM flags');
    console.log(`📊 Total flags in database: ${total.rows[0].count}`);
  } finally {
    client.release();
    await pool.end();
  }
}

addFlags().catch(console.error);
