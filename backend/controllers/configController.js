const geminiManager = require('../config/gemini');
const db = require('../config/db');

exports.getStatus = (req, res) => {
  res.json({
    success: true,
    data: {
      appName: 'Vision AI Platform',
      version: '2.0.0',
      hasGeminiApiKey: geminiManager.hasKey(),
      geminiModel: geminiManager.modelName,
      availableModels: [
        'gemini-1.5-flash',
        'gemini-1.5-pro',
        'gemini-2.0-flash-exp'
      ],
      aiFeatures: [
        'Real-time Multi-turn Chat',
        'Multimodal Vision & Image Inspection',
        'PDF & Document Intelligence',
        'Video Scene Breakdown',
        'Adaptive Learning & Explanation Assistant',
        'Course Progress & Syllabus Tracking',
        'AI Quiz Generator & Performance Evaluator',
        'Voice Input & Text-to-Speech'
      ],
      serverTime: new Date().toISOString()
    }
  });
};

exports.updateApiKey = (req, res) => {
  const { apiKey, model } = req.body;

  if (model) {
    geminiManager.modelName = model;
    db.data.settings.geminiModel = model;
  }

  if (apiKey !== undefined) {
    geminiManager.updateApiKey(apiKey);
  }

  db.save();

  res.json({
    success: true,
    message: geminiManager.hasKey()
      ? 'Google Gemini API key successfully verified and configured.'
      : 'API key cleared. System is running in Local Intelligent Engine mode.',
    data: {
      hasGeminiApiKey: geminiManager.hasKey(),
      geminiModel: geminiManager.modelName
    }
  });
};

