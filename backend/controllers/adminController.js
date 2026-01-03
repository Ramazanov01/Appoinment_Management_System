const { supabase } = require('../config/supabaseClient');
const bcrypt = require('bcryptjs');
const { pool } = require('../config/supabaseClient');
const nodemailer = require('nodemailer');


exports.createManager = async (req, res) => {
  // Veritabanı bağlantısını transaction için alıyoruz
  const client = await pool.connect();

  try {
    const {
      firstName,
      lastName,
      email,
      password,
      department,
      managerLevel
    } = req.body;

    // 1. Temel Doğrulamalar
    if (!firstName || !lastName || !email || !password || !department) {
      return res.status(400).json({
        success: false,
        message: 'Lütfen tüm zorunlu alanları doldurun.',
      });
    }

    // 2. E-posta Kontrolü
    const userCheck = await client.query('SELECT id FROM users WHERE email = $1', [email.toLowerCase()]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Bu e-posta adresi zaten kayıtlı.' });
    }

    // 3. Şifre Hashleme
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // --- TRANSACTION BAŞLAT ---
    await client.query('BEGIN');

    // 4. USERS Tablosuna Ekleme (Giriş yetkisi için)
    const userQuery = `
      INSERT INTO users (first_name, last_name, email, password, role, department, manager_level, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())
      RETURNING id, first_name, last_name`;

    const userResult = await client.query(userQuery, [
      firstName,
      lastName,
      email.toLowerCase(),
      hashedPassword,
      'manager',
      department,
      managerLevel
    ]);

    const newUser = userResult.rows[0];
    const fullName = `${newUser.first_name} ${newUser.last_name}`;

    // 5. DOCTORS Tablosuna Ekleme (Randevu sisteminde görünmesi için)
    // Tablonuzdaki sütun isimlerine (full_name, specialization) uygun:
    const doctorQuery = `
      INSERT INTO doctors (id, full_name, specialization, created_at)
      VALUES (gen_random_uuid(), $1, $2, NOW())`;

    await client.query(doctorQuery, [fullName, department]);

    // --- TRANSACTION ONAYLA ---
    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Yönetici ve Doktor kaydı başarıyla oluşturuldu.',
      data: {
        userId: newUser.id,
        fullName: fullName
      }
    });

  } catch (error) {
    // Hata durumunda yapılan tüm işlemleri geri al
    await client.query('ROLLBACK');
    console.error('Create Manager & Doctor Error:', error);
    res.status(500).json({
      success: false,
      message: 'İşlem başarısız.',
      error: error.message
    });
  } finally {
    // Bağlantıyı havuza geri bırak
    client.release();
  }
};

exports.getStats = async (req, res) => {
  try {
    // 1. Toplam Kullanıcı ve Yönetici Sayıları
    const userCountsQuery = `
      SELECT 
        COUNT(*) FILTER (WHERE role = 'user') as total_users,
        COUNT(*) FILTER (WHERE role = 'manager') as total_managers
      FROM users`;
    
    // 2. Bugün randevu oluşturan/aktif olan kullanıcılar
    const activeTodayQuery = `
      SELECT COUNT(DISTINCT user_id) as active_today 
      FROM appointments 
      WHERE created_at::date = CURRENT_DATE`;

    // 3. Bu hafta kayıt olan yeni kullanıcılar
    const newThisWeekQuery = `
      SELECT COUNT(*) as new_this_week 
      FROM users 
      WHERE created_at >= NOW() - INTERVAL '7 days' AND role = 'user'`;

    // Tüm sorguları paralel olarak çalıştıralım
    const [userCounts, activeToday, newThisWeek] = await Promise.all([
      pool.query(userCountsQuery),
      pool.query(activeTodayQuery),
      pool.query(newThisWeekQuery)
    ]);

    // Verileri Flutter'ın beklediği formatta düzenleyelim
    res.status(200).json({
      success: true,
      data: {
        totalUsers: parseInt(userCounts.rows[0].total_users) || 0,
        totalManagers: parseInt(userCounts.rows[0].total_managers) || 0,
        activeToday: parseInt(activeToday.rows[0].active_today) || 0,
        newThisWeek: parseInt(newThisWeek.rows[0].new_this_week) || 0
      },
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Sadece yöneticilere toplu mail gönder
// @route   POST /api/admin/send-manager-email
exports.sendManagerBulkEmail = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ success: false, message: 'Mesaj içeriği boş olamaz' });
    }

    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: false, 
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    // SADECE MANAGER ROLÜNDEKİLERİ ÇEK
    const managersResult = await pool.query("SELECT email FROM users WHERE role = 'manager' AND is_active = true");
    const emails = managersResult.rows.map(row => row.email);

    if (emails.length === 0) {
      return res.status(404).json({ success: false, message: 'Gönderilecek yönetici bulunamadı' });
    }

    const mailOptions = {
      from: `"${process.env.FROM_NAME}" <${process.env.FROM_EMAIL}>`,
      bcc: emails,
      subject: 'Yönetici Bilgilendirmesi (Internal)',
      text: message,
      html: `<div style="font-family: Arial; padding: 20px; background-color: #f9f9f9;">
               <h2 style="color: #9C27B0;">Yönetici Duyurusu</h2>
               <p>${message}</p>
               <br>
               <hr>
               <small>Bu mail sadece sistem yöneticilerine gönderilmiştir.</small>
             </div>`,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({
      success: true,
      message: `${emails.length} yöneticiye başarıyla mail gönderildi.`
    });

  } catch (error) {
    res.status(500).json({ success: false, message: 'Mail gönderimi başarısız', error: error.message });
  }
};

