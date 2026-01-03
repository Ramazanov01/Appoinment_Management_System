# Appointment Manager System - Backend API

A RESTful API backend for the Appointment Manager System built with Node.js, Express, and Supabase (PostgreSQL).

## Features

- 🔐 User Authentication (JWT-based)
- 👥 User Management (User, Manager, Admin roles)
- 📅 Appointment Management
- 🔒 Role-based Access Control
- ☁️ Cloud Database (Supabase/PostgreSQL)
- 🛡️ Secure Password Hashing
- ✅ Input Validation

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **Supabase** - Cloud database (PostgreSQL)
- **@supabase/supabase-js** - Supabase client library
- **JWT** - Authentication tokens
- **bcryptjs** - Password hashing
- **dotenv** - Environment variables

## Project Structure

```
backend/
├── config/          # Configuration files
├── controllers/     # Business logic
│   ├── adminController.js
│   ├── appointmentController.js
│   ├── authController.js
│   └── userController.js
├── middleware/      # Custom middleware
│   └── authMiddleware.js
├── models/          # MongoDB models
│   ├── Appointment.js
│   └── User.js
├── routes/          # API routes
│   ├── adminRoutes.js
│   ├── appointmentRoutes.js
│   ├── authRoutes.js
│   └── userRoutes.js
├── utils/           # Utility functions
│   └── generateToken.js
├── .env.example     # Environment variables template
├── .gitignore       # Git ignore file
├── package.json     # Dependencies
├── server.js        # Entry point
└── README.md        # Documentation
```

## Installation

1. **Clone the repository** (if not already done)
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   - Copy `.env.example` to `.env`
   ```bash
   cp .env.example .env
   ```
   - Edit `.env` and add your MongoDB Atlas connection string and JWT secret

4. **Start the server**
   ```bash
   # Development mode (with auto-reload)
   npm run dev

   # Production mode
   npm start
   ```

## Environment Variables

Create a `.env` file in the backend directory with the following variables:

```env
PORT=5000
NODE_ENV=development
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_public_key_here
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRE=7d
```

### Setting up Supabase (Cloud Database)

1. Go to [Supabase](https://supabase.com)
2. Create a free account or sign in
3. Create a new project (free tier available)
4. Go to **Settings** → **API** to get your:
   - Project URL (`SUPABASE_URL`)
   - Anon public key (`SUPABASE_ANON_KEY`)
5. Go to **SQL Editor** and run the SQL schema from `database/schema.sql`
6. Add your credentials to `.env` file

See `SUPABASE_SETUP.md` for detailed setup instructions.

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register a new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (Protected)

### User Profile
- `GET /api/user/profile` - Get user profile (Protected)
- `PUT /api/user/profile` - Update user profile (Protected)

### Appointments
- `GET /api/appointments` - Get user's appointments (Protected)
- `GET /api/appointments/:id` - Get single appointment (Protected)
- `POST /api/appointments` - Create new appointment (Protected)
- `PUT /api/appointments/:id` - Update appointment (Protected)
- `DELETE /api/appointments/:id` - Delete appointment (Protected)
- `GET /api/appointments/all` - Get all appointments (Admin/Manager only)

### Admin
- `POST /api/admin/managers` - Create new manager (Admin only)
- `GET /api/admin/users` - Get all users (Admin only)
- `GET /api/admin/users/:id` - Get user by ID (Admin only)
- `PUT /api/admin/users/:id` - Update user (Admin only)
- `DELETE /api/admin/users/:id` - Delete user (Admin only)
- `GET /api/admin/stats` - Get system statistics (Admin only)

### Health Check
- `GET /api/health` - Server health check

## API Usage Examples

### Signup
```bash
POST /api/auth/signup
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

### Login
```bash
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "...",
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com",
      "role": "user"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "role": "user"
  }
}
```

### Create Appointment (Protected)
```bash
POST /api/appointments
Authorization: Bearer <token>
Content-Type: application/json

{
  "doctor": "Dr. Sarah Johnson",
  "service": "Check-up",
  "date": "2024-12-25T14:00:00.000Z",
  "time": "2:00 PM",
  "notes": "Regular checkup",
  "department": "General Medicine"
}
```

### Create Manager (Admin only)
```bash
POST /api/admin/managers
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "jane@example.com",
  "password": "password123",
  "department": "Cardiology",
  "managerLevel": "Department Manager",
  "permissions": {
    "viewStaffSchedule": true,
    "modifyStaffSchedule": true,
    "viewAllAppointments": true,
    "modifyAppointments": true
  }
}
```

## Authentication

Most endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## User Roles

- **user** - Regular user, can manage own appointments
- **manager** - Can view and manage appointments, staff schedules
- **admin** - Full access to all features

## Error Handling

All errors follow a consistent format:

```json
{
  "success": false,
  "message": "Error message here"
}
```

## Security Features

- Password hashing with bcryptjs
- JWT token-based authentication
- Role-based access control
- Input validation
- CORS enabled
- Environment variables for sensitive data
- Row Level Security (RLS) on database tables

## Development

- Use `npm run dev` for development with auto-reload (requires nodemon)
- Server runs on `http://localhost:5000` by default
- API base URL: `http://localhost:5000/api`

## Production Deployment

1. Set `NODE_ENV=production` in `.env`
2. Use a strong `JWT_SECRET`
3. Configure proper CORS origins
4. Use a production MongoDB cluster
5. Set up proper logging and monitoring

## Support

For issues or questions, please check the main project documentation or create an issue in the repository.

