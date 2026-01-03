const { pool } = require('../config/supabaseClient');

// @desc    Get all appointments for logged in user
// @route   GET /api/appointments
// @access  Private
exports.getAppointments = async (req, res) => {
  try {
    const appointmentsResult = await pool.query(
      'SELECT * FROM appointments WHERE user_id = $1 ORDER BY date ASC',
      [req.user.id]
    );

    const appointments = appointmentsResult.rows || [];

    res.status(200).json({
      success: true,
      count: appointments.length,
      data: {
        appointments: appointments,
      },
    });
  } catch (error) {
    console.error('Get appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Get single appointment
// @route   GET /api/appointments/:id
// @access  Private
// exports.getAppointment = async (req, res) => {
//   try {
//     const appointmentResult = await pool.query(
//       'SELECT * FROM appointments WHERE id = $1',
//       [req.params.id]
//     );

//     if (appointmentResult.rows.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: 'Appointment not found',
//       });
//     }

//     const appointment = appointmentResult.rows[0];

//     // Check if user owns the appointment or is admin/manager
//     if (
//       appointment.user_id !== req.user.id &&
//       req.user.role !== 'admin' &&
//       req.user.role !== 'manager'
//     ) {
//       return res.status(403).json({
//         success: false,
//         message: 'Not authorized to access this appointment',
//       });
//     }

//     res.status(200).json({
//       success: true,
//       data: {
//         appointment,
//       },
//     });
//   } catch (error) {
//     console.error('Get appointment error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Create new appointment
// @route   POST /api/appointments
// @access  Private

exports.createAppointment = async (req, res) => {
  try {
    const { doctor, service, date, time, notes, department, duration } = req.body;
    
    // JWT Token'dan gelen kullanıcı ID'si
    const userId = req.user.id; 

    // 1. Çakışma Kontrolü 
    // date::date kullanımı TIMESTAMP sütunundaki sadece gün kısmını alır
    const collisionCheck = await pool.query(
      "SELECT id FROM appointments WHERE doctor = $1 AND date::date = $2 AND time = $3 AND status NOT IN ('Cancelled')",
      [doctor, date, time]
    );

    if (collisionCheck.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Bu doktorun belirtilen saatte randevusu bulunmaktadır.' });
    }

    // 2. Tablo yapına uygun INSERT sorgusu
    const newAppointment = await pool.query(
      `INSERT INTO appointments 
        (user_id, doctor, service, date, time, status, notes, department, duration)
       VALUES 
        ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        userId,           // user_id (UUID)
        doctor,           // doctor (VARCHAR)
        service,          // service (VARCHAR)
        date,             // date (TIMESTAMP - '2025-12-28' formatı kabul edilir)
        time,             // time (VARCHAR - '09:00')
        'Confirmed',      // status (VARCHAR)
        notes || null,    // notes (TEXT)
        department || null, // department (VARCHAR)
        duration || 60    // duration (INTEGER)
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Randevu başarıyla kaydedildi.',
      data: newAppointment.rows[0]
    });

  } catch (error) {
    console.error('Kayıt Hatası:', error);
    res.status(500).json({ success: false, message: 'Sunucu hatası', error: error.message });
  }
};

// @desc    Get all doctors with their specialization (service type)
// @route   GET /api/appointments/doctors/all
// @access  Private
exports.getAllDoctors = async (req, res) => {
  try {
    // Sadece isim değil, uzmanlık alanını (specialization) da çekiyoruz
    const doctorsResult = await pool.query(
      'SELECT full_name, specialization FROM doctors ORDER BY specialization ASC'
    );

    // Veriyi [ {full_name: "...", specialization: "..."}, ... ] formatında döndürüyoruz
    const doctors = doctorsResult.rows;

    res.status(200).json({ 
      success: true, 
      count: doctors.length,
      data: doctors 
    });
  } catch (error) {
    console.error('Get all doctors error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Server Error', 
      error: error.message 
    });
  }
};

// exports.getTodaysDoctorAppointments = async (req, res) => {
//   try {
//     const doctorId = req.user.id; // Token'dan gelen doktor ID'si

//     // Önce giriş yapan kullanıcının adını al (Randevular tablosunda isimle eşleşiyor)
//     const doctorUser = await pool.query('SELECT first_name, last_name FROM users WHERE id = $1', [doctorId]);
//     const doctorFullName = `${doctorUser.rows[0].first_name} ${doctorUser.rows[0].last_name}`;

//     // Bugünün randevularını kullanıcı (hasta) isimleriyle birlikte getir
//     const query = `
//       SELECT a.id, a.time, a.status, a.service, 
//              u.first_name || ' ' || u.last_name as user_name
//       FROM appointments a
//       JOIN users u ON a.user_id = u.id
//       WHERE a.doctor = $1 
//       AND a.date::date = CURRENT_DATE 
//       AND a.status != 'Cancelled'
//       ORDER BY a.time ASC`;

//     const result = await pool.query(query, [doctorFullName]);

//     res.status(200).json({
//       success: true,
//       count: result.rows.length,
//       appointments: result.rows
//     });
//   } catch (error) {
//     res.status(500).json({ success: false, message: 'Server Error', error: error.message });
//   }
// };

// exports.getDoctorSchedule = async (req, res) => {
//   try {
//     const doctorId = req.user.id;
//     const doctorUser = await pool.query('SELECT first_name, last_name FROM users WHERE id = $1', [doctorId]);
//     const doctorFullName = `${doctorUser.rows[0].first_name} ${doctorUser.rows[0].last_name}`;

//     const query = `
//       SELECT a.*, u.first_name || ' ' || u.last_name as user_name
//       FROM appointments a
//       JOIN users u ON a.user_id = u.id
//       WHERE a.doctor = $1
//       ORDER BY a.date DESC, a.time ASC`;

//     const result = await pool.query(query, [doctorFullName]);

//     res.status(200).json({
//       success: true,
//       data: result.rows
//     });
//   } catch (error) {
//     res.status(500).json({ success: false, message: 'Server Error' });
//   }
// };

// exports.updateAppointmentStatus = async (req, res) => {
//   try {
//     const { id } = req.params; // Randevu ID'si
//     const { status } = req.body; // Yeni durum: 'Completed', 'Cancelled' vb.

//     const result = await pool.query(
//       'UPDATE appointments SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
//       [status, id]
//     );

//     if (result.rows.length === 0) {
//       return res.status(404).json({ success: false, message: 'Appointment not found' });
//     }

//     res.status(200).json({ success: true, data: result.rows[0] });
//   } catch (error) {
//     res.status(500).json({ success: false, message: 'Update failed' });
//   }
// };

exports.getTodaysDoctorAppointments = async (req, res) => {
  try {
    const doctorId = req.user.id; //

    // 1. Doktorun adını al (image_7972cc.png'deki first_name, last_name sütunları)
    const doctorUser = await pool.query(
      'SELECT first_name, last_name FROM users WHERE id = $1', 
      [doctorId]
    );

    if (doctorUser.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Doktor bilgisi bulunamadı' });
    }

    const doctorFullName = `${doctorUser.rows[0].first_name} ${doctorUser.rows[0].last_name}`;

    // 2. JOIN sorgusu: u.id ve a.user_id ikisi de int8 olduğu için doğrudan eşleşir
    const query = `
      SELECT a.id, a.time, a.status, a.service, a.notes,
             u.first_name || ' ' || u.last_name as user_name
      FROM appointments a
      JOIN users u ON a.user_id = u.id
      WHERE a.doctor ILIKE $1 
      AND a.date::date = CURRENT_DATE 
      AND a.status != 'Cancelled'
      ORDER BY a.time ASC`;

    // ILIKE kullanarak isimdeki küçük farkları (örn: Dr. eki gibi) tolere ediyoruz
    const result = await pool.query(query, [`%${doctorFullName}%`]);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      appointments: result.rows
    });
  } catch (error) {
    console.error('getTodaysDoctorAppointments error:', error);
    res.status(500).json({ success: false, message: 'Server Error', error: error.message });
  }
};

exports.getDoctorSchedule = async (req, res) => {
  try {
    const doctorId = req.user.id;
    const doctorUser = await pool.query(
      'SELECT first_name, last_name FROM users WHERE id = $1', 
      [doctorId]
    );
    
    const doctorFullName = `${doctorUser.rows[0].first_name} ${doctorUser.rows[0].last_name}`;

    const query = `
      SELECT a.*, u.first_name || ' ' || u.last_name as user_name
      FROM appointments a
      JOIN users u ON a.user_id = u.id
      WHERE a.doctor ILIKE $1
      ORDER BY a.date DESC, a.time ASC`;

    const result = await pool.query(query, [`%${doctorFullName}%`]);

    res.status(200).json({
      success: true,
      data: result.rows
    });
  } catch (error) {
    console.error('getDoctorSchedule error:', error);
    res.status(500).json({ success: false, message: 'Server Error', error: error.message });
  }
};

// exports.updateAppointmentStatus = async (req, res) => {
//   try {
//     const { id } = req.params; // appointments tablosundaki id (UUID)
//     const { status } = req.body; // 'Completed', 'Cancelled', 'Confirmed'

//     const result = await pool.query(
//       'UPDATE appointments SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
//       [status, id]
//     );

//     if (result.rows.length === 0) {
//       return res.status(404).json({ success: false, message: 'Randevu bulunamadı' });
//     }

//     res.status(200).json({ 
//       success: true, 
//       message: 'Randevu durumu güncellendi', 
//       data: result.rows[0] 
//     });
//   } catch (error) {
//     console.error('updateAppointmentStatus error:', error);
//     res.status(500).json({ success: false, message: 'Güncelleme başarısız', error: error.message });
//   }
// };

// @desc    Randevu durumunu güncelle (Completed, Cancelled vb.)
// @route   PUT /api/appointments/doctor/:id
exports.updateAppointmentStatus = async (req, res) => {
  try {
    const { id } = req.params; // Randevunun UUID'si
    const { status } = req.body; // Flutter'dan gelen 'Completed' veya 'Cancelled' değeri

    // Status değerini güncelle ve güncellenen satırı geri dön
    const result = await pool.query(
      'UPDATE appointments SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Randevu bulunamadı' });
    }

    res.status(200).json({
      success: true,
      message: `Randevu durumu ${status} olarak güncellendi`,
      data: result.rows[0]
    });
  } catch (error) {
    console.error('Update status error:', error);
    res.status(500).json({ success: false, message: 'Güncelleme hatası', error: error.message });
  }
};

// @desc    Doktorun randevu katılım oranını hesaplar
// @route   GET /api/appointments/doctor/attendance-rate
exports.getAttendanceRate = async (req, res) => {
  try {
    const doctorId = req.user.id;

    // Doktorun adını al
    const doctorUser = await pool.query('SELECT first_name, last_name FROM users WHERE id = $1', [doctorId]);
    const doctorFullName = `${doctorUser.rows[0].first_name} ${doctorUser.rows[0].last_name}`;

    // Toplam randevu sayısı ve tamamlanan randevu sayısını al
    const statsQuery = `
      SELECT 
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE status = 'Completed') as completed
      FROM appointments 
      WHERE doctor ILIKE $1`;

    const stats = await pool.query(statsQuery, [`%${doctorFullName}%`]);
    
    const total = parseInt(stats.rows[0].total);
    const completed = parseInt(stats.rows[0].completed);

    // Oran hesapla (Eğer hiç randevu yoksa 0 döndür)
    const rate = total > 0 ? (completed / total * 100).toFixed(1) : 0;

    res.status(200).json({
      success: true,
      attendanceRate: rate
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Oran hesaplanamadı', error: error.message });
  }
};

exports.getDoctorsByService = async (req, res) => {
  try {
    const { service } = req.query;

    if (!service) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a service type'
      });
    }

    // Projenin geri kalanıyla uyumlu 'pool' sorgusu
    const doctorsResult = await pool.query(
      'SELECT full_name FROM doctors WHERE specialization = $1',
      [service]
    );

    // Veritabanından gelen satırları sadece isim listesine (String Array) çeviriyoruz
    const doctors = doctorsResult.rows.map(row => row.full_name);

    res.status(200).json({
      success: true,
      data: doctors
    });
  } catch (error) {
    console.error('Get doctors error:', error);
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: error.message
    });
  }
};

