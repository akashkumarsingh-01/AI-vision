const { v4: uuidv4 } = require('uuid');
const db = require('../config/db');
const geminiService = require('../services/geminiService');

exports.sendChatMessage = async (req, res, next) => {
  try {
    const { message, conversationId, history = [] } = req.body;
    const userId = req.user?.id || 'guest_user';

    if (!message || typeof message !== 'string' || !message.trim()) {
      return res.status(400).json({ success: false, message: 'Message content cannot be empty.' });
    }

    const conversations = db.get('conversations');
    let conv = conversations.find(c => c.id === conversationId && (c.userId === userId || userId === 'guest_user'));

    if (!conv) {
      conv = {
        id: conversationId || uuidv4(),
        userId: userId,
        title: message.trim().slice(0, 35) + (message.length > 35 ? '...' : ''),
        messages: [],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      conversations.unshift(conv);
    }

    // Add user message to conversation
    const userMsg = {
      id: uuidv4(),
      role: 'user',
      content: message.trim(),
      timestamp: new Date().toISOString()
    };
    conv.messages.push(userMsg);

    // Call Gemini
    const aiResponse = await geminiService.generateChatResponse({
      prompt: message.trim(),
      history: conv.messages.slice(-10) // provide last 10 messages for multi-turn context
    });

    // Add AI message
    const aiMsg = {
      id: uuidv4(),
      role: 'assistant',
      content: aiResponse.content,
      modelUsed: aiResponse.modelUsed,
      isLiveGemini: aiResponse.isLiveGemini,
      timestamp: new Date().toISOString()
    };
    conv.messages.push(aiMsg);
    conv.updatedAt = new Date().toISOString();

    db.set('conversations', conversations);

    res.json({
      success: true,
      data: {
        conversationId: conv.id,
        userMessage: userMsg,
        aiMessage: aiMsg,
        title: conv.title
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.getConversations = (req, res) => {
  const userId = req.user?.id || 'guest_user';
  const conversations = db.get('conversations');
  const userConvs = conversations
    .filter(c => c.userId === userId || userId === 'guest_user')
    .map(c => ({
      id: c.id,
      title: c.title,
      messageCount: c.messages.length,
      lastMessage: c.messages[c.messages.length - 1]?.content?.slice(0, 80) || '',
      updatedAt: c.updatedAt,
      createdAt: c.createdAt
    }))
    .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));

  res.json({ success: true, data: userConvs });
};

exports.getConversationById = (req, res) => {
  const { id } = req.params;
  const userId = req.user?.id || 'guest_user';
  const conversations = db.get('conversations');
  const conv = conversations.find(c => c.id === id);

  if (!conv) {
    return res.status(404).json({ success: false, message: 'Conversation not found.' });
  }

  res.json({ success: true, data: conv });
};

exports.deleteConversation = (req, res) => {
  const { id } = req.params;
  const userId = req.user?.id || 'guest_user';
  let conversations = db.get('conversations');
  conversations = conversations.filter(c => c.id !== id);
  db.set('conversations', conversations);

  res.json({ success: true, message: 'Conversation deleted successfully.' });
};

exports.clearConversation = (req, res) => {
  const { id } = req.params;
  const conversations = db.get('conversations');
  const conv = conversations.find(c => c.id === id);

  if (conv) {
    conv.messages = [];
    conv.updatedAt = new Date().toISOString();
    db.set('conversations', conversations);
  }

  res.json({ success: true, message: 'Conversation messages cleared.' });
};

