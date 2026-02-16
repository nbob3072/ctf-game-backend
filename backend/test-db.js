require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function testDatabase() {
  try {
    console.log('Testing database connection...');
    console.log(`Host: ${process.env.DB_HOST}`);
    console.log(`Database: ${process.env.DB_NAME}`);
    
    // Test connection
    const result = await pool.query('SELECT NOW()');
    console.log('✅ Database connected successfully');
    console.log('Server time:', result.rows[0].now);
    
    // Check if teams table exists
    const tablesResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name IN ('teams', 'users', 'flags')
      ORDER BY table_name
    `);
    
    console.log('\n📋 Tables found:');
    tablesResult.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });
    
    // If teams table exists, check for data
    if (tablesResult.rows.some(r => r.table_name === 'teams')) {
      const teamsResult = await pool.query('SELECT * FROM teams ORDER BY id');
      console.log(`\n🎯 Teams in database: ${teamsResult.rows.length}`);
      teamsResult.rows.forEach(team => {
        console.log(`  ${team.id}. ${team.name} (${team.color})`);
      });
    } else {
      console.log('\n❌ Teams table does not exist! Database needs to be initialized.');
    }
    
  } catch (error) {
    console.error('❌ Database error:', error.message);
    console.error('Error details:', error);
  } finally {
    await pool.end();
  }
}

testDatabase();
