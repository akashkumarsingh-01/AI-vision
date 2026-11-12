const rateLimit = require('express-rate-limit');

// General API rate limiter: 120 requests per minute
const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 120,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests from this IP address, please try again in a minute.'
  }
});

// Stricter rate limiter for heavy AI generation
const aiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'AI generation rate limit reached. Please wait a moment before sending another request.'
  }
});

module.exports = { apiLimiter, aiLimiter };