// @desc    Update appointment
// @route   PUT /api/appointments/:id
// @access  Private
exports.updateAppointment = async (req, res) => {
  try {
    // First check if appointment exists and user has permission
    const checkResult = await pool.query(
      'SELECT user_id FROM appointments WHERE id = $1',
      [req.params.id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found',
      });
    }

    const existingAppointment = checkResult.rows[0];

    // Check if user owns the appointment or is admin/manager
    if (
      existingAppointment.user_id !== req.user.id &&
      req.user.role !== 'admin' &&
      req.user.role !== 'manager'
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this appointment',
      });
    }

    const { doctor, service, date, time, status, notes, department, duration } =
      req.body;

    // If time or date is being changed, handle booked_slots update
    if (time !== undefined || date !== undefined) {
      const appointmentData = await pool.query(
        'SELECT time, date FROM appointments WHERE id = $1',
        [req.params.id]
      );
      
      if (appointmentData.rows.length > 0) {
        const oldTime = appointmentData.rows[0].time;
        const oldDate = appointmentData.rows[0].date;
        const newTime = time !== undefined ? time : oldTime;
        const newDate = date !== undefined ? date : oldDate;

        // Check if new time slot is already booked
        if (newTime !== oldTime || newDate !== oldDate) {
          const bookedCheckResult = await pool.query(
            `SELECT id FROM booked_slots 
             WHERE time_slot_id IN (SELECT id FROM time_slots WHERE start_time = $1) 
             AND slot_date = $2 
             AND status = 'Booked'
             AND appointment_id != $3`,
            [newTime, newDate, req.params.id]
          );

          if (bookedCheckResult.rows.length > 0) {
            return res.status(400).json({
              success: false,
              message: 'The selected time slot is already booked',
            });
          }

          // Update booked_slots with new time/date
          const newSlotId = await pool.query(
            'SELECT id FROM time_slots WHERE start_time = $1',
            [newTime]
          );

          if (newSlotId.rows.length > 0) {
            await pool.query(
              'UPDATE booked_slots SET time_slot_id = $1, slot_date = $2 WHERE appointment_id = $3',
              [newSlotId.rows[0].id, newDate, req.params.id]
            );
          }
        }
      }
    }

    // Build update query dynamically
    const updateFields = [];
    const updateValues = [];
    let paramCount = 1;

    if (doctor !== undefined) {
      updateFields.push(`doctor = $${paramCount++}`);
      updateValues.push(doctor);
    }
    if (service !== undefined) {
      updateFields.push(`service = $${paramCount++}`);
      updateValues.push(service);
    }
    if (date !== undefined) {
      updateFields.push(`date = $${paramCount++}`);
      updateValues.push(date);
    }
    if (time !== undefined) {
      updateFields.push(`time = $${paramCount++}`);
      updateValues.push(time);
    }
    if (status !== undefined) {
      updateFields.push(`status = $${paramCount++}`);
      updateValues.push(status);
    }
    if (notes !== undefined) {
      updateFields.push(`notes = $${paramCount++}`);
      updateValues.push(notes);
    }
    if (department !== undefined) {
      updateFields.push(`department = $${paramCount++}`);
      updateValues.push(department);
    }
    if (duration !== undefined) {
      updateFields.push(`duration = $${paramCount++}`);
      updateValues.push(duration);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update',
      });
    }

    updateValues.push(req.params.id);
    const updateQuery = `UPDATE appointments SET ${updateFields.join(', ')} WHERE id = $${paramCount} RETURNING *`;

    const appointmentResult = await pool.query(updateQuery, updateValues);

    if (appointmentResult.rows.length === 0) {
      return res.status(500).json({
        success: false,
        message: 'Error updating appointment',
      });
    }

    const appointment = appointmentResult.rows[0];

    res.status(200).json({
      success: true,
      message: 'Appointment updated successfully',
      data: {
        appointment,
      },
    });
  } catch (error) {
    console.error('Update appointment error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// @desc    Delete/Cancel appointment
// @route   DELETE /api/appointments/:id
// // @access  Private
// exports.deleteAppointment = async (req, res) => {
//   try {
//     // First check if appointment exists and user has permission
//     const checkResult = await pool.query(
//       'SELECT user_id FROM appointments WHERE id = $1',
//       [req.params.id]
//     );

//     if (checkResult.rows.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: 'Appointment not found',
//       });
//     }

//     const appointment = checkResult.rows[0];

//     // Check if user owns the appointment or is admin/manager
//     if (
//       appointment.user_id !== req.user.id &&
//       req.user.role !== 'admin' &&
//       req.user.role !== 'manager'
//     ) {
//       return res.status(403).json({
//         success: false,
//         message: 'Not authorized to delete this appointment',
//       });
//     }

//     // Remove the booked slot when appointment is deleted
//     await pool.query(
//       'DELETE FROM booked_slots WHERE appointment_id = $1',
//       [req.params.id]
//     );

//     const deleteResult = await pool.query(
//       'DELETE FROM appointments WHERE id = $1',
//       [req.params.id]
//     );

//     res.status(200).json({
//       success: true,
//       message: 'Appointment deleted successfully',
//     });
//   } catch (error) {
//     console.error('Delete appointment error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Get all appointments (Admin/Manager only)
// @route   GET /api/appointments/all
// @access  Private (Admin/Manager)
exports.getAllAppointments = async (req, res) => {
  try {
    const appointmentsResult = await pool.query(
      'SELECT * FROM appointments ORDER BY date ASC'
    );

    const appointments = appointmentsResult.rows || [];

    res.status(200).json({
      success: true,
      count: appointments.length,
      data: {
        appointments: appointments,
      },
    });
  } catch (error) {
    console.error('Get all appointments error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};