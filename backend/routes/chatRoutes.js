const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');
const { aiLimiter } = require('../middleware/rateLimiter');

router.use(authMiddleware);

router.post('/', aiLimiter, chatController.sendChatMessage);
router.get('/conversations', chatController.getConversations);
router.get('/conversations/:id', chatController.getConversationById);
router.delete('/conversations/:id', chatController.deleteConversation);
router.post('/conversations/:id/clear', chatController.clearConversation);

module.exports = router;

