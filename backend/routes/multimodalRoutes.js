const express = require('express');
const router = express.Router();
const multimodalController = require('../controllers/multimodalController');
const upload = require('../middleware/uploadMiddleware');
const authMiddleware = require('../middleware/authMiddleware');
const { aiLimiter } = require('../middleware/rateLimiter');

router.use(authMiddleware);

router.post('/image', aiLimiter, upload.single('image'), multimodalController.analyzeImage);
router.post('/document', aiLimiter, upload.single('document'), multimodalController.analyzeDocument);
router.post('/video', aiLimiter, upload.single('video'), multimodalController.analyzeVideo);

module.exports = router;

