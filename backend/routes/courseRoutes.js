const express = require('express');
const router = express.Router();
const courseController = require('../controllers/courseController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', courseController.getCourses);
router.get('/:id', courseController.getCourseById);
router.post('/:id/progress', courseController.updateCourseProgress);

module.exports = router;

