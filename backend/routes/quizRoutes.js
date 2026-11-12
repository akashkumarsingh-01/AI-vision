const express = require('express');
const router = express.Router();
const quizController = require('../controllers/quizController');
const authMiddleware = require('../middleware/authMiddleware');
const { aiLimiter } = require('../middleware/rateLimiter');

router.use(authMiddleware);

router.post('/generate', aiLimiter, quizController.generateQuiz);
router.post('/evaluate', quizController.evaluateQuiz);
router.get('/history', quizController.getQuizHistory);

module.exports = router;

