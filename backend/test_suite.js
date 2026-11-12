// Vision AI Automated End-to-End Verification Test Suite
const http = require('http');

async function request(path, method = 'GET', data = null, isMultipart = false) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 5000,
      path,
      method,
      headers: {}
    };

    let bodyStr = null;
    if (data && !isMultipart) {
      bodyStr = JSON.stringify(data);
      options.headers['Content-Type'] = 'application/json';
      options.headers['Content-Length'] = Buffer.byteLength(bodyStr);
    }

    const req = http.request(options, (res) => {
      let rawData = '';
      res.on('data', chunk => rawData += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(rawData);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: rawData });
        }
      });
    });

    req.on('error', reject);
    if (bodyStr) req.write(bodyStr);
    req.end();
  });
}

async function runTests() {
  console.log('====================================================');
  console.log('🧪 Starting Vision AI Comprehensive System Test Suite');
  console.log('====================================================\n');

  let passed = 0;
  let total = 0;

  async function test(name, fn) {
    total++;
    process.stdout.write(`[TEST ${total}] ${name}... `);
    try {
      await fn();
      console.log('✅ PASSED');
      passed++;
    } catch (err) {
      console.log('❌ FAILED:', err.message);
    }
  }

  // 1. Health & Config Status
  await test('Server Health & Config Check', async () => {
    const res = await request('/api/config/status');
    if (res.status !== 200 || !res.data.success) throw new Error('Status check failed');
    if (res.data.data.appName !== 'Vision AI Platform') throw new Error('Invalid app name');
  });

  // 2. Chat Conversation
  let convId = null;
  await test('AI Multi-turn Chat Generation', async () => {
    const res = await request('/api/chat', 'POST', {
      message: 'Explain Flutter state management and Provider pattern in 2 bullet points.'
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Chat request failed');
    convId = res.data.data.conversationId;
    if (!convId || !res.data.data.aiMessage.content) throw new Error('No AI message content returned');
  });

  // 3. Conversation Follow-up
  await test('Chat Multi-turn Follow-up Context', async () => {
    const res = await request('/api/chat', 'POST', {
      message: 'Can you show a code example for that?',
      conversationId: convId
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Follow-up failed');
    if (res.data.data.conversationId !== convId) throw new Error('Conversation ID mismatch');
  });

  // 4. Courses Retrieval
  await test('Courses Curriculum & Progress Retrieval', async () => {
    const res = await request('/api/courses');
    if (res.status !== 200 || !res.data.success) throw new Error('Failed to retrieve courses');
    if (res.data.data.length < 6) throw new Error('Expected at least 6 core courses');
  });

  // 5. Course Lesson Progress Toggle
  await test('Course Progress Update', async () => {
    const res = await request('/api/courses/course-flutter/progress', 'POST', {
      lessonTitle: 'Dart Syntax, Variables, Null Safety',
      completed: true
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Failed to update progress');
    if (res.data.data.progressPercent <= 0) throw new Error('Progress percentage did not update');
  });

  // 6. AI Quiz Generation
  let quizId = null;
  await test('AI Quiz Generation', async () => {
    const res = await request('/api/quiz/generate', 'POST', {
      topic: 'React 19 & Hooks',
      count: 3,
      difficulty: 'medium'
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Quiz generation failed');
    quizId = res.data.data.id;
    if (!quizId || res.data.data.questions.length !== 3) throw new Error('Unexpected questions count');
  });

  // 7. Quiz Evaluation & Scoring
  await test('Quiz Answer Evaluation & Feedback', async () => {
    const res = await request('/api/quiz/evaluate', 'POST', {
      quizId: quizId,
      answers: { q1: 0, q2: 1, q3: 2 }
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Quiz evaluation failed');
    if (res.data.data.breakdown.length !== 3) throw new Error('Incomplete answer breakdown');
    if (typeof res.data.data.scorePercent !== 'number') throw new Error('Score percentage missing');
  });

  // 8. Learning Hub - Explain
  await test('Learning Hub: Explain Topic (ELI5)', async () => {
    const res = await request('/api/learn/explain', 'POST', {
      topic: 'Neural Networks and Backpropagation',
      level: 'beginner'
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Topic explain failed');
    if (!res.data.data.explanation) throw new Error('Empty explanation returned');
  });

  // 9. Learning Hub - Study Notes
  await test('Learning Hub: Generate Study Notes', async () => {
    const res = await request('/api/learn/notes', 'POST', {
      topic: 'Docker Containers & Kubernetes Pods',
      format: 'cheat-sheet'
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Notes generation failed');
    if (!res.data.data.notes) throw new Error('Empty notes returned');
  });

  // 10. Learning Hub - Code Assistant
  await test('Learning Hub: Code Refactoring & Bug Inspection', async () => {
    const res = await request('/api/learn/code-assist', 'POST', {
      code: 'function add(a, b) { return a + b; }',
      language: 'javascript'
    });
    if (res.status !== 200 || !res.data.success) throw new Error('Code assist failed');
    if (!res.data.data.result) throw new Error('Empty code result returned');
  });

  // 11. User Profile & Analytics
  await test('User Profile Analytics Retrieval', async () => {
    const res = await request('/api/auth/profile');
    if (res.status !== 200 || !res.data.success) throw new Error('Failed to get profile');
    if (!res.data.data.stats) throw new Error('Stats object missing');
  });

  console.log(`\n====================================================`);
  console.log(`🎉 TEST SUMMARY: ${passed}/${total} Tests Passed Successfully!`);
  console.log(`====================================================`);
}

runTests();

