const { pool } = require('../config/supabaseClient');

// @desc    Get all available time slots
// @route   GET /api/time-slots
// // @access  Public
// exports.getTimeSlots = async (req, res) => {
//   try {
//     const result = await pool.query(
//       `SELECT * FROM time_slots WHERE is_active = true ORDER BY 
//        CASE 
//          WHEN day_of_week = 'Monday' THEN 1
//          WHEN day_of_week = 'Tuesday' THEN 2
//          WHEN day_of_week = 'Wednesday' THEN 3
//          WHEN day_of_week = 'Thursday' THEN 4
//          WHEN day_of_week = 'Friday' THEN 5
//          WHEN day_of_week = 'Saturday' THEN 6
//          WHEN day_of_week = 'Sunday' THEN 7
//        END, start_time`
//     );

//     res.status(200).json({
//       success: true,
//       count: result.rows.length,
//       data: {
//         timeSlots: result.rows,
//       },
//     });
//   } catch (error) {
//     console.error('Get time slots error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Get available time slots for a specific date
// @route   GET /api/time-slots/available/:date
// // @access  Public
// exports.getAvailableSlotsByDate = async (req, res) => {
//   try {
//     const { date } = req.params;
    
//     // Validate date format (YYYY-MM-DD)
//     if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
//       return res.status(400).json({
//         success: false,
//         message: 'Invalid date format. Use YYYY-MM-DD',
//       });
//     }

//     // Get day of week from the date
//     const dateObj = new Date(date + 'T00:00:00Z');
//     const dayOfWeek = dateObj.toLocaleDateString('en-US', { weekday: 'long' });

//     // Get time slots for that day of week
//     const slotsResult = await pool.query(
//       `SELECT * FROM time_slots 
//        WHERE day_of_week = $1 AND is_active = true 
//        ORDER BY start_time`,
//       [dayOfWeek]
//     );

//     const timeSlots = slotsResult.rows || [];

//     // Get booked slots for that specific date
//     const bookedResult = await pool.query(
//       `SELECT bs.*, ts.start_time, ts.end_time 
//        FROM booked_slots bs
//        JOIN time_slots ts ON bs.time_slot_id = ts.id
//        WHERE bs.slot_date = $1 AND bs.status = 'Booked'`,
//       [date]
//     );

//     const bookedSlots = bookedResult.rows || [];

//     // Mark which slots are available
//     const availableSlots = timeSlots.map(slot => {
//       const isBooked = bookedSlots.some(booked => booked.time_slot_id === slot.id);
//       return {
//         ...slot,
//         available: !isBooked,
//         is_break: slot.is_break || false,
//       };
//     });

//     res.status(200).json({
//       success: true,
//       count: availableSlots.length,
//       data: {
//         date,
//         dayOfWeek,
//         timeSlots: availableSlots,
//         bookedCount: bookedSlots.length,
//       },
//     });
//   } catch (error) {
//     console.error('Get available slots error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Get available hours for a date range
// @route   GET /api/time-slots/available-range
// // @access  Public
// exports.getAvailableSlotsRange = async (req, res) => {
//   try {
//     const { startDate, endDate } = req.query;

//     if (!startDate || !endDate) {
//       return res.status(400).json({
//         success: false,
//         message: 'startDate and endDate are required',
//       });
//     }

//     // Get all time slots
//     const slotsResult = await pool.query(
//       `SELECT * FROM time_slots WHERE is_active = true`
//     );

//     const timeSlots = slotsResult.rows || [];

//     // Get all booked slots in the date range
//     const bookedResult = await pool.query(
//       `SELECT bs.* FROM booked_slots bs
//        WHERE bs.slot_date >= $1 AND bs.slot_date <= $2 AND bs.status = 'Booked'`,
//       [startDate, endDate]
//     );

//     const bookedSlots = bookedResult.rows || [];

//     // Build availability map
//     const availabilityMap = {};
    
//     // Initialize all dates in range
//     const start = new Date(startDate);
//     const end = new Date(endDate);
    
//     for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
//       const dateStr = d.toISOString().split('T')[0];
//       const dayOfWeek = d.toLocaleDateString('en-US', { weekday: 'long' });
      
