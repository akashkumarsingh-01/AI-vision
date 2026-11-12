const db = require('../config/db');

exports.getCourses = (req, res) => {
  const userId = req.user?.id || 'guest_user';
  const courses = db.get('courses');
  const userProgress = db.data.userProgress || {};

  const coursesWithProgress = courses.map(course => {
    const key = `${userId}_${course.id}`;
    const progress = userProgress[key] || { completedLessons: [], progressPercent: 0 };
    return {
      ...course,
      completedLessons: progress.completedLessons || [],
      progressPercent: progress.progressPercent || 0
    };
  });

  res.json({ success: true, data: coursesWithProgress });
};

exports.getCourseById = (req, res) => {
  const { id } = req.params;
  const userId = req.user?.id || 'guest_user';
  const courses = db.get('courses');
  const course = courses.find(c => c.id === id);

  if (!course) {
    return res.status(404).json({ success: false, message: 'Course not found.' });
  }

  const key = `${userId}_${course.id}`;
  const userProgress = db.data.userProgress || {};
  const progress = userProgress[key] || { completedLessons: [], progressPercent: 0 };

  res.json({
    success: true,
    data: {
      ...course,
      completedLessons: progress.completedLessons || [],
      progressPercent: progress.progressPercent || 0
    }
  });
};

exports.updateCourseProgress = (req, res) => {
  const { id } = req.params;
  const { lessonTitle, completed = true } = req.body;
  const userId = req.user?.id || 'guest_user';

  const courses = db.get('courses');
  const course = courses.find(c => c.id === id);
  if (!course) {
    return res.status(404).json({ success: false, message: 'Course not found.' });
  }

  if (!db.data.userProgress) {
    db.data.userProgress = {};
  }

  const key = `${userId}_${course.id}`;
  const current = db.data.userProgress[key] || { completedLessons: [], progressPercent: 0 };

  let completedLessons = [...current.completedLessons];
  if (completed) {
    if (!completedLessons.includes(lessonTitle)) {
      completedLessons.push(lessonTitle);
    }
  } else {
    completedLessons = completedLessons.filter(l => l !== lessonTitle);
  }

  // Count total lessons across all modules
  let totalLessons = 0;
  course.modules.forEach(m => {
    totalLessons += m.lessons.length;
  });

  const progressPercent = totalLessons > 0 ? Math.round((completedLessons.length / totalLessons) * 100) : 0;

  db.data.userProgress[key] = {
    completedLessons,
    progressPercent,
    updatedAt: new Date().toISOString()
  };
  db.save();

  res.json({
    success: true,
    data: {
      courseId: id,
      completedLessons,
      progressPercent
    }
  });
};

