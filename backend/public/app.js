// Vision AI – Frontend Client Application Engine
const API_BASE = '/api';

// State Store
const state = {
  activeView: 'home',
  activeConversationId: null,
  messages: [],
  selectedFile: null,
  isTtsEnabled: true,
  isRecordingVoice: false,
  recognition: null,
  activeQuiz: null,
  quizAnswers: {},
  courses: [],
  currentCourse: null,
  theme: localStorage.getItem('vision_ai_theme') || 'dark',
  geminiStatus: { hasGeminiApiKey: false, geminiModel: 'gemini-1.5-flash' }
};

// --- DOM References ---
const sidebar = document.getElementById('sidebar');
const sidebarOverlay = document.getElementById('sidebarOverlay');
const chatMessageList = document.getElementById('chatMessageList');
const chatInput = document.getElementById('chatInput');
const chatForm = document.getElementById('chatForm');
const micBtn = document.getElementById('micBtn');
const chatTypingIndicator = document.getElementById('chatTypingIndicator');
const fileUploadPreview = document.getElementById('fileUploadPreview');
const filePreviewName = document.getElementById('filePreviewName');
const filePreviewSize = document.getElementById('filePreviewSize');

// Initialize on Document Ready
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initNavigation();
  initSpeechFeatures();
  initChatEvents();
  initCoursesEvents();
  initQuizEvents();
  initLearnEvents();
  initSettingsEvents();

  // Load initial backend states
  checkConfigStatus();
  loadRecentConversations();
  loadCoursesList();
  loadQuizHistory();
  loadUserProfile();

  renderEmptyChatWelcome();
  populateHomePromptChips();
});

// --- Theme Management ---
function initTheme() {
  const html = document.documentElement;
  if (state.theme === 'dark') {
    html.classList.add('dark');
  } else {
    html.classList.remove('dark');
  }

  const toggleHandler = () => {
    state.theme = state.theme === 'dark' ? 'light' : 'dark';
    localStorage.setItem('vision_ai_theme', state.theme);
    if (state.theme === 'dark') {
      html.classList.add('dark');
    } else {
      html.classList.remove('dark');
    }
  };

  document.getElementById('themeToggleDesktop')?.addEventListener('click', toggleHandler);
  document.getElementById('themeToggleMobile')?.addEventListener('click', toggleHandler);
}

// --- Navigation Controller ---
function initNavigation() {
  document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const view = btn.getAttribute('data-nav');
      switchView(view);
      closeMobileSidebar();
    });
  });

  document.getElementById('mobileMenuBtn')?.addEventListener('click', () => {
    sidebar.classList.remove('-translate-x-full');
    sidebarOverlay.classList.remove('hidden');
  });

  document.getElementById('closeMobileMenu')?.addEventListener('click', closeMobileSidebar);
  sidebarOverlay?.addEventListener('click', closeMobileSidebar);

  document.getElementById('newChatBtn')?.addEventListener('click', () => {
    startNewChat();
    switchView('chat');
    closeMobileSidebar();
  });

  document.getElementById('homeSearchInput')?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && e.target.value.trim()) {
      const query = e.target.value.trim();
      e.target.value = '';
      switchView('chat');
      sendUserMessage(query);
    }
  });

  document.getElementById('globalTtsToggle')?.addEventListener('click', () => {
    state.isTtsEnabled = !state.isTtsEnabled;
    const btn = document.getElementById('globalTtsToggle');
    btn.innerHTML = `<i class="fa-solid ${state.isTtsEnabled ? 'fa-volume-high text-brand-500' : 'fa-volume-xmark text-slate-400'}"></i><span class="hidden sm:inline">TTS: ${state.isTtsEnabled ? 'On' : 'Off'}</span>`;
  });

  document.getElementById('quickKeyModalBtn')?.addEventListener('click', () => {
    switchView('settings');
  });
}

function closeMobileSidebar() {
  sidebar.classList.add('-translate-x-full');
  sidebarOverlay.classList.add('hidden');
}

function switchView(viewName) {
  state.activeView = viewName;

  // Update panels
  document.querySelectorAll('.view-panel').forEach(p => p.classList.add('hidden'));
  const target = document.getElementById(`view-${viewName}`);
  if (target) target.classList.remove('hidden');

  // Update nav buttons
  document.querySelectorAll('.nav-btn').forEach(b => {
    if (b.getAttribute('data-nav') === viewName) {
      b.classList.add('active');
    } else {
      b.classList.remove('active');
    }
  });

  // Update Title
  const titles = {
    home: 'Home Dashboard',
    chat: 'Vision AI Chat Assistant',
    courses: 'Curated Tech Courses',
    quiz: 'AI Quiz Master & Assessment',
    learn: 'Learning Hub & AI Mentor',
    history: 'Conversation History',
    profile: 'User Profile & Analytics',
    settings: 'Settings & Cloud Integration'
  };
  const titleEl = document.getElementById('sectionTitle');
  if (titleEl) titleEl.innerText = titles[viewName] || 'Vision AI';

  if (viewName === 'history') loadHistoryView();
  if (viewName === 'profile') loadUserProfile();
}

