const { Pool } = require('pg');
require('dotenv').config();

// Elindeki postgresql://... linkini kullanıyoruz
const connectionString = process.env.SUPABASE_URL; 

if (!connectionString) {
  throw new Error('Missing SUPABASE_URL in .env file.');
}

const pool = new Pool({
  connectionString: connectionString,
});

const testConnection = async () => {
  try {
    const client = await pool.connect();
    console.log(' PostgreSQL Veritabanına Başarıyla Bağlanıldı');
    client.release();
    return true;
  } catch (error) {
    console.error(' Bağlantı hatası:', error.message);
    return false;
  }
};

// 'supabase' yerine 'pool' objesini dışarı aktarıyoruz
module.exports = { pool, testConnection };