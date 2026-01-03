const jwt = require('jsonwebtoken');
const { pool } = require('../config/supabaseClient');

// Protect routes - verify JWT token
exports.protect = async (req, res, next) => {
  try {
    let token;

    // Check for token in headers
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer')
    ) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized to access this route',
      });
    }

    try {
      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get user from database
      const userResult = await pool.query(
        'SELECT * FROM users WHERE id = $1',
        [decoded.id]
      );

      if (userResult.rows.length === 0) {
        return res.status(401).json({
          success: false,
          message: 'User not found',
        });
      }

      const user = userResult.rows[0];

      if (!user.is_active) {
        return res.status(401).json({
          success: false,
          message: 'User account is deactivated',
        });
      }

      // Attach user to request (without password)
      const { password: _, ...userWithoutPassword } = user;
      req.user = userWithoutPassword;

      next();
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token',
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// Grant access to specific roles
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `User role '${req.user.role}' is not authorized to access this route`,
      });
    }
    next();
  };
};
