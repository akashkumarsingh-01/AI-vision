const jwt = require('jsonwebtoken');
const db = require('../config/db');

const JWT_SECRET = process.env.JWT_SECRET || 'vision_ai_super_secret_jwt_key_2026_change_in_production';

function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'];
  let token = null;

  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.substring(7);
  }

  if (!token) {
    // Support guest user identification via header or generate fallback guest
    const guestId = req.headers['x-guest-id'] || 'guest_user';
    req.user = { id: guestId, email: 'guest@visionai.local', name: 'Guest Explorer', role: 'guest' };
    return next();
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const users = db.get('users');
    const existing = users.find(u => u.id === decoded.id);
    if (existing) {
      req.user = { id: existing.id, email: existing.email, name: existing.name, role: existing.role || 'user' };
    } else {
      req.user = decoded;
    }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired authentication token.' });
  }
}

module.exports = authMiddleware;

