const geminiService = require('../services/geminiService');

exports.explainTopic = async (req, res, next) => {
  try {
    const { topic, level = 'beginner' } = req.body;
    if (!topic || !topic.trim()) {
      return res.status(400).json({ success: false, message: 'Please specify a topic to explain.' });
    }

    const result = await geminiService.explainTopic({
      topic: topic.trim(),
      audience: level
    });

    res.json({
      success: true,
      data: {
        topic,
        level,
        explanation: result.content,
        modelUsed: result.modelUsed,
        isLiveGemini: result.isLiveGemini
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.generateNotes = async (req, res, next) => {
  try {
    const { topic, format = 'cheat-sheet' } = req.body;
    if (!topic || !topic.trim()) {
      return res.status(400).json({ success: false, message: 'Please specify a topic for notes generation.' });
    }

    const result = await geminiService.generateNotes({
      topic: topic.trim(),
      format
    });

    res.json({
      success: true,
      data: {
        topic,
        format,
        notes: result.content,
        modelUsed: result.modelUsed,
        isLiveGemini: result.isLiveGemini
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.assistCode = async (req, res, next) => {
  try {
    const { code, language = 'javascript', instruction = 'Explain, debug, and optimize this code.' } = req.body;
    if (!code || !code.trim()) {
      return res.status(400).json({ success: false, message: 'Please provide code snippet to analyze.' });
    }

    const result = await geminiService.assistCode({
      code: code.trim(),
      language,
      instruction
    });

    res.json({
      success: true,
      data: {
        language,
        result: result.content,
        modelUsed: result.modelUsed,
        isLiveGemini: result.isLiveGemini
      }
    });
  } catch (err) {
    next(err);
  }
};

