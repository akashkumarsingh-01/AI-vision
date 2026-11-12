const geminiService = require('../services/geminiService');

exports.analyzeImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please provide an image file to analyze.' });
    }

    const prompt = req.body.prompt || 'Describe and analyze this image in detail.';
    const imageBuffer = req.file.buffer;
    const mimeType = req.file.mimetype;

    const result = await geminiService.analyzeImage({
      imageBuffer,
      mimeType,
      prompt
    });

    res.json({
      success: true,
      data: {
        analysis: result.analysis,
        modelUsed: result.modelUsed,
        fileName: req.file.originalname,
        fileSize: req.file.size,
        mimeType: req.file.mimetype,
        isLiveGemini: result.isLiveGemini
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.analyzeDocument = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload a PDF or document file to analyze.' });
    }

    const prompt = req.body.prompt || 'Summarize this document and extract key action items and insights.';
    const fileBuffer = req.file.buffer;
    const fileName = req.file.originalname;
    const mimeType = req.file.mimetype;

    const result = await geminiService.analyzeDocument({
      fileBuffer,
      fileName,
      mimeType,
      prompt
    });

    res.json({
      success: true,
      data: {
        analysis: result.content,
        modelUsed: result.modelUsed,
        fileName: fileName,
        fileSize: req.file.size,
        isLiveGemini: result.isLiveGemini
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.analyzeVideo = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload a video file to analyze.' });
    }

    const prompt = req.body.prompt || 'Analyze this video and provide a timeline breakdown of topics and visual events.';
    const fileName = req.file.originalname;
    const mimeType = req.file.mimetype;

    const result = await geminiService.analyzeVideo({
      fileName,
      mimeType,
      prompt
    });

    res.json({
      success: true,
      data: {
        analysis: result.content,
        modelUsed: result.modelUsed,
        fileName: fileName,
        fileSize: req.file.size,
        isLiveGemini: result.isLiveGemini
      }
    });
  } catch (err) {
    next(err);
  }
};

