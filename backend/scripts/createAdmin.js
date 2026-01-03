// Script to create an admin user
// Run this with: node backend/scripts/createAdmin.js

const { pool } = require('../config/supabaseClient');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const createAdmin = async () => {
  try {
    const firstName = 'Admin';
    const lastName = 'User';
    const email = 'admin@example.com';
    const password = 'admin123'; // Change this to your desired password
    const role = 'admin';

    // Check if admin already exists
    const checkResult = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    if (checkResult.rows.length > 0) {
      console.log('❌ Admin user already exists with email:', email);
      return;
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insert admin user
    const result = await pool.query(
      `INSERT INTO users (first_name, last_name, email, password, role, is_active)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, first_name, last_name, email, role`,
      [firstName, lastName, email.toLowerCase(), hashedPassword, role, true]
    );

    const admin = result.rows[0];
    console.log('✅ Admin user created successfully!');
    console.log('   ID:', admin.id);
    console.log('   Name:', `${admin.first_name} ${admin.last_name}`);
    console.log('   Email:', admin.email);
    console.log('   Role:', admin.role);
    console.log('   Password:', password, '(change this after first login)');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
    process.exit(1);
  }
};

createAdmin();

