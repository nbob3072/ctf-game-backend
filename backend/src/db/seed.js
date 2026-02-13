const db = require('./index');

async function seed() {
  try {
    console.log('Seeding database with initial data...');
    
    // Insert teams/factions
    await db.query(`
      INSERT INTO teams (name, color, description) VALUES
      ('Titans', '#E74C3C', 'Strength through unity, aggressive expansion'),
      ('Guardians', '#3498DB', 'Protect and defend, honor above all'),
      ('Phantoms', '#2ECC71', 'Speed and stealth, strike from shadows')
      ON CONFLICT (name) DO NOTHING
    `);
    
    // Insert defender types
    await db.query(`
      INSERT INTO defender_types (name, strength, duration_minutes, unlock_level, description) VALUES
      ('Scout Bot', 20, 60, 1, 'Basic defender, lasts 1 hour'),
      ('Sentinel', 50, 120, 5, 'Medium strength, lasts 2 hours'),
      ('Guardian Titan', 80, 240, 10, 'Strong defender, lasts 4 hours'),
      ('Phantom Shadow', 100, 360, 15, 'Elite defender, lasts 6 hours')
      ON CONFLICT DO NOTHING
    `);
    
    // Insert sample flags (San Francisco locations for MVP testing)
    const sampleFlags = [
      { name: 'Golden Gate Park', lat: 37.7694, lng: -122.4862, type: 'common' },
      { name: 'Ferry Building', lat: 37.7955, lng: -122.3937, type: 'common' },
      { name: 'Coit Tower', lat: 37.8024, lng: -122.4058, type: 'rare' },
      { name: 'Alamo Square', lat: 37.7766, lng: -122.4330, type: 'common' },
      { name: 'Golden Gate Bridge', lat: 37.8199, lng: -122.4783, type: 'legendary' },
      { name: 'Fisherman\'s Wharf', lat: 37.8080, lng: -122.4177, type: 'rare' },
      { name: 'Mission Dolores Park', lat: 37.7596, lng: -122.4269, type: 'common' },
      { name: 'Twin Peaks', lat: 37.7544, lng: -122.4477, type: 'rare' },
      { name: 'Chinatown Gate', lat: 37.7908, lng: -122.4056, type: 'common' },
      { name: 'Presidio', lat: 37.7989, lng: -122.4662, type: 'rare' },
    ];
    
    for (const flag of sampleFlags) {
      await db.query(`
        INSERT INTO flags (name, location, latitude, longitude, flag_type)
        VALUES ($1, ST_SetSRID(ST_MakePoint($3, $2), 4326)::geography, $2, $3, $4)
        ON CONFLICT DO NOTHING
      `, [flag.name, flag.lat, flag.lng, flag.type]);
    }
    
    console.log('✅ Database seeded successfully!');
    console.log(`   - 3 teams created`);
    console.log(`   - 4 defender types created`);
    console.log(`   - ${sampleFlags.length} flags created in San Francisco`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

seed();
