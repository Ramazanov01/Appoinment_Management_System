const { pool } = require('../config/supabaseClient');

// @desc    Get user profile
// @route   GET /api/user/profile
// @access  Private
exports.getProfile = async (req, res) => {
  try {
    const userResult = await pool.query(
      'SELECT id, first_name, last_name, email, role, phone, address, date_of_birth, profile_picture, is_active, department, manager_level, permissions, created_at, updated_at FROM users WHERE id = $1',
      [req.user.id]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const user = userResult.rows[0];

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user.id,
          firstName: user.first_name,
          lastName: user.last_name,
          email: user.email,
          role: user.role,
          phone: user.phone,
          address: user.address,
          dateOfBirth: user.date_of_birth,
          profilePicture: user.profile_picture,
          isActive: user.is_active,
          department: user.department,
          managerLevel: user.manager_level,
          permissions: user.permissions,
          createdAt: user.created_at,
          updatedAt: user.updated_at,
        },
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message,
    });
  }
};

// // @desc    Update user profile
// // @route   PUT /api/user/profile
// // @access  Private
// exports.updateProfile = async (req, res) => {
//   try {
//     const { firstName, lastName, phone, address, dateOfBirth } = req.body;

//     // Build update query dynamically
//     const updateFields = [];
//     const updateValues = [];
//     let paramCount = 1;

//     if (firstName !== undefined) {
//       updateFields.push(`first_name = $${paramCount++}`);
//       updateValues.push(firstName);
//     }
//     if (lastName !== undefined) {
//       updateFields.push(`last_name = $${paramCount++}`);
//       updateValues.push(lastName);
//     }
//     if (phone !== undefined) {
//       updateFields.push(`phone = $${paramCount++}`);
//       updateValues.push(phone);
//     }
//     if (address !== undefined) {
//       updateFields.push(`address = $${paramCount++}`);
//       updateValues.push(address);
//     }
//     if (dateOfBirth !== undefined) {
//       updateFields.push(`date_of_birth = $${paramCount++}`);
//       updateValues.push(dateOfBirth);
//     }

//     if (updateFields.length === 0) {
//       return res.status(400).json({
//         success: false,
//         message: 'No fields to update',
//       });
//     }

//     updateValues.push(req.user.id);
//     const updateQuery = `UPDATE users SET ${updateFields.join(', ')}, updated_at = NOW() WHERE id = $${paramCount} RETURNING id, first_name, last_name, email, role, phone, address, date_of_birth, profile_picture, is_active, department, manager_level, permissions, created_at, updated_at`;

//     const userResult = await pool.query(updateQuery, updateValues);

//     if (userResult.rows.length === 0) {
//       return res.status(404).json({
//         success: false,
//         message: 'User not found or update failed',
//       });
//     }

//     const user = userResult.rows[0];

//     res.status(200).json({
//       success: true,
//       message: 'Profile updated successfully',
//       data: {
//         user: {
//           id: user.id,
//           firstName: user.first_name,
//           lastName: user.last_name,
//           email: user.email,
//           role: user.role,
//           phone: user.phone,
//           address: user.address,
//           dateOfBirth: user.date_of_birth,
//           profilePicture: user.profile_picture,
//           isActive: user.is_active,
//           department: user.department,
//           managerLevel: user.manager_level,
//           permissions: user.permissions,
//           createdAt: user.created_at,
//           updatedAt: user.updated_at,
//         },
//       },
//     });
//   } catch (error) {
//     console.error('Update profile error:', error);
//     res.status(500).json({
//       success: false,
//       message: 'Server error',
//       error: error.message,
//     });
//   }
// };

// @desc    Update user profile (Only FirstName and LastName)
// @route   PUT /api/user/profile
// @access  Private
exports.updateProfile = async (req, res) => {
  try {
    const { firstName, lastName } = req.body;

    // Sadece firstName ve lastName kontrolü yapıyoruz
    const updateFields = [];
    const updateValues = [];
    let paramCount = 1;

    if (firstName !== undefined) {
      updateFields.push(`first_name = $${paramCount++}`);
      updateValues.push(firstName);
    }
    if (lastName !== undefined) {
      updateFields.push(`last_name = $${paramCount++}`);
      updateValues.push(lastName);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Güncellenecek alan bulunamadı (FirstName veya LastName gerekli)',
      });
    }

    // Kullanıcı ID'sini parametre dizisine ekliyoruz
    updateValues.push(req.user.id);

    // Sorguyu sadece var olan temel sütunları döndürecek şekilde sadeleştirdik
    const updateQuery = `
      UPDATE users 
      SET ${updateFields.join(', ')}, updated_at = NOW() 
      WHERE id = $${paramCount} 
      RETURNING id, first_name, last_name, email, role, created_at, updated_at`;

    const userResult = await pool.query(updateQuery, updateValues);

    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kullanıcı bulunamadı veya güncelleme başarısız',
      });
    }

    const user = userResult.rows[0];

    // Flutter tarafındaki StorageService'in beklediği formatta (camelCase) veri döndürüyoruz
    res.status(200).json({
      success: true,
      message: 'Profil başarıyla güncellendi',
      data: {
        user: {
          id: user.id,
          firstName: user.first_name,
          lastName: user.last_name,
          email: user.email,
          role: user.role,
          createdAt: user.created_at,
          updatedAt: user.updated_at,
        },
      },
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Sunucu hatası',
      error: error.message,
    });
  }
};