// @desc    Tüm kullanıcılara toplu mail gönder
// @route   POST /api/admin/send-bulk-email
exports.sendBulkEmail = async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ success: false, message: 'Mesaj içeriği boş olamaz' });
    }

    // 1. Mailjet SMTP Taşıyıcısı Oluşturma
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: false, // 587 portu için false
      auth: {
        user: process.env.SMTP_USER, // API Key
        pass: process.env.SMTP_PASS, // Secret Key
      },
    });

    // 2. Tüm kullanıcıların maillerini çek
    const usersResult = await pool.query('SELECT email FROM users WHERE is_active = true');
    const emails = usersResult.rows.map(row => row.email);

    if (emails.length === 0) {
      return res.status(404).json({ success: false, message: 'Gönderilecek kullanıcı bulunamadı' });
    }

    // 3. Mail Seçenekleri (Senin C# kodundaki yapıya uygun)
    const mailOptions = {
      from: `"${process.env.FROM_NAME}" <${process.env.FROM_EMAIL}>`,
      bcc: emails, // Gizli alıcılar (herkes birbirini görmez)
      subject: 'Sistem Bilgilendirmesi',
      html: `
        <div style="font-family: sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #2196F3;">Yeni Duyuru</h2>
          <p>${message}</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          <small>Bu e-posta ${process.env.FROM_NAME} tarafından gönderilmiştir.</small>
        </div>
      `,
    };

    // 4. Gönderim İşlemi
    await transporter.sendMail(mailOptions);

    res.status(200).json({
      success: true,
      message: `${emails.length} kullanıcıya başarıyla mail gönderildi.`
    });

  } catch (error) {
    console.error('Mailjet Bulk Email Error:', error);
    res.status(500).json({ success: false, message: 'Mail gönderimi başarısız', error: error.message });
  }
};

// @desc    Tüm managerları listele
exports.getAllManagers = async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, first_name, last_name, email, department, manager_level FROM users WHERE role = 'manager' ORDER BY created_at DESC"
    );
    res.status(200).json({ success: true, data: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.deleteManager = async (req, res) => {
  const client = await pool.connect();
  try {
    const { id } = req.params;
    await client.query('BEGIN');

    // 1. Önce users tablosundan silinecek kişinin adını ve soyadını alalım
    const userResult = await client.query(
      "SELECT first_name, last_name FROM users WHERE id = $1", 
      [id]
    );

    if (userResult.rows.length > 0) {
      const { first_name, last_name } = userResult.rows[0];
      const fullName = `${first_name} ${last_name}`;

      // 2. Doctors tablosundan isim eşleşmesiyle sil
      await client.query("DELETE FROM doctors WHERE full_name = $1", [fullName]);
    }

    // 3. Users tablosundan yöneticiyi sil
    const deleteResult = await client.query(
      "DELETE FROM users WHERE id = $1 AND role = 'manager' RETURNING id", 
      [id]
    );

    if (deleteResult.rowCount === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ success: false, message: 'Manager not found' });
    }

    await client.query('COMMIT');
    res.status(200).json({ success: true, message: 'Manager and doctor record deleted successfully' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Delete Manager Error Details:', error);
    res.status(500).json({ success: false, error: error.message });
  } finally {
    client.release();
  }
};