const express = require('express');
const router = express.Router();
const learnController = require('../controllers/learnController');
const authMiddleware = require('../middleware/authMiddleware');
const { aiLimiter } = require('../middleware/rateLimiter');

router.use(authMiddleware);

router.post('/explain', aiLimiter, learnController.explainTopic);
router.post('/notes', aiLimiter, learnController.generateNotes);
router.post('/code-assist', aiLimiter, learnController.assistCode);

module.exports = router;

