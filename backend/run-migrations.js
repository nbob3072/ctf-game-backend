#!/usr/bin/env node

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false }
});

async function runMigrations() {
  const client = await pool.connect();
  
  try {
    console.log('🔗 Connected to database');
    
    // Read schema file
    const schemaPath = path.join(__dirname, 'src/db/schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    console.log('📝 Running base schema...');
    await client.query(schema);
    console.log('✅ Base schema complete');
    
    // Read password reset migration
    const passwordResetPath = path.join(__dirname, 'src/db/migrations/add_password_reset.sql');
    if (fs.existsSync(passwordResetPath)) {
      const passwordResetSQL = fs.readFileSync(passwordResetPath, 'utf8');
      console.log('📝 Running password reset migration...');
      await client.query(passwordResetSQL);
      console.log('✅ Password reset migration complete');
    }
    
    console.log('\n✅ All migrations completed successfully!');
    
  } catch (error) {
    console.error('❌ Migration error:', error.message);
    console.error(error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

runMigrations();
