const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const geminiService = require('../services/geminiService');

exports.generateQuiz = async (req, res, next) => {
  try {
    const { topic = 'Full-Stack & AI Concepts', count = 5, difficulty = 'medium' } = req.body;

    const quizData = await geminiService.generateQuiz({
      topic,
      count: parseInt(count, 10) || 5,
      difficulty
    });

    const quizId = uuidv4();
    const newQuiz = {
      id: quizId,
      topic: quizData.topic,
      difficulty: quizData.difficulty,
      questions: quizData.questions,
      createdAt: new Date().toISOString()
    };

    const quizzes = db.get('quizzes');
    quizzes.unshift(newQuiz);
    db.set('quizzes', quizzes.slice(0, 50)); // store up to 50 active quizzes

    res.json({
      success: true,
      data: newQuiz
    });
  } catch (err) {
    next(err);
  }
};

exports.evaluateQuiz = (req, res) => {
  const { quizId, answers = {} } = req.body;
  const userId = req.user?.id || 'guest_user';

  const quizzes = db.get('quizzes');
  const quiz = quizzes.find(q => q.id === quizId);

  if (!quiz) {
    return res.status(404).json({ success: false, message: 'Quiz session expired or not found.' });
  }

  let correctCount = 0;
  const breakdown = quiz.questions.map((q, idx) => {
    const userAnswerIndex = answers[q.id] !== undefined ? answers[q.id] : answers[idx];
    const isCorrect = userAnswerIndex === q.correctIndex;
    if (isCorrect) correctCount++;

    return {
      questionId: q.id,
      question: q.question,
      userAnswerIndex,
      correctIndex: q.correctIndex,
      userAnswerText: q.options[userAnswerIndex] || 'Unanswered',
      correctAnswerText: q.options[q.correctIndex],
      isCorrect,
      explanation: q.explanation
    };
  });

  const totalQuestions = quiz.questions.length;
  const scorePercent = Math.round((correctCount / totalQuestions) * 100);

  const resultRecord = {
    id: uuidv4(),
    quizId,
    userId,
    topic: quiz.topic,
    difficulty: quiz.difficulty,
    totalQuestions,
    correctCount,
    scorePercent,
    breakdown,
    timestamp: new Date().toISOString()
  };

  const quizResults = db.get('quizResults');
  quizResults.unshift(resultRecord);
  db.set('quizResults', quizResults);

  res.json({
    success: true,
    data: resultRecord
  });
};

exports.getQuizHistory = (req, res) => {
  const userId = req.user?.id || 'guest_user';
  const quizResults = db.get('quizResults');
  const userResults = quizResults.filter(r => r.userId === userId || userId === 'guest_user');

  const totalQuizzes = userResults.length;
  const averageScore = totalQuizzes > 0
    ? Math.round(userResults.reduce((acc, curr) => acc + curr.scorePercent, 0) / totalQuizzes)
    : 0;

  res.json({
    success: true,
    data: {
      stats: {
        totalQuizzes,
        averageScore,
        highestScore: totalQuizzes > 0 ? Math.max(...userResults.map(r => r.scorePercent)) : 0
      },
      history: userResults.slice(0, 20)
    }
  });
};

