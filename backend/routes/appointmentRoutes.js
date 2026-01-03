const express = require('express');
const router = express.Router();
const {
  getAppointments,
  //getAppointment,
  createAppointment,
  //updateAppointment,
  //deleteAppointment,
  getDoctorsByService,
  //getAllAppointments,
  getAllDoctors,
  getTodaysDoctorAppointments,
  getDoctorSchedule,
  updateAppointmentStatus,
  getAttendanceRate
} = require('../controllers/appointmentController');
const { protect, authorize } = require('../middleware/authMiddleware');

// All routes are protected
router.use(protect);

// User routes
router.get('/', getAppointments);
router.post('/', createAppointment);
router.get('/doctors/all', getAllDoctors);
router.get('/doctors', getDoctorsByService);
router.get('/doctor/today', getTodaysDoctorAppointments);
router.get('/doctor/all', getDoctorSchedule);
router.get('/doctor/attendance-rate', getAttendanceRate);
router.put('/doctor/:id', updateAppointmentStatus);



// router.get('/all', authorize('admin', 'manager'), getAllAppointments);
// router.get('/doctor/attendance-rate', getAttendanceRate);
// router.get('/doctor/today', getTodaysDoctorAppointments);
// router.get('/doctor/all', getDoctorSchedule);
// router.get('/:id', getAppointment);
// router.put('/:id', updateAppointment);
// router.put('/doctor/:id', updateAppointmentStatus);
// router.delete('/:id', deleteAppointment);

module.exports = router;

