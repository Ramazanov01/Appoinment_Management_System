const express = require('express');
const router = express.Router();
const timeSlotsController = require('../controllers/timeSlotsController');
const { protect } = require('../middleware/authMiddleware');


router.get('/available-hours', timeSlotsController.getAvailableHours);

// Public routes - Get time slots
// router.get('/', timeSlotsController.getTimeSlots);
// router.get('/available/:date', timeSlotsController.getAvailableSlotsByDate);
// router.get('/available-range', timeSlotsController.getAvailableSlotsRange);
// router.post('/check-availability', timeSlotsController.checkSlotAvailability);

// // Protected routes - Create, Update, Delete (Admin/Manager only)
// router.post('/', protect, timeSlotsController.createTimeSlot);
// router.put('/:id', protect, timeSlotsController.updateTimeSlot);
// router.delete('/:id', protect, timeSlotsController.deleteTimeSlot);

module.exports = router;