// --- Home Screen Prompts ---
function populateHomePromptChips() {
  const container = document.getElementById('homePromptChips');
  if (!container) return;
  const prompts = [
    'Explain how Flutter compiles to Web & Native',
    'Write a Python script with Google Gemini API',
    'What is the difference between useMemo and useCallback?',
    'Explain quantum computing like I am 10 years old',
    'Design a scalable microservices architecture',
  ];

  container.innerHTML = prompts.map(p => `
    <button onclick="triggerQuickPrompt('${p.replace(/'/g, "\\'")}')" class="px-3.5 py-1.5 rounded-full bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder text-xs hover:border-brand-500 hover:text-brand-600 dark:hover:text-brand-400 transition flex items-center space-x-1.5 shadow-sm">
      <i class="fa-solid fa-bolt text-purple-500 text-[11px]"></i>
      <span>${p}</span>
    </button>
  `).join('');
}

function triggerQuickPrompt(promptText) {
  switchView('chat');
  sendUserMessage(promptText);
}

// --- Speech Recognition & Text-to-Speech ---
function initSpeechFeatures() {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (SpeechRecognition) {
    state.recognition = new SpeechRecognition();
    state.recognition.continuous = false;
    state.recognition.interimResults = false;
    state.recognition.lang = 'en-US';

    state.recognition.onstart = () => {
      state.isRecordingVoice = true;
      micBtn.classList.add('text-red-500', 'animate-pulse');
      chatInput.placeholder = 'Listening... Speak now into your microphone...';
    };

    state.recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript;
      chatInput.value = transcript;
    };

    state.recognition.onerror = (e) => {
      console.warn('Speech recognition error:', e.error);
      stopVoiceRecording();
    };

    state.recognition.onend = () => {
      stopVoiceRecording();
    };
  }

  micBtn?.addEventListener('click', () => {
    if (!state.recognition) {
      alert('Speech recognition is not supported in this browser. Please use Chrome or Edge.');
      return;
    }
    if (state.isRecordingVoice) {
      state.recognition.stop();
      stopVoiceRecording();
    } else {
      try {
        state.recognition.start();
      } catch (e) {
        console.warn(e);
      }
    }
  });
}

function stopVoiceRecording() {
  state.isRecordingVoice = false;
  micBtn?.classList.remove('text-red-500', 'animate-pulse');
  chatInput.placeholder = 'Ask Vision AI anything (code, algorithms, document summaries, voice)...';
}

function speakText(text) {
  if (!state.isTtsEnabled || !window.speechSynthesis) return;
  window.speechSynthesis.cancel(); // stop current audio
  // strip markdown symbols for clean speech
  const clean = text.replace(/[*#`_~]/g, '').slice(0, 500);
  const utterance = new SpeechSynthesisUtterance(clean);
  utterance.rate = 1.0;
  window.speechSynthesis.speak(utterance);
}

// --- Chat Engine ---
function initChatEvents() {
  chatForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const text = chatInput.value.trim();
    if (!text && !state.selectedFile) return;

    chatInput.value = '';
    chatInput.style.height = 'auto';

    if (state.selectedFile) {
      uploadMultimodalFile(text);
    } else {
      sendUserMessage(text);
    }
  });

  // Auto expand textarea
  chatInput.addEventListener('input', () => {
    chatInput.style.height = 'auto';
    chatInput.style.height = Math.min(chatInput.scrollHeight, 120) + 'px';
  });

  // Enter to send (Shift+Enter for newline)
  chatInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      chatForm.dispatchEvent(new Event('submit'));
    }
  });

  // Multimodal file pickers
  document.getElementById('imageFileInput')?.addEventListener('change', (e) => handleFileSelected(e, 'image'));
  document.getElementById('docFileInput')?.addEventListener('change', (e) => handleFileSelected(e, 'document'));
  document.getElementById('videoFileInput')?.addEventListener('change', (e) => handleFileSelected(e, 'video'));

  document.getElementById('cancelFileAttachment')?.addEventListener('click', cancelSelectedFile);

  document.getElementById('clearChatBtn')?.addEventListener('click', () => {
    if (confirm('Clear current conversation messages?')) {
      chatMessageList.innerHTML = '';
      state.messages = [];
      renderEmptyChatWelcome();
    }
  });

  document.getElementById('regenerateBtn')?.addEventListener('click', () => {
    const lastUser = [...state.messages].reverse().find(m => m.role === 'user');
    if (lastUser) {
      sendUserMessage(lastUser.content);
    }
  });
}

function handleFileSelected(event, fileType) {
  const file = event.target.files[0];
  if (!file) return;

  state.selectedFile = { file, fileType };
  filePreviewName.innerText = file.name;
  filePreviewSize.innerText = `(${(file.size / 1024).toFixed(1)} KB)`;
  fileUploadPreview.classList.remove('hidden');
}

function cancelSelectedFile() {
  state.selectedFile = null;
  fileUploadPreview.classList.add('hidden');
  document.getElementById('imageFileInput').value = '';
  document.getElementById('docFileInput').value = '';
  document.getElementById('videoFileInput').value = '';
}

function startNewChat() {
  state.activeConversationId = null;
  state.messages = [];
  chatMessageList.innerHTML = '';
  cancelSelectedFile();
  renderEmptyChatWelcome();
}

