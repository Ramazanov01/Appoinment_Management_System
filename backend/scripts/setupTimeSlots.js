const { pool } = require('../config/supabaseClient');
const fs = require('fs');
const path = require('path');

/**
 * Setup Time Slots Tables Script
 * 
 * This script creates the time_slots and booked_slots tables
 * and inserts sample data for working hours.
 * 
 * Usage: node scripts/setupTimeSlots.js
 */

async function setupTimeSlots() {
  let client;
  
  try {
    console.log('🔄 Connecting to database...');
    client = await pool.connect();
    console.log('✅ Connected to database');

    // Check if appointments table exists (required for foreign key)
    console.log('🔍 Checking if appointments table exists...');
    const appointmentsCheck = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'appointments'
      );
    `);
    
    if (!appointmentsCheck.rows[0].exists) {
      console.error('\n❌ Error: appointments table does not exist!');
      console.error('   The booked_slots table requires the appointments table.');
      console.error('   Please run database/schema.sql or create_appointments_table.sql first.');
      process.exit(1);
    }
    console.log('✅ appointments table exists');

    // Read the SQL file
    const sqlFilePath = path.join(__dirname, '../database/create_time_slots_table.sql');
    console.log(`📄 Reading SQL file: ${sqlFilePath}`);
    
    if (!fs.existsSync(sqlFilePath)) {
      throw new Error(`SQL file not found: ${sqlFilePath}`);
    }

    const sql = fs.readFileSync(sqlFilePath, 'utf8');
    
    // Remove comments and split into statements
    // We'll execute the SQL in chunks: CREATE TABLE, CREATE INDEX, INSERT
    console.log('🚀 Creating time_slots table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS time_slots (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        day_of_week VARCHAR(20) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
        start_time VARCHAR(5) NOT NULL,
        end_time VARCHAR(5) NOT NULL,
        is_break BOOLEAN DEFAULT false,
        department VARCHAR(100),
        duration_minutes INTEGER DEFAULT 30,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
    `);
    
    console.log('🚀 Creating booked_slots table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS booked_slots (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
        time_slot_id UUID NOT NULL REFERENCES time_slots(id) ON DELETE CASCADE,
        slot_date DATE NOT NULL,
        status VARCHAR(20) DEFAULT 'Booked' CHECK (status IN ('Booked', 'Completed', 'Cancelled')),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
    `);
    
    console.log('🚀 Creating indexes...');
    await client.query('CREATE INDEX IF NOT EXISTS idx_time_slots_day ON time_slots(day_of_week);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_time_slots_department ON time_slots(department);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_booked_slots_appointment_id ON booked_slots(appointment_id);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_booked_slots_slot_date ON booked_slots(slot_date);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_booked_slots_status ON booked_slots(status);');
    
    // Check if time slots already exist
    const existingCheck = await client.query('SELECT COUNT(*) as count FROM time_slots');
    if (existingCheck.rows[0].count > 0) {
      console.log('⚠️  Time slots already exist. Skipping data insertion.');
    } else {
      console.log('🚀 Inserting sample time slots data...');
      await client.query(`
        INSERT INTO time_slots (day_of_week, start_time, end_time, is_break, duration_minutes, is_active)
        VALUES
          ('Monday', '09:00', '10:00', false, 30, true),
          ('Monday', '10:00', '11:00', false, 30, true),
          ('Monday', '11:00', '12:00', false, 30, true),
          ('Monday', '12:00', '13:00', true, 60, true),
          ('Monday', '13:00', '14:00', false, 30, true),
          ('Monday', '14:00', '15:00', false, 30, true),
          ('Monday', '15:00', '16:00', false, 30, true),
          ('Monday', '16:00', '17:00', false, 30, true),
          ('Tuesday', '09:00', '10:00', false, 30, true),
          ('Tuesday', '10:00', '11:00', false, 30, true),
          ('Tuesday', '11:00', '12:00', false, 30, true),
          ('Tuesday', '12:00', '13:00', true, 60, true),
          ('Tuesday', '13:00', '14:00', false, 30, true),
          ('Tuesday', '14:00', '15:00', false, 30, true),
          ('Tuesday', '15:00', '16:00', false, 30, true),
          ('Tuesday', '16:00', '17:00', false, 30, true),
          ('Wednesday', '09:00', '10:00', false, 30, true),
          ('Wednesday', '10:00', '11:00', false, 30, true),
          ('Wednesday', '11:00', '12:00', false, 30, true),
          ('Wednesday', '12:00', '13:00', true, 60, true),
          ('Wednesday', '13:00', '14:00', false, 30, true),
          ('Wednesday', '14:00', '15:00', false, 30, true),
          ('Wednesday', '15:00', '16:00', false, 30, true),
          ('Wednesday', '16:00', '17:00', false, 30, true),
          ('Thursday', '09:00', '10:00', false, 30, true),
          ('Thursday', '10:00', '11:00', false, 30, true),
          ('Thursday', '11:00', '12:00', false, 30, true),
          ('Thursday', '12:00', '13:00', true, 60, true),
          ('Thursday', '13:00', '14:00', false, 30, true),
          ('Thursday', '14:00', '15:00', false, 30, true),
          ('Thursday', '15:00', '16:00', false, 30, true),
          ('Thursday', '16:00', '17:00', false, 30, true),
          ('Friday', '09:00', '10:00', false, 30, true),
          ('Friday', '10:00', '11:00', false, 30, true),
          ('Friday', '11:00', '12:00', false, 30, true),
          ('Friday', '12:00', '13:00', true, 60, true),
          ('Friday', '13:00', '14:00', false, 30, true),
          ('Friday', '14:00', '15:00', false, 30, true),
          ('Friday', '15:00', '16:00', false, 30, true),
          ('Friday', '16:00', '17:00', false, 30, true);
      `);
    }
    
    console.log('✅ Successfully created time_slots and booked_slots tables');
    console.log('✅ Sample time slots data inserted');
    
    // Verify tables were created
    console.log('\n📊 Verifying tables...');
    
    const timeSlotsCheck = await client.query(
      'SELECT COUNT(*) as count FROM time_slots'
    );
    console.log(`   ✅ time_slots table: ${timeSlotsCheck.rows[0].count} rows`);
    
    const bookedSlotsCheck = await client.query(
      'SELECT COUNT(*) as count FROM booked_slots'
    );
    console.log(`   ✅ booked_slots table: ${bookedSlotsCheck.rows[0].count} rows`);
    
    // Show sample data
    const sampleSlots = await client.query(
      `SELECT day_of_week, start_time, end_time, is_break 
       FROM time_slots 
       WHERE day_of_week = 'Monday' 
       ORDER BY start_time 
       LIMIT 5`
    );
    
    console.log('\n📅 Sample Monday time slots:');
    sampleSlots.rows.forEach(slot => {
      const breakText = slot.is_break ? ' (BREAK)' : '';
      console.log(`   - ${slot.start_time} - ${slot.end_time}${breakText}`);
    });
    
    console.log('\n✅ Setup completed successfully!');
    console.log('🎉 You can now use the time slots API endpoints.');
    
  } catch (error) {
    console.error('\n❌ Error setting up time slots:');
    console.error('   Message:', error.message);
    console.error('   Code:', error.code);
    
    if (error.code === '42P01') {
      console.error('\n💡 Tip: Make sure the appointments table exists first.');
      console.error('   The booked_slots table references appointments(id).');
      console.error('   Run database/schema.sql or create_appointments_table.sql first.');
    } else if (error.code === '23503') {
      console.error('\n💡 Tip: Foreign key constraint failed.');
      console.error('   Make sure the appointments table exists.');
    } else if (error.message.includes('already exists') || error.code === '42P07') {
      console.error('\n💡 Tip: Some tables already exist. This is OK!');
      console.error('   The script uses CREATE TABLE IF NOT EXISTS.');
    }
    
    process.exit(1);
  } finally {
    if (client) {
      client.release();
    }
    await pool.end();
  }
}

// Run the setup
setupTimeSlots();