//       const daySlots = timeSlots.filter(slot => slot.day_of_week === dayOfWeek);
      
//       availabilityMap[dateStr] = daySlots.map(slot => {
//         const isBooked = bookedSlots.some(
//           booked => booked.time_slot_id === slot.id && booked.slot_date === dateStr
//         );
//         return {
//           ...slot,
//           available: !isBooked,
//         };
//       });
//     }

//     res.status(200).json({
//       success: true,
//       data: {
//         startDate,
//         endDate,
//         availability: availabilityMap,
//       },
//     });
//   } catch (error) {
//     console.error('Get available slots range error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Check if a specific time slot is available
// @route   POST /api/time-slots/check-availability
// // @access  Public
// exports.checkSlotAvailability = async (req, res) => {
//   try {
//     const { slotDate, slotTime } = req.body;

//     if (!slotDate || !slotTime) {
//       return res.status(400).json({
//         success: false,
//         message: 'slotDate and slotTime are required',
//       });
//     }

//     // Get the time slot
//     const slotResult = await pool.query(
//       `SELECT * FROM time_slots WHERE start_time = $1 AND is_active = true LIMIT 1`,
//       [slotTime]
//     );

//     if (slotResult.rows.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: 'Time slot not found',
//       });
//     }

//     const timeSlot = slotResult.rows[0];

//     // Check if this slot is already booked for the given date
//     const bookedResult = await pool.query(
//       `SELECT * FROM booked_slots 
//        WHERE time_slot_id = $1 AND slot_date = $2 AND status = 'Booked'`,
//       [timeSlot.id, slotDate]
//     );

//     const isAvailable = bookedResult.rows.length === 0;

//     res.status(200).json({
//       success: true,
//       data: {
//         slotDate,
//         slotTime,
//         timeSlotId: timeSlot.id,
//         available: isAvailable,
//         timeSlot: {
//           startTime: timeSlot.start_time,
//           endTime: timeSlot.end_time,
//           isBreak: timeSlot.is_break,
//           duration: timeSlot.duration_minutes,
//         },
//       },
//     });
//   } catch (error) {
//     console.error('Check slot availability error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Create a new time slot
// @route   POST /api/time-slots
// // @access  Private (Admin/Manager only)
// exports.createTimeSlot = async (req, res) => {
//   try {
//     // Check if user is admin or manager
//     if (req.user.role !== 'admin' && req.user.role !== 'manager') {
//       return res.status(403).json({
//         success: false,
//         message: 'Not authorized to create time slots',
//       });
//     }

//     const { dayOfWeek, startTime, endTime, isBreak, department, durationMinutes } = req.body;

//     if (!dayOfWeek || !startTime || !endTime) {
//       return res.status(400).json({
//         success: false,
//         message: 'dayOfWeek, startTime, and endTime are required',
//       });
//     }

//     const result = await pool.query(
//       `INSERT INTO time_slots (day_of_week, start_time, end_time, is_break, department, duration_minutes)
//        VALUES ($1, $2, $3, $4, $5, $6)
//        RETURNING *`,
//       [dayOfWeek, startTime, endTime, isBreak || false, department || null, durationMinutes || 30]
//     );

//     res.status(201).json({
//       success: true,
//       message: 'Time slot created successfully',
//       data: {
//         timeSlot: result.rows[0],
//       },
//     });
//   } catch (error) {
//     console.error('Create time slot error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Update time slot
// @route   PUT /api/time-slots/:id
// // @access  Private (Admin/Manager only)
// exports.updateTimeSlot = async (req, res) => {
//   try {
//     // Check if user is admin or manager
//     if (req.user.role !== 'admin' && req.user.role !== 'manager') {
//       return res.status(403).json({
//         success: false,
//         message: 'Not authorized to update time slots',
//       });
//     }

//     const { id } = req.params;
//     const { dayOfWeek, startTime, endTime, isBreak, department, durationMinutes, isActive } = req.body;

//     const updateFields = [];
//     const updateValues = [];
//     let paramCount = 1;

