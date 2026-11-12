require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');

const { apiLimiter } = require('./middleware/rateLimiter');
const { notFound, errorHandler } = require('./middleware/errorHandler');

// Route imports
const chatRoutes = require('./routes/chatRoutes');
const multimodalRoutes = require('./routes/multimodalRoutes');
const learnRoutes = require('./routes/learnRoutes');
const courseRoutes = require('./routes/courseRoutes');
const quizRoutes = require('./routes/quizRoutes');
const authRoutes = require('./routes/authRoutes');
const configRoutes = require('./routes/configRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Security & Global Middlewares
app.use(helmet({
  contentSecurityPolicy: false, // allows modern CDN fonts, markdown renderers and icons
  crossOriginEmbedderPolicy: false
}));

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-guest-id', 'x-gemini-key']
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Apply rate limiter to /api
app.use('/api', apiLimiter);

// Serve static frontend web files if present in public folder
app.use(express.static(path.join(__dirname, 'public')));

// Serve compiled Flutter Web application build
const flutterWebDir = path.join(__dirname, '..', 'frontend', 'build', 'web');
app.use('/flutter', express.static(flutterWebDir));

// API Routes
app.use('/api/chat', chatRoutes);
app.use('/api/multimodal', multimodalRoutes);
app.use('/api/learn', learnRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/quiz', quizRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/config', configRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Single Page Application fallback for frontend routes
app.use((req, res, next) => {
  if (req.originalUrl.startsWith('/api')) {
    return next();
  }
  const indexPath = path.join(__dirname, 'public', 'index.html');
  res.sendFile(indexPath, (err) => {
    if (err) {
      res.status(200).json({
        message: 'Vision AI Backend Server running successfully. Connect frontend client or build Flutter web.',
        apiDoc: '/api/config/status'
      });
    }
  });
});

// Error handling
app.use(notFound);
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`🚀 Vision AI Server running on http://localhost:${PORT}`);
  console.log(`📡 REST API Base: http://localhost:${PORT}/api`);
  console.log(`⚡ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`===============================================`);
});