function renderEmptyChatWelcome() {
  chatMessageList.innerHTML = `
    <div class="h-full flex flex-col items-center justify-center text-center p-6 space-y-4 my-auto">
      <div class="w-16 h-16 rounded-2xl bg-gradient-to-tr from-brand-600 to-purple-600 text-white flex items-center justify-center text-2xl shadow-xl shadow-brand-500/25">
        <i class="fa-solid fa-sparkles"></i>
      </div>
      <div>
        <h3 class="text-xl font-bold text-slate-900 dark:text-white">How can Vision AI assist you today?</h3>
        <p class="text-xs text-slate-500 dark:text-slate-400 mt-1">Communicate through text, microphone speech, images, PDFs, or videos.</p>
      </div>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3 max-w-lg w-full pt-2 text-left">
        <div onclick="triggerQuickPrompt('Analyze the architecture of modern AI foundational models')" class="cursor-pointer p-3.5 rounded-xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder hover:border-brand-500 text-xs transition">
          <p class="font-bold text-slate-800 dark:text-slate-200">🤖 AI Architectures</p>
          <p class="text-[11px] text-slate-400 mt-0.5">Explore transformer mechanisms & attention</p>
        </div>
        <div onclick="triggerQuickPrompt('Explain Flutter state management: Provider vs Riverpod vs Bloc')" class="cursor-pointer p-3.5 rounded-xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder hover:border-brand-500 text-xs transition">
          <p class="font-bold text-slate-800 dark:text-slate-200">📱 Flutter State Management</p>
          <p class="text-[11px] text-slate-400 mt-0.5">Provider, Riverpod, and Bloc comparisons</p>
        </div>
        <div onclick="triggerQuickPrompt('Write a full-stack REST API endpoint with JWT authentication in Express')" class="cursor-pointer p-3.5 rounded-xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder hover:border-brand-500 text-xs transition">
          <p class="font-bold text-slate-800 dark:text-slate-200">💻 Full-Stack Development</p>
          <p class="text-[11px] text-slate-400 mt-0.5">Express, JWT & secure middleware</p>
        </div>
        <div onclick="triggerQuickPrompt('Explain quantum computing like I am 10 years old with analogies')" class="cursor-pointer p-3.5 rounded-xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder hover:border-brand-500 text-xs transition">
          <p class="font-bold text-slate-800 dark:text-slate-200">💡 ELI5 Explanations</p>
          <p class="text-[11px] text-slate-400 mt-0.5">Intuitive analogies for deep concepts</p>
        </div>
      </div>
    </div>
  `;
}