//     if (dayOfWeek !== undefined) {
//       updateFields.push(`day_of_week = $${paramCount++}`);
//       updateValues.push(dayOfWeek);
//     }
//     if (startTime !== undefined) {
//       updateFields.push(`start_time = $${paramCount++}`);
//       updateValues.push(startTime);
//     }
//     if (endTime !== undefined) {
//       updateFields.push(`end_time = $${paramCount++}`);
//       updateValues.push(endTime);
//     }
//     if (isBreak !== undefined) {
//       updateFields.push(`is_break = $${paramCount++}`);
//       updateValues.push(isBreak);
//     }
//     if (department !== undefined) {
//       updateFields.push(`department = $${paramCount++}`);
//       updateValues.push(department);
//     }
//     if (durationMinutes !== undefined) {
//       updateFields.push(`duration_minutes = $${paramCount++}`);
//       updateValues.push(durationMinutes);
//     }
//     if (isActive !== undefined) {
//       updateFields.push(`is_active = $${paramCount++}`);
//       updateValues.push(isActive);
//     }

//     if (updateFields.length === 0) {
//       return res.status(400).json({
//         success: false,
//         message: 'No fields to update',
//       });
//     }

//     updateValues.push(id);
//     const updateQuery = `UPDATE time_slots SET ${updateFields.join(', ')} WHERE id = $${paramCount} RETURNING *`;

//     const result = await pool.query(updateQuery, updateValues);

//     if (result.rows.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: 'Time slot not found',
//       });
//     }

//     res.status(200).json({
//       success: true,
//       message: 'Time slot updated successfully',
//       data: {
//         timeSlot: result.rows[0],
//       },
//     });
//   } catch (error) {
//     console.error('Update time slot error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Delete time slot
// @route   DELETE /api/time-slots/:id
// // @access  Private (Admin/Manager only)
// exports.deleteTimeSlot = async (req, res) => {
//   try {
//     // Check if user is admin or manager
//     if (req.user.role !== 'admin' && req.user.role !== 'manager') {
//       return res.status(403).json({
//         success: false,
//         message: 'Not authorized to delete time slots',
//       });
//     }

//     const { id } = req.params;

//     const result = await pool.query(
//       'DELETE FROM time_slots WHERE id = $1 RETURNING *',
//       [id]
//     );

//     if (result.rows.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: 'Time slot not found',
//       });
//     }

//     res.status(200).json({
//       success: true,
//       message: 'Time slot deleted successfully',
//     });
//   } catch (error) {
//     console.error('Delete time slot error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Get filtered available hours for a doctor on a specific date
// @route   GET /api/time-slots/available-hours?date=2025-12-28&doctor=Dr. Ahmet
// @access  Private
exports.getAvailableHours = async (req, res) => {
  try {
    const { date, doctor } = req.query;

    if (!date || !doctor) {
      return res.status(400).json({
        success: false,
        message: 'Date and Doctor are required',
      });
    }

    // 1. O günkü dolu randevuları getir (İptal edilmemiş olanlar)
    const bookedResult = await pool.query(
      "SELECT time FROM appointments WHERE date::date = $1 AND doctor = $2 AND status != 'Cancelled'",
      [date, doctor]
    );

    // Dolu saatleri formatla (Örn: "09:00:00" -> "09:00")
    const bookedTimes = bookedResult.rows.map((row) => row.time.substring(0, 5));

    // 2. Çalışma saatlerini oluştur (09:00 - 17:00 arası her saat başı)
    const startHour = 9;
    const endHour = 17;
    const lunchHour = 12; // 12:00 - 13:00 arası mola
    const availableSlots = [];

    for (let hour = startHour; hour < endHour; hour++) {
      if (hour === lunchHour) continue; // Molayı atla

      const timeString = `${hour.toString().padStart(2, '0')}:00`;

      availableSlots.push({
        time: timeString,
        // Eğer o saatte randevu varsa available: false döner
        available: !bookedTimes.includes(timeString),
      });
    }

    res.status(200).json({
      success: true,
      data: availableSlots,
    });
  } catch (error) {
    console.error('Get available hours error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};