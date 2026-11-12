const { GoogleGenerativeAI } = require('@google/generative-ai');
const db = require('./db');

class GeminiManager {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY || db.data.settings?.geminiApiKey || '';
    this.modelName = process.env.GEMINI_MODEL || db.data.settings?.geminiModel || 'gemini-1.5-flash';
    this.client = null;
    this.init();
  }

  init() {
    this.apiKey = process.env.GEMINI_API_KEY || db.data.settings?.geminiApiKey || '';
    if (this.apiKey && this.apiKey.trim().length > 10) {
      try {
        this.client = new GoogleGenerativeAI(this.apiKey.trim());
      } catch (err) {
        console.error('[GeminiManager] Init failed:', err.message);
        this.client = null;
      }
    } else {
      this.client = null;
    }
  }

  updateApiKey(newKey) {
    this.apiKey = (newKey || '').trim();
    db.data.settings.geminiApiKey = this.apiKey;
    db.save();
    this.init();
    return this.hasKey();
  }

  hasKey() {
    return !!(this.client && this.apiKey && this.apiKey.length > 10);
  }

  getModel(modelOverride) {
    if (!this.hasKey()) return null;
    const targetModel = modelOverride || this.modelName || 'gemini-1.5-flash';
    return this.client.getGenerativeModel({ model: targetModel });
  }
}

const geminiManager = new GeminiManager();
module.exports = geminiManager;

