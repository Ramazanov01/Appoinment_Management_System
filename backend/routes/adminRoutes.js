const express = require('express');
const router = express.Router();
const {
  createManager,
  getStats,
  sendBulkEmail,
  sendManagerBulkEmail,
  getAllManagers,
  deleteManager,
} = require('../controllers/adminController');
const { protect, authorize } = require('../middleware/authMiddleware');

// All routes are protected and admin only
router.use(protect);
router.use(authorize('admin'));

router.post('/create-manager', createManager);
router.get('/stats', getStats);
router.post('/send-bulk-email', sendBulkEmail);
router.post('/send-manager-email', sendManagerBulkEmail);
router.get('/managers', getAllManagers);
router.delete('/managers/:id', deleteManager);

module.exports = router;