async function sendUserMessage(text) {
  // Clear welcome if present
  if (state.messages.length === 0) {
    chatMessageList.innerHTML = '';
  }

  // Append user bubble
  appendChatBubble({ role: 'user', content: text });
  state.messages.push({ role: 'user', content: text });

  // Show typing indicator
  showTyping(true);

  try {
    const res = await fetch(`${API_BASE}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: text,
        conversationId: state.activeConversationId
      })
    });

    const data = await res.json();
    showTyping(false);

    if (data.success) {
      state.activeConversationId = data.data.conversationId;
      const aiMsg = data.data.aiMessage;
      appendChatBubble(aiMsg);
      state.messages.push(aiMsg);
      speakText(aiMsg.content);
      loadRecentConversations();
    } else {
      appendChatBubble({ role: 'assistant', content: `Error: ${data.message || 'Failed to generate response'}` });
    }
  } catch (err) {
    showTyping(false);
    appendChatBubble({ role: 'assistant', content: `Network Connection Error: ${err.message}` });
  }
}

async function uploadMultimodalFile(promptText) {
  if (!state.selectedFile) return;

  const { file, fileType } = state.selectedFile;
  const prompt = promptText || `Analyze this ${fileType} in detail.`;

  // Append user bubble with attachment tag
  appendChatBubble({
    role: 'user',
    content: prompt,
    attachment: { name: file.name, type: fileType }
  });

  cancelSelectedFile();
  showTyping(true, `Analyzing ${fileType} with Vision AI multimodal reasoning...`);

  const formData = new FormData();
  formData.append(fileType, file);
  formData.append('prompt', prompt);

  try {
    const endpoint = `${API_BASE}/multimodal/${fileType}`;
    const res = await fetch(endpoint, {
      method: 'POST',
      body: formData
    });

    const data = await res.json();
    showTyping(false);

    if (data.success) {
      const aiResponseText = data.data.analysis;
      appendChatBubble({
        role: 'assistant',
        content: aiResponseText,
        isLiveGemini: data.data.isLiveGemini,
        modelUsed: data.data.modelUsed
      });
      speakText(aiResponseText);
    } else {
      appendChatBubble({ role: 'assistant', content: `Multimodal Analysis Error: ${data.message}` });
    }
  } catch (err) {
    showTyping(false);
    appendChatBubble({ role: 'assistant', content: `Failed to upload and analyze file: ${err.message}` });
  }
}

function showTyping(show, text = 'Vision AI is formulating response...') {
  if (show) {
    document.getElementById('chatTypingText').innerText = text;
    chatTypingIndicator.classList.remove('hidden');
    chatMessageList.scrollTop = chatMessageList.scrollHeight;
  } else {
    chatTypingIndicator.classList.add('hidden');
  }
}

function appendChatBubble(msg) {
  const isUser = msg.role === 'user';
  const bubble = document.createElement('div');
  bubble.className = `flex items-start space-x-3 ${isUser ? 'justify-end' : 'justify-start'}`;

  const timeStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  let parsedContent = '';
  if (isUser) {
    parsedContent = `<p class="whitespace-pre-wrap">${escapeHtml(msg.content)}</p>`;
  } else {
    parsedContent = marked.parse(msg.content || '');
  }

  bubble.innerHTML = `
    ${!isUser ? `
      <div class="w-8 h-8 rounded-xl bg-gradient-to-tr from-brand-600 to-purple-600 text-white flex items-center justify-center text-xs flex-shrink-0 shadow-md">
        <i class="fa-solid fa-bolt"></i>
      </div>
    ` : ''}

    <div class="max-w-[85%] sm:max-w-2xl rounded-2xl p-4 ${
      isUser
        ? 'bg-brand-600 text-white rounded-br-none shadow-md shadow-brand-500/20'
        : 'bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder text-slate-800 dark:text-slate-100 rounded-bl-none shadow-sm'
    }">
      ${msg.attachment ? `
        <div class="mb-2 px-2.5 py-1 rounded-lg bg-black/15 text-xs flex items-center space-x-2">
          <i class="fa-solid fa-paperclip"></i>
          <span class="font-semibold">${escapeHtml(msg.attachment.name)}</span>
        </div>
      ` : ''}

      <div class="${isUser ? '' : 'markdown-body text-sm'}">${parsedContent}</div>

      <div class="mt-2 pt-2 border-t ${isUser ? 'border-white/20' : 'border-slate-100 dark:border-darkBorder/60'} flex items-center justify-between text-[11px] ${isUser ? 'text-white/70' : 'text-slate-400'}">
        <span>${timeStr}</span>
        ${!isUser ? `
          <div class="flex items-center space-x-3">
            <button onclick="copyBubbleText(this)" data-raw="${encodeURIComponent(msg.content)}" class="hover:text-brand-500 p-0.5" title="Copy text">
              <i class="fa-regular fa-copy"></i>
            </button>
            <button onclick="speakText(decodeURIComponent('${encodeURIComponent(msg.content)}'))" class="hover:text-brand-500 p-0.5" title="Read aloud">
              <i class="fa-solid fa-volume-high"></i>
            </button>
          </div>
        ` : ''}
      </div>
    </div>

    ${isUser ? `
      <div class="w-8 h-8 rounded-xl bg-brand-500/20 text-brand-600 dark:text-brand-400 flex items-center justify-center text-xs font-bold flex-shrink-0">
        <i class="fa-solid fa-user"></i>
      </div>
    ` : ''}
  `;

  chatMessageList.appendChild(bubble);

  // Apply code block copy buttons and syntax highlighting
  bubble.querySelectorAll('pre code').forEach((block) => {
    hljs.highlightElement(block);
    const pre = block.parentElement;
    if (!pre.querySelector('.code-copy-btn')) {
      const copyBtn = document.createElement('button');
      copyBtn.className = 'code-copy-btn';
      copyBtn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy';
      copyBtn.onclick = () => {
        navigator.clipboard.writeText(block.innerText);
        copyBtn.innerHTML = '<i class="fa-solid fa-check text-emerald-400"></i> Copied!';
        setTimeout(() => copyBtn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy', 2000);
      };
      pre.appendChild(copyBtn);
    }
  });

  chatMessageList.scrollTop = chatMessageList.scrollHeight;
}

function copyBubbleText(btn) {
  const raw = decodeURIComponent(btn.getAttribute('data-raw'));
  navigator.clipboard.writeText(raw);
  const icon = btn.querySelector('i');
  icon.className = 'fa-solid fa-check text-emerald-500';
  setTimeout(() => icon.className = 'fa-regular fa-copy', 2000);
}

// --- Courses Module ---
function initCoursesEvents() {
  // Event listeners for courses
}

async function loadCoursesList() {
  try {
    const res = await fetch(`${API_BASE}/courses`);
    const data = await res.json();
    if (data.success) {
      state.courses = data.data;
      renderCoursesGrid(state.courses);
    }
  } catch (err) {
    console.warn('Error loading courses:', err);
  }
}

function renderCoursesGrid(courses) {
  const container = document.getElementById('coursesGrid');
  if (!container) return;

  container.innerHTML = courses.map(c => `
    <div onclick="openCourseDetails('${c.id}')" class="cursor-pointer group p-6 rounded-2xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder hover:border-brand-500/50 shadow-sm hover:shadow-md transition-all flex flex-col justify-between">
      <div>
        <div class="flex items-center justify-between mb-3">
          <span class="px-2.5 py-1 rounded-lg bg-brand-500/10 text-brand-600 dark:text-brand-400 text-xs font-semibold">${escapeHtml(c.category)}</span>
          <span class="flex items-center text-xs font-bold text-amber-500">
            <i class="fa-solid fa-star text-[11px] mr-1"></i>${c.rating}
          </span>
        </div>
        <h3 class="font-bold text-base text-slate-900 dark:text-white group-hover:text-brand-600 dark:group-hover:text-brand-400 transition">${escapeHtml(c.title)}</h3>
        <p class="text-xs text-slate-500 dark:text-slate-400 mt-2 line-clamp-3 leading-relaxed">${escapeHtml(c.description)}</p>
      </div>

      <div class="mt-4 pt-4 border-t border-slate-100 dark:border-darkBorder/60 space-y-2">
        <div class="flex justify-between text-xs">
          <span class="text-slate-400">Progress</span>
          <span class="font-bold text-brand-600 dark:text-brand-400">${c.progressPercent}%</span>
        </div>
        <div class="w-full bg-slate-100 dark:bg-darkSurface h-1.5 rounded-full overflow-hidden">
          <div class="bg-brand-600 h-full rounded-full transition-all duration-300" style="width: ${c.progressPercent}%"></div>
        </div>
        <div class="flex items-center justify-between text-[11px] text-slate-400 pt-1">
          <span><i class="fa-regular fa-clock mr-1"></i>${c.duration}</span>
          <span class="font-semibold text-brand-600 dark:text-brand-400">${c.modules.length} Modules</span>
        </div>
      </div>
    </div>
  `).join('');
}

function openCourseDetails(courseId) {
  const course = state.courses.find(c => c.id === courseId);
  if (!course) return;
  state.currentCourse = course;

  document.getElementById('modalCourseLevel').innerText = course.level;
  document.getElementById('modalCourseTitle').innerText = course.title;
  document.getElementById('modalCourseDesc').innerText = course.description;
  document.getElementById('modalProgressText').innerText = `${course.progressPercent}%`;
  document.getElementById('modalProgressBar').style.width = `${course.progressPercent}%`;

  const modulesList = document.getElementById('modalModulesList');
  modulesList.innerHTML = course.modules.map((m, mIdx) => `
    <div class="rounded-xl border border-slate-200 dark:border-darkBorder p-4 bg-slate-50/50 dark:bg-darkSurface/30">
      <h5 class="font-bold text-xs uppercase tracking-wider text-slate-500 dark:text-slate-400 mb-2">Module ${mIdx + 1}: ${escapeHtml(m.title)}</h5>
      <div class="space-y-1.5">
        ${m.lessons.map(lesson => {
          const isDone = (course.completedLessons || []).includes(lesson);
          return `
            <div class="flex items-center justify-between p-2 rounded-lg bg-white dark:bg-darkCard border border-slate-100 dark:border-darkBorder/60">
              <label class="flex items-center space-x-2.5 cursor-pointer text-xs flex-1">
                <input type="checkbox" ${isDone ? 'checked' : ''} onchange="toggleLessonCompletion('${course.id}', '${lesson.replace(/'/g, "\\'")}', this.checked)" class="w-4 h-4 text-brand-600 rounded">
                <span class="${isDone ? 'line-through text-slate-400' : 'text-slate-800 dark:text-slate-200'}">${escapeHtml(lesson)}</span>
              </label>
              <button onclick="askMentorAboutLesson('${course.title.replace(/'/g, "\\'")}', '${lesson.replace(/'/g, "\\'")}')" class="text-xs text-brand-600 hover:text-brand-700 p-1" title="Ask AI Mentor to explain this lesson">
                <i class="fa-solid fa-chalkboard-user"></i>
              </button>
            </div>
          `;
        }).join('')}
      </div>
    </div>
  `).join('');

  document.getElementById('courseDetailModal').classList.remove('hidden');
}

function closeCourseModal() {
  document.getElementById('courseDetailModal').classList.add('hidden');
}

async function toggleLessonCompletion(courseId, lessonTitle, completed) {
  try {
    const res = await fetch(`${API_BASE}/courses/${courseId}/progress`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ lessonTitle, completed })
    });
    const data = await res.json();
    if (data.success) {
      await loadCoursesList();
      openCourseDetails(courseId);
    }
  } catch (err) {
    console.warn(err);
  }
}

function askMentorAboutLesson(courseTitle, lessonTitle) {
  closeCourseModal();
  switchView('chat');
  sendUserMessage(`Please mentor me on "${lessonTitle}" from "${courseTitle}". Explain the fundamental intuition, provide practical code examples, and suggest a hands-on exercise.`);
}

// --- Quiz Module ---
function initQuizEvents() {
  document.getElementById('generateQuizBtn')?.addEventListener('click', async () => {
    const topic = document.getElementById('quizTopicInput').value.trim() || 'Modern Technology';
    const difficulty = document.getElementById('quizDifficultySelect').value;
    const count = document.getElementById('quizCountSelect').value;

    const btn = document.getElementById('generateQuizBtn');
    btn.disabled = true;
    btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin mr-2"></i> Generating questions with AI...`;

    try {
      const res = await fetch(`${API_BASE}/quiz/generate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ topic, difficulty, count })
      });
      const data = await res.json();
      btn.disabled = false;
      btn.innerHTML = `<i class="fa-solid fa-sparkles mr-2"></i> Generate & Start Quiz`;

      if (data.success) {
        state.activeQuiz = data.data;
        state.quizAnswers = {};
        renderQuizTaker(data.data);
      }
    } catch (err) {
      btn.disabled = false;
      btn.innerHTML = `<i class="fa-solid fa-sparkles mr-2"></i> Generate & Start Quiz`;
      alert('Error generating quiz: ' + err.message);
    }
  });

  document.getElementById('submitQuizBtn')?.addEventListener('click', async () => {
    if (!state.activeQuiz) return;
    const btn = document.getElementById('submitQuizBtn');
    btn.disabled = true;
    btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin mr-2"></i> Evaluating with AI...`;

    try {
      const res = await fetch(`${API_BASE}/quiz/evaluate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          quizId: state.activeQuiz.id,
          answers: state.quizAnswers
        })
      });
      const data = await res.json();
      btn.disabled = false;
      btn.innerText = 'Submit Answers & Evaluate';

      if (data.success) {
        renderQuizResult(data.data);
        loadQuizHistory();
      }
    } catch (err) {
      btn.disabled = false;
      btn.innerText = 'Submit Answers & Evaluate';
      alert('Error evaluating quiz: ' + err.message);
    }
  });
}

function renderQuizTaker(quiz) {
  document.getElementById('quizGeneratorCard').classList.add('hidden');
  document.getElementById('quizResultCard').classList.add('hidden');
  document.getElementById('quizTakerCard').classList.remove('hidden');

  document.getElementById('quizActiveTitle').innerText = `Topic: ${quiz.topic} (${quiz.difficulty})`;
  document.getElementById('quizAnsweredCount').innerText = `0 of ${quiz.questions.length} answered`;

  const container = document.getElementById('quizQuestionsContainer');
  container.innerHTML = quiz.questions.map((q, qIdx) => `
    <div class="p-6 rounded-2xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder space-y-3">
      <h4 class="font-bold text-sm text-slate-900 dark:text-white">${qIdx + 1}. ${escapeHtml(q.question)}</h4>
      <div class="space-y-2">
        ${q.options.map((opt, optIdx) => `
          <label class="flex items-center space-x-3 p-3 rounded-xl border border-slate-200 dark:border-darkBorder hover:bg-brand-500/5 cursor-pointer text-xs font-medium transition">
            <input type="radio" name="question_${q.id}" onchange="selectQuizOption('${q.id}', ${optIdx}, ${quiz.questions.length})" class="w-4 h-4 text-brand-600">
            <span>${escapeHtml(opt)}</span>
          </label>
        `).join('')}
      </div>
    </div>
  `).join('');
}

function selectQuizOption(questionId, optionIndex, total) {
  state.quizAnswers[questionId] = optionIndex;
  const count = Object.keys(state.quizAnswers).length;
  document.getElementById('quizAnsweredCount').innerText = `${count} of ${total} answered`;
}

function renderQuizResult(result) {
  document.getElementById('quizTakerCard').classList.add('hidden');
  const card = document.getElementById('quizResultCard');
  card.classList.remove('hidden');

  const isPassed = result.scorePercent >= 60;

  card.innerHTML = `
    <div class="p-8 rounded-3xl ${isPassed ? 'bg-gradient-to-r from-emerald-600 to-teal-700' : 'bg-gradient-to-r from-red-600 to-rose-700'} text-white shadow-xl flex items-center space-x-6">
      <div class="w-20 h-20 rounded-full bg-white/20 flex items-center justify-center text-3xl font-black">
        ${result.scorePercent}%
      </div>
      <div>
        <h3 class="text-2xl font-bold">${isPassed ? 'Excellent Performance! 🎉' : 'Keep Learning! 📚'}</h3>
        <p class="text-sm text-white/90 mt-1">You answered ${result.correctCount} of ${result.totalQuestions} questions correctly.</p>
      </div>
    </div>

    <div class="space-y-3">
      <h4 class="text-xs font-bold uppercase tracking-wider text-slate-400">Pedagogical Review & Explanations</h4>
      ${result.breakdown.map((item, idx) => `
        <div class="p-5 rounded-2xl bg-white dark:bg-darkCard border ${item.isCorrect ? 'border-emerald-500/40' : 'border-red-500/40'} space-y-2">
          <div class="flex items-center space-x-2">
            <i class="fa-solid ${item.isCorrect ? 'fa-circle-check text-emerald-500' : 'fa-circle-xmark text-red-500'}"></i>
            <h5 class="font-bold text-sm">${idx + 1}. ${escapeHtml(item.question)}</h5>
          </div>
          <p class="text-xs ${item.isCorrect ? 'text-emerald-600 dark:text-emerald-400' : 'text-red-500'}">
            Your Answer: ${escapeHtml(item.userAnswerText)}
          </p>
          ${!item.isCorrect ? `<p class="text-xs text-emerald-600 dark:text-emerald-400 font-semibold">Correct Answer: ${escapeHtml(item.correctAnswerText)}</p>` : ''}
          <div class="p-3 rounded-xl bg-slate-50 dark:bg-darkSurface text-xs text-slate-600 dark:text-slate-300 leading-relaxed">
            💡 <strong>Explanation:</strong> ${escapeHtml(item.explanation)}
          </div>
        </div>
      `).join('')}
    </div>

    <button onclick="resetQuizInterface()" class="w-full py-3 rounded-xl bg-brand-600 hover:bg-brand-700 text-white font-bold text-sm shadow-md transition">
      Take Another AI Quiz
    </button>
  `;
}

function resetQuizInterface() {
  document.getElementById('quizResultCard').classList.add('hidden');
  document.getElementById('quizGeneratorCard').classList.remove('hidden');
}

async function loadQuizHistory() {
  try {
    const res = await fetch(`${API_BASE}/quiz/history`);
    const data = await res.json();
    if (data.success) {
      const container = document.getElementById('quizHistoryList');
      if (!container) return;
      const history = data.data.history || [];
      if (history.length === 0) {
        container.innerHTML = `<p class="text-xs text-slate-400 italic">No previous quizzes taken yet.</p>`;
        return;
      }
      container.innerHTML = history.slice(0, 5).map(h => `
        <div class="p-4 rounded-xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder flex items-center justify-between text-xs">
          <div>
            <p class="font-bold text-slate-800 dark:text-slate-200">${escapeHtml(h.topic)}</p>
            <p class="text-[11px] text-slate-400">${h.correctCount}/${h.totalQuestions} correct • ${h.difficulty} level</p>
          </div>
          <span class="px-2.5 py-1 rounded-lg font-bold ${h.scorePercent >= 60 ? 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-400' : 'bg-red-500/10 text-red-500'}">
            ${h.scorePercent}%
          </span>
        </div>
      `).join('');
    }
  } catch (e) {
    console.warn(e);
  }
}

// --- Learning Hub Events ---
function initLearnEvents() {
  document.querySelectorAll('.learn-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.learn-tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.learn-subpanel').forEach(p => p.classList.add('hidden'));

      tab.classList.add('active');
      const target = tab.getAttribute('data-learntab');
      document.getElementById(`learnPanel-${target}`)?.classList.remove('hidden');
    });
  });

  document.getElementById('runExplainBtn')?.addEventListener('click', async () => {
    const topic = document.getElementById('learnExplainTopic').value.trim();
    const level = document.getElementById('learnExplainLevel').value;
    if (!topic) return;

    renderLearnOutputLoading('Formulating simple analogies and step-by-step breakdown...');
    try {
      const res = await fetch(`${API_BASE}/learn/explain`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ topic, level })
      });
      const data = await res.json();
      if (data.success) {
        renderLearnOutput(data.data.explanation);
      }
    } catch (e) {
      renderLearnOutput('Error: ' + e.message);
    }
  });

  document.getElementById('runNotesBtn')?.addEventListener('click', async () => {
    const topic = document.getElementById('learnNotesTopic').value.trim();
    const format = document.getElementById('learnNotesFormat').value;
    if (!topic) return;

    renderLearnOutputLoading('Synthesizing high-yield study notes & core cheat sheet...');
    try {
      const res = await fetch(`${API_BASE}/learn/notes`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ topic, format })
      });
      const data = await res.json();
      if (data.success) {
        renderLearnOutput(data.data.notes);
      }
    } catch (e) {
      renderLearnOutput('Error: ' + e.message);
    }
  });

  document.getElementById('runCodeBtn')?.addEventListener('click', async () => {
    const code = document.getElementById('learnCodeSnippet').value.trim();
    const language = document.getElementById('learnCodeLanguage').value;
    if (!code) return;

    renderLearnOutputLoading('Debugging code bottlenecks and generating optimized implementation...');
    try {
      const res = await fetch(`${API_BASE}/learn/code-assist`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code, language })
      });
      const data = await res.json();
      if (data.success) {
        renderLearnOutput(data.data.result);
      }
    } catch (e) {
      renderLearnOutput('Error: ' + e.message);
    }
  });
}

function renderLearnOutputLoading(msg) {
  const box = document.getElementById('learnOutputBox');
  const content = document.getElementById('learnOutputContent');
  box.classList.remove('hidden');
  content.innerHTML = `<div class="flex items-center space-x-2 text-brand-600"><i class="fa-solid fa-spinner fa-spin"></i><span>${msg}</span></div>`;
}

function renderLearnOutput(markdownText) {
  const box = document.getElementById('learnOutputBox');
  const content = document.getElementById('learnOutputContent');
  box.classList.remove('hidden');
  content.innerHTML = marked.parse(markdownText);
  content.querySelectorAll('pre code').forEach((block) => hljs.highlightElement(block));
}

// --- History & Recent Conversations ---
async function loadRecentConversations() {
  try {
    const res = await fetch(`${API_BASE}/chat/conversations`);
    const data = await res.json();
    if (data.success) {
      const container = document.getElementById('sidebarRecentChats');
      if (!container) return;
      const list = data.data || [];
      if (list.length === 0) {
        container.innerHTML = `<p class="px-3 text-[11px] text-slate-400 italic">No chats yet</p>`;
        return;
      }
      container.innerHTML = list.slice(0, 5).map(c => `
        <button onclick="resumeConversation('${c.id}')" class="w-full text-left px-3 py-1.5 rounded-lg text-xs hover:bg-slate-100 dark:hover:bg-darkSurface text-slate-600 dark:text-slate-300 truncate flex items-center space-x-2 transition">
          <i class="fa-regular fa-comment text-[10px] text-slate-400"></i>
          <span class="truncate">${escapeHtml(c.title)}</span>
        </button>
      `).join('');
    }
  } catch (e) {
    console.warn(e);
  }
}

async function loadHistoryView() {
  const container = document.getElementById('historyConversationsList');
  if (!container) return;
  try {
    const res = await fetch(`${API_BASE}/chat/conversations`);
    const data = await res.json();
    if (data.success) {
      const list = data.data || [];
      if (list.length === 0) {
        container.innerHTML = `<p class="text-sm text-slate-400 italic text-center py-10">No conversation history found.</p>`;
        return;
      }
      container.innerHTML = list.map(c => `
        <div class="p-4 rounded-xl bg-white dark:bg-darkCard border border-slate-200 dark:border-darkBorder flex items-center justify-between">
          <div onclick="resumeConversation('${c.id}')" class="cursor-pointer flex-1 mr-4">
            <h4 class="font-bold text-sm text-slate-900 dark:text-white hover:text-brand-600 transition">${escapeHtml(c.title)}</h4>
            <p class="text-xs text-slate-400 mt-1">${c.messageCount || 0} messages • ${new Date(c.updatedAt).toLocaleDateString()}</p>
          </div>
          <button onclick="deleteConversation('${c.id}', event)" class="p-2 text-slate-400 hover:text-red-500 rounded-lg" title="Delete conversation">
            <i class="fa-regular fa-trash-can"></i>
          </button>
        </div>
      `).join('');
    }
  } catch (e) {
    container.innerHTML = `<p class="text-sm text-red-500">${e.message}</p>`;
  }
}

async function resumeConversation(convId) {
  try {
    const res = await fetch(`${API_BASE}/chat/conversations/${convId}`);
    const data = await res.json();
    if (data.success) {
      state.activeConversationId = convId;
      state.messages = data.data.messages || [];
      switchView('chat');
      chatMessageList.innerHTML = '';
      state.messages.forEach(msg => appendChatBubble(msg));
    }
  } catch (e) {
    alert('Error resuming conversation: ' + e.message);
  }
}

async function deleteConversation(convId, event) {
  event?.stopPropagation();
  if (!confirm('Are you sure you want to delete this conversation?')) return;
  try {
    await fetch(`${API_BASE}/chat/conversations/${convId}`, { method: 'DELETE' });
    if (state.activeConversationId === convId) {
      startNewChat();
    }
    loadRecentConversations();
    loadHistoryView();
  } catch (e) {
    alert(e.message);
  }
}

// --- User Profile & Metrics ---
async function loadUserProfile() {
  try {
    const res = await fetch(`${API_BASE}/auth/profile`);
    const data = await res.json();
    if (data.success) {
      const p = data.data.profile;
      const s = data.data.stats;

      document.getElementById('homeWelcomeName').innerText = p.name || 'Explorer';
      document.getElementById('sidebarUserName').innerText = p.name || 'Vision Explorer';
      document.getElementById('profileNameDisplay').innerText = p.name || 'Vision Explorer';
      document.getElementById('profileEmailDisplay').innerText = p.email || 'explorer@visionai.io';
      document.getElementById('profileBioDisplay').innerText = p.bio || 'Exploring Vision AI Multimodal capabilities';

      document.getElementById('metricChats').innerText = s.conversationsCount || 0;
      document.getElementById('metricQuizzes').innerText = s.quizzesTaken || 0;
      document.getElementById('metricAvgScore').innerText = `${s.avgQuizScore || 0}%`;
      document.getElementById('metricLessons').innerText = s.totalLessonsFinished || 0;
    }
  } catch (e) {
    console.warn(e);
  }
}

// --- Settings & Gemini API Key Management ---
function initSettingsEvents() {
  document.getElementById('saveApiKeyBtn')?.addEventListener('click', async () => {
    const apiKey = document.getElementById('settingsApiKeyInput').value.trim();
    const model = document.getElementById('settingsModelSelect').value;

    const btn = document.getElementById('saveApiKeyBtn');
    const resultEl = document.getElementById('settingsKeySaveResult');
    btn.disabled = true;
    btn.innerText = 'Verifying with Google Gemini...';

    try {
      const res = await fetch(`${API_BASE}/config/update-key`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ apiKey, model })
      });
      const data = await res.json();
      btn.disabled = false;
      btn.innerText = 'Verify & Save Configuration';

      resultEl.classList.remove('hidden');
      resultEl.innerText = data.message;
      resultEl.className = 'text-xs font-semibold ' + (data.success ? 'text-emerald-500' : 'text-red-500');

      checkConfigStatus();
    } catch (e) {
      btn.disabled = false;
      btn.innerText = 'Verify & Save Configuration';
      alert('Error updating key: ' + e.message);
    }
  });
}

async function checkConfigStatus() {
  try {
    const res = await fetch(`${API_BASE}/config/status`);
    const data = await res.json();
    if (data.success) {
      state.geminiStatus = data.data;
      const pill = document.getElementById('settingsKeyStatusPill');
      const headerBadge = document.getElementById('geminiStatusBadge');

      if (data.data.hasGeminiApiKey) {
        if (pill) {
          pill.innerText = 'Cloud Gemini Key Active';
          pill.className = 'text-xs font-bold px-2.5 py-1 rounded-full bg-emerald-500/15 text-emerald-600 dark:text-emerald-400';
        }
        if (headerBadge) {
          headerBadge.innerHTML = `<span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span><span>${data.data.geminiModel} Active</span>`;
        }
      } else {
        if (pill) {
          pill.innerText = 'Local Intelligent Mode';
          pill.className = 'text-xs font-bold px-2.5 py-1 rounded-full bg-amber-500/15 text-amber-600 dark:text-amber-400';
        }
        if (headerBadge) {
          headerBadge.innerHTML = `<span class="w-1.5 h-1.5 rounded-full bg-brand-500"></span><span>Vision AI Intelligent Engine</span>`;
        }
      }
    }
  } catch (e) {
    console.warn(e);
  }
}

// --- Utilities ---
function escapeHtml(string) {
  const div = document.createElement('div');
  div.innerText = string || '';
  return div.innerHTML;
}

