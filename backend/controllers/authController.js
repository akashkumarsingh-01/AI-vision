const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');

const JWT_SECRET = process.env.JWT_SECRET || 'vision_ai_super_secret_jwt_key_2026_change_in_production';

exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide name, email, and password.' });
    }

    if (password.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters.' });
    }

    const users = db.get('users');
    const existing = users.find(u => u.email.toLowerCase() === email.toLowerCase());
    if (existing) {
      return res.status(400).json({ success: false, message: 'An account with this email already exists.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = {
      id: uuidv4(),
      name: name.trim(),
      email: email.toLowerCase().trim(),
      password: hashedPassword,
      avatar: `https://api.dicebear.com/7.x/bottts/svg?seed=${encodeURIComponent(name)}`,
      bio: 'Lifelong learner exploring Vision AI intelligence.',
      learningGoals: ['Master Flutter & Dart', 'Build AI-powered Web Apps', 'Learn Gemini Multimodal API'],
      preferences: {
        theme: 'dark',
        autoSpeech: false,
        soundEffects: true
      },
      createdAt: new Date().toISOString()
    };

    users.push(newUser);
    db.set('users', users);

    const token = jwt.sign({ id: newUser.id, email: newUser.email, name: newUser.name }, JWT_SECRET, { expiresIn: '30d' });

    const safeUser = { ...newUser };
    delete safeUser.password;

    res.status(201).json({
      success: true,
      data: {
        token,
        user: safeUser
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Please provide email and password.' });
    }

    const users = db.get('users');
    const user = users.find(u => u.email.toLowerCase() === email.toLowerCase().trim());
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid credentials. User not found.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials. Incorrect password.' });
    }

    const token = jwt.sign({ id: user.id, email: user.email, name: user.name }, JWT_SECRET, { expiresIn: '30d' });

    const safeUser = { ...user };
    delete safeUser.password;

    res.json({
      success: true,
      data: {
        token,
        user: safeUser
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getProfile = (req, res) => {
  const userId = req.user?.id || 'guest_user';
  const users = db.get('users');
  const user = users.find(u => u.id === userId);

  // Compute stats
  const conversations = db.get('conversations').filter(c => c.userId === userId || userId === 'guest_user');
  const quizResults = db.get('quizResults').filter(q => q.userId === userId || userId === 'guest_user');
  const userProgress = db.data.userProgress || {};

  let coursesCompleted = 0;
  let totalLessonsFinished = 0;
  Object.keys(userProgress).forEach(key => {
    if (key.startsWith(userId)) {
      const p = userProgress[key];
      totalLessonsFinished += (p.completedLessons || []).length;
      if (p.progressPercent >= 100) coursesCompleted++;
    }
  });

  const avgQuizScore = quizResults.length > 0
    ? Math.round(quizResults.reduce((acc, q) => acc + q.scorePercent, 0) / quizResults.length)
    : 0;

  const profileData = user ? { ...user } : {
    id: 'guest_user',
    name: 'Explorer Guest',
    email: 'guest@visionai.dev',
    avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=Explorer',
    bio: 'Vision AI Interactive Guest Explorer',
    learningGoals: ['Explore Multimodal AI', 'Learn Modern Full-Stack'],
    preferences: {
      theme: 'dark',
      autoSpeech: false,
      soundEffects: true
    }
  };
  delete profileData.password;

  res.json({
    success: true,
    data: {
      profile: profileData,
      stats: {
        conversationsCount: conversations.length,
        quizzesTaken: quizResults.length,
        avgQuizScore,
        coursesCompleted,
        totalLessonsFinished
      }
    }
  });
};

exports.updateProfile = (req, res) => {
  const userId = req.user?.id;
  if (!userId || userId === 'guest_user') {
    return res.json({
      success: true,
      message: 'Guest profile updated in local session.',
      data: req.body
    });
  }

  const users = db.get('users');
  const userIndex = users.findIndex(u => u.id === userId);
  if (userIndex === -1) {
    return res.status(404).json({ success: false, message: 'User not found.' });
  }

  const { name, bio, learningGoals, preferences } = req.body;
  if (name) users[userIndex].name = name.trim();
  if (bio !== undefined) users[userIndex].bio = bio;
  if (learningGoals) users[userIndex].learningGoals = learningGoals;
  if (preferences) users[userIndex].preferences = { ...users[userIndex].preferences, ...preferences };

  db.set('users', users);

  const safe = { ...users[userIndex] };
  delete safe.password;

  res.json({
    success: true,
    data: safe,
    message: 'Profile updated successfully.'
  });
};

