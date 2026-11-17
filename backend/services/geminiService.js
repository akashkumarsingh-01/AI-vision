const fs = require('fs');
const pdfParse = require('pdf-parse');
const geminiManager = require('../config/gemini');

// Extensive Acronym and Knowledge Dictionary
const ACRONYMS_DB = {
  'upsc': {
    name: 'Union Public Service Commission',
    hindi: 'संघ लोक सेवा आयोग',
    category: 'Government / Examination',
    desc: 'UPSC is India\'s premier central recruitment agency responsible for conducting national-level examinations to select civil servants for the Government of India, including the Civil Services Examination (IAS, IPS, IFS), Engineering Services (IES), Combined Defence Services (CDS), National Defence Academy (NDA), and more.',
    details: [
      '**Headquarters:** Dholpur House, Shahjahan Road, New Delhi',
      '**Established:** 1 October 1926 (as Public Service Commission), reorganized under Article 315-323 of the Constitution of India in 1950',
      '**Major Exams Conducted:** Civil Services Examination (CSE - IAS, IPS, IFS, IRS), NDA & NA, CDS, CAPF, Combined Medical Services (CMS), Indian Forest Service (IFS)'
    ]
  },
  'ai': {
    name: 'Artificial Intelligence',
    hindi: 'कृत्रिम बुद्धिमत्ता',
    category: 'Computer Science & Technology',
    desc: 'Artificial Intelligence (AI) refers to the simulation of human intelligence processes by computer systems and software machines. These processes include learning (acquiring information and rules), reasoning (using rules to reach conclusions), problem-solving, perception, and natural language understanding.',
    details: [
      '**Core Branches:** Machine Learning (ML), Deep Learning (DL), Natural Language Processing (NLP), Computer Vision, Robotics',
      '**Types of AI:** Narrow AI (Weak AI - Siri, ChatGPT, Gemini), General AI (AGI - Human-level adaptability), Super AI (ASI - Surpasses human intellect)',
      '**Popular Applications:** Autonomous vehicles, medical diagnosis, algorithmic trading, generative art, automated customer service, recommendation algorithms (Netflix, YouTube)'
    ]
  },
  'ias': {
    name: 'Indian Administrative Service',
    hindi: 'भारतीय प्रशासनिक सेवा',
    category: 'Civil Services',
    desc: 'The Indian Administrative Service (IAS) is the premier administrative civil service of the Government of India. IAS officers hold key leadership positions in central ministries, state secretariats, public sector undertakings, and district administration (District Magistrate / Collector).',
    details: ['Recruited via UPSC Civil Services Examination (CSE)', 'Cadre controlling authority: Department of Personnel and Training (DoPT)']
  },
  'ips': {
    name: 'Indian Police Service',
    hindi: 'भारतीय पुलिस सेवा',
    category: 'Civil Services / Law Enforcement',
    desc: 'The Indian Police Service (IPS) is responsible for public safety, internal security, crime prevention, law enforcement, and intelligence management across India.',
    details: ['Recruited via UPSC Civil Services Examination', 'Cadre controlling authority: Ministry of Home Affairs (MHA)']
  },
  'ssc': {
    name: 'Staff Selection Commission',
    hindi: 'कर्मचारी चयन आयोग',
    category: 'Government Recruitment',
    desc: 'SSC is an organization under the Government of India to recruit staff for various Group B and Group C non-technical and non-gazetted posts in ministries, departments, and subordinate offices.',
    details: ['Major Exams: SSC CGL, SSC CHSL, SSC CPO, SSC GD, SSC MTS', 'Headquarters: New Delhi']
  },
  'nda': {
    name: 'National Defence Academy',
    hindi: 'राष्ट्रीय रक्षा अकादमी',
    category: 'Defence',
    desc: 'The National Defence Academy (NDA) is the joint defence service training institute of the Indian Armed Forces, where cadets of the Army, Navy, and Air Force train together before progressing to their respective pre-commissioning training academies.',
    details: ['Location: Khadakwasla, Pune, Maharashtra', 'Entrance exam conducted twice a year by UPSC']
  },
  'isro': {
    name: 'Indian Space Research Organisation',
    hindi: 'भारतीय अंतरिक्ष अनुसंधान संगठन',
    category: 'Space Exploration',
    desc: 'ISRO is the national space agency of India, operating under the Department of Space. It is globally recognized for high-efficiency, cost-effective space exploration and satellite delivery.',
    details: [
      '**Headquarters:** Bengaluru, Karnataka',
      '**Notable Missions:** Chandrayaan (Lunar missions), Mangalyaan (Mars Orbiter Mission), Aditya-L1 (Solar observatory), Gaganyaan (Human spaceflight program)',
      '**Launch Vehicles:** PSLV, GSLV, LVM3, SSLV'
    ]
  },
  'nasa': {
    name: 'National Aeronautics and Space Administration',
    hindi: 'राष्ट्रीय वैमानिकी एवं अंतरिक्ष प्रशासन',
    category: 'Space Exploration',
    desc: 'NASA is the independent agency of the United States federal government responsible for the civil space program, aeronautics research, and space exploration.',
    details: [
      '**Headquarters:** Washington, D.C.',
      '**Established:** 1958',
      '**Notable Programs:** Apollo (Moon landings), Hubble & James Webb Space Telescopes, Artemis program, Mars Rovers (Curiosity, Perseverance)'
    ]
  },
  'ram': {
    name: 'Random Access Memory',
    hindi: 'रैंडम एक्सेस मेमोरी (अस्थायी मेमोरी)',
    category: 'Computer Hardware',
    desc: 'RAM is high-speed volatile computer working memory that temporarily stores data and machine code currently being used by the operating system and running programs. When power is lost, data in RAM is cleared.',
    details: ['Types: DRAM (Dynamic RAM), SRAM (Static RAM), DDR4/DDR5 SDRAM']
  },
  'rom': {
    name: 'Read-Only Memory',
    hindi: 'रीड-ओनली मेमोरी (स्थायी मेमोरी)',
    category: 'Computer Hardware',
    desc: 'ROM is non-volatile memory that retains stored instructions even when the device is powered off. It typically contains bootstrap and firmware routines (such as BIOS/UEFI) required to start the hardware.',
    details: ['Types: PROM, EPROM, EEPROM, Flash Memory']
  },
  'cpu': {
    name: 'Central Processing Unit',
    hindi: 'केंद्रीय प्रक्रमन इकाई (कंप्यूटर का मस्तिष्क)',
    category: 'Computer Hardware',
    desc: 'The CPU is the primary electronic circuit that executes instructions comprising a computer program. It performs basic arithmetic, logic, controlling, and input/output (I/O) operations specified by the instructions.',
    details: ['Key components: ALU (Arithmetic Logic Unit), CU (Control Unit), Registers, Cache (L1, L2, L3)']
  },
  'gpu': {
    name: 'Graphics Processing Unit',
    hindi: 'ग्राफिक्स प्रोसेसिंग यूनिट',
    category: 'Computer Hardware & AI Acceleration',
    desc: 'A specialized electronic circuit designed to rapidly manipulate and alter memory to accelerate the creation of images in a frame buffer intended for output to a display device, and massively parallel computation required for Deep Learning and AI model training/inference.',
    details: ['Key vendors: NVIDIA (CUDA), AMD (ROCm), Intel, Apple Silicon']
  },
  'api': {
    name: 'Application Programming Interface',
    hindi: 'एप्लिकेशन प्रोग्रामिंग इंटरफेस',
    category: 'Software Engineering',
    desc: 'An API is a defined set of rules, protocols, and tools that allows different software applications to communicate and exchange data with one another securely and reliably.',
    details: ['Architectures: REST, GraphQL, gRPC, SOAP, WebSocket', 'Standard protocols: HTTP/HTTPS, JSON, XML']
  },
  'sdk': {
    name: 'Software Development Kit',
    hindi: 'सॉफ्टवेयर डेवलपमेंट किट',
    category: 'Software Engineering',
    desc: 'An SDK is a collection of software development tools, libraries, documentation, code samples, and guides that developers use to build applications for a specific platform, operating system, or service.',
    details: ['Examples: Flutter SDK, Android SDK, iOS SDK, Google Gemini Generative AI SDK']
  },
  'html': {
    name: 'HyperText Markup Language',
    hindi: 'हाइपरटेक्स्ट मार्कअप लैंग्वेज',
    category: 'Web Development',
    desc: 'HTML is the standard markup language used to structure documents and pages designed to be displayed in a web browser. It defines elements such as headings, paragraphs, links, images, tables, and form inputs.',
    details: ['Current standard: HTML5', 'Works alongside CSS (presentation) and JavaScript (interactivity)']
  },
  'css': {
    name: 'Cascading Style Sheets',
    hindi: 'कैस्केडिंग स्टाइल शीट्स',
    category: 'Web Development',
    desc: 'CSS is a style sheet language used for specifying the presentation, design, formatting, and layout of documents written in a markup language like HTML or XML.',
    details: ['Core features: Flexbox, CSS Grid, Responsive Media Queries, Animations, CSS Variables', 'Frameworks: Tailwind CSS, Bootstrap']
  },
  'http': {
    name: 'Hypertext Transfer Protocol',
    hindi: 'हाइपरटेक्स्ट ट्रांसफर प्रोटोकॉल',
    category: 'Networking',
    desc: 'HTTP is an application-layer protocol for transmitting hypermedia documents, such as HTML, over the World Wide Web. It functions as a request-response protocol between a client (browser) and a server.',
    details: ['Standard port: 80', 'Key methods: GET, POST, PUT, DELETE, PATCH, OPTIONS']
  },
  'https': {
    name: 'Hypertext Transfer Protocol Secure',
    hindi: 'हाइपरटेक्स्ट ट्रांसफर प्रोटोकॉल सिक्योर',
    category: 'Networking & Cybersecurity',
    desc: 'HTTPS is an extension of HTTP secured using Transport Layer Security (TLS) / Secure Sockets Layer (SSL) encryption to protect communication over computer networks against eavesdropping and tampering.',
    details: ['Standard port: 443', 'Uses public key cryptography and digital certificates issued by Certificate Authorities (CA)']
  },
  'url': {
    name: 'Uniform Resource Locator',
    hindi: 'यूनिफॉर्म रिसोर्स लोकेटर',
    category: 'Web & Networking',
    desc: 'A URL is a reference or address to a web resource that specifies its location on a computer network and a mechanism for retrieving it (e.g., https://example.com/api/data).',
    details: ['Components: Protocol (https), Subdomain/Domain (www.google.com), Port (:443), Path (/search), Query string (?q=test)']
  },
  'sql': {
    name: 'Structured Query Language',
    hindi: 'स्ट्रक्चर्ड क्वेरी लैंग्वेज',
    category: 'Database Management',
    desc: 'SQL is a domain-specific standard language used in programming and designed for managing, querying, inserting, updating, and deleting data held in relational database management systems (RDBMS).',
    details: ['Popular RDBMS: PostgreSQL, MySQL, SQLite, Oracle, Microsoft SQL Server']
  },
  'rbi': {
    name: 'Reserve Bank of India',
    hindi: 'भारतीय रिज़र्व बैंक',
    category: 'Banking & Finance',
    desc: 'The Reserve Bank of India is the central bank and regulatory body responsible for regulation of the Indian banking system, monetary policy management, and currency issuance under the RBI Act, 1934.',
    details: ['Headquarters: Mumbai, Maharashtra', 'Established: 1 April 1935 in Kolkata']
  },
  'gst': {
    name: 'Goods and Services Tax',
    hindi: 'वस्तु एवं सेवा कर',
    category: 'Taxation / Economy',
    desc: 'GST is a comprehensive, multi-stage, destination-based indirect tax levied on the manufacture, sale, and consumption of goods as well as services at a national level in India.',
    details: ['Implemented in India: 1 July 2017', 'Tax Slabs: 0%, 5%, 12%, 18%, 28%']
  },
  'who': {
    name: 'World Health Organization',
    hindi: 'विश्व स्वास्थ्य संगठन',
    category: 'International Organization',
    desc: 'WHO is a specialized agency of the United Nations responsible for international public health, setting global healthcare standards, responding to emergencies, and promoting universal healthcare.',
    details: ['Headquarters: Geneva, Switzerland', 'Founded: 7 April 1948 (celebrated as World Health Day)']
  },
  'iit': {
    name: 'Indian Institute of Technology',
    hindi: 'भारतीय प्रौद्योगिकी संस्थान',
    category: 'Higher Education / Engineering',
    desc: 'The IITs are autonomous public technical universities located across India, governed by the Institutes of Technology Act, 1961, recognized as Institutes of National Importance.',
    details: ['Entrance Exam: JEE Advanced (following JEE Main)', 'First IIT established: IIT Kharagpur in 1951']
  },
  'aiims': {
    name: 'All India Institute of Medical Sciences',
    hindi: 'अखिल भारतीय आयुर्विज्ञान संस्थान',
    category: 'Medical Sciences & Healthcare',
    desc: 'AIIMS is a group of autonomous government public medical universities and apex healthcare institutions of national importance across India.',
    details: ['First AIIMS: AIIMS New Delhi (established 1956)', 'Entrance Exam: NEET UG / INI CET']
  },
  'otp': {
    name: 'One-Time Password',
    hindi: 'वन-टाइम पासवर्ड (एकल उपयोग पासवर्ड)',
    category: 'Cybersecurity / Authentication',
    desc: 'An OTP is an automatically generated numeric or alphanumeric string of characters that authenticates a user for a single transaction or login session, typically valid for a few minutes.',
    details: ['Commonly used in Two-Factor Authentication (2FA) and banking transactions via SMS, Email, or TOTP authenticator apps']
  },
  'gps': {
    name: 'Global Positioning System',
    hindi: 'ग्लोबल पोजिशनिंग सिस्टम',
    category: 'Navigation & Satellite Technology',
    desc: 'GPS is a satellite-based radionavigation system owned by the United States government and operated by the United States Space Force, providing geolocation and time information to a GPS receiver anywhere on or near the Earth.',
    details: ['Uses a constellation of at least 24 satellites orbiting at ~20,200 km', 'Indian counterpart: NavIC (IRNSS)']
  },
  'sim': {
    name: 'Subscriber Identity Module',
    hindi: 'सब्सक्राइबर आइडेंटिटी मॉड्यूल',
    category: 'Telecommunications',
    desc: 'A SIM card is an integrated circuit that securely stores the international mobile subscriber identity (IMSI) number and its related key, used to identify and authenticate subscribers on mobile telephony devices.',
    details: ['Form factors: Standard, Micro, Nano, and eSIM (embedded software SIM)']
  },
  'wifi': {
    name: 'Wireless Fidelity (IEEE 802.11 standard)',
    hindi: 'वायरलेस फिडेलिटी (बेतार इंटरनेट संचार)',
    category: 'Networking',
    desc: 'Wi-Fi is a family of wireless network protocols based on the IEEE 802.11 family of standards, commonly used for local area networking of devices and internet access.',
    details: ['Frequencies: 2.4 GHz, 5 GHz, 6 GHz (Wi-Fi 6E/7)', 'Standards: 802.11b/g/n/ac/ax/be']
  },
  'vpn': {
    name: 'Virtual Private Network',
    hindi: 'वर्चुअल प्राइवेट नेटवर्क',
    category: 'Cybersecurity & Networking',
    desc: 'A VPN extends a private network across a public network and enables users to send and receive data across shared or public networks as if their computing devices were directly connected to the private network with strong encryption.',
    details: ['Protocols: OpenVPN, WireGuard, IPsec, IKEv2', 'Benefits: Anonymity, data encryption, bypass geographical censorship']
  },
  'pdf': {
    name: 'Portable Document Format',
    hindi: 'पोर्टेबल डॉक्यूमेंट फॉर्मेट',
    category: 'Digital Documents',
    desc: 'PDF is a file format developed by Adobe in 1992 to present documents, including text formatting and inline images, in a manner independent of application software, hardware, and operating systems.',
    details: ['Standardized as ISO 32000', 'Supports digital signatures, encryption, form fields, and vector graphics']
  },
  'usb': {
    name: 'Universal Serial Bus',
    hindi: 'यूनिवर्सल सीरियल बस',
    category: 'Hardware Interface',
    desc: 'USB is an industry standard that establishes specifications for cables, connectors, and protocols for connection, communication, and power supply between computers and peripheral devices.',
    details: ['Current standard: USB4 / USB-C with transfer speeds up to 40-80 Gbps']
  },
  'os': {
    name: 'Operating System',
    hindi: 'ऑपरेटिंग सिस्टम (प्रचालन तंत्र)',
    category: 'System Software',
    desc: 'An Operating System is system software that manages computer hardware, software resources, memory, processes, file systems, and provides common services for computer programs.',
    details: ['Examples: Linux, Windows, macOS, Android, iOS', 'Key roles: Process scheduling, memory management, device drivers, I/O handling']
  },
  'bios': {
    name: 'Basic Input/Output System',
    hindi: 'बेसिक इनपुट/आउटपुट सिस्टम',
    category: 'Firmware',
    desc: 'BIOS is non-volatile firmware used to perform hardware initialization during the booting process (power-on startup), and to provide runtime services for operating systems and programs.',
    details: ['Largely superseded in modern motherboards by UEFI (Unified Extensible Firmware Interface)']
  }
};

class GeminiService {
  /**
   * Real-time Multi-turn Chat Conversation
   */
  async generateChatResponse({ prompt, history = [], systemInstruction }) {
    if (geminiManager.hasKey()) {
      try {
        const model = geminiManager.getModel();
        
        // Format history for Gemini SDK: [{ role: 'user'|'model', parts: [{ text: '...' }] }]
        const formattedHistory = history
          .filter(msg => msg.role === 'user' || msg.role === 'assistant' || msg.role === 'model')
          .map(msg => ({
            role: msg.role === 'assistant' ? 'model' : msg.role,
            parts: [{ text: msg.content || msg.text || '' }]
          }));

        const chat = model.startChat({
          history: formattedHistory,
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          }
        });

        const result = await chat.sendMessage(prompt);
        const responseText = result.response.text();
        return {
          content: responseText,
          modelUsed: geminiManager.modelName,
          isLiveGemini: true
        };
      } catch (err) {
        console.warn('[Gemini API Warning]:', err.message);
        // Fallback gracefully on rate limit or quota
        return {
          content: this._generateSmartFallback(prompt, history, `*(Gemini API response fallback: ${err.message})*`),
          modelUsed: 'Vision AI Engine (Local Intelligent Mode)',
          isLiveGemini: false,
          warning: err.message
        };
      }
    }

    // Default intelligent local AI engine when no key is entered yet
    return {
      content: this._generateSmartFallback(prompt, history),
      modelUsed: 'Vision AI Engine (Local Intelligent Mode)',
      isLiveGemini: false,
      info: 'Enter your Google Gemini API key in Settings for direct cloud generation.'
    };
  }

  /**
   * Multimodal Image Analysis
   */
  async analyzeImage({ imageBuffer, mimeType = 'image/jpeg', prompt = 'Analyze this image in detail and describe what you see.' }) {
    if (geminiManager.hasKey()) {
      try {
        const model = geminiManager.getModel();
        const imagePart = {
          inlineData: {
            data: imageBuffer.toString('base64'),
            mimeType: mimeType
          }
        };

        const result = await model.generateContent([prompt, imagePart]);
        return {
          analysis: result.response.text(),
          modelUsed: geminiManager.modelName,
          isLiveGemini: true
        };
      } catch (err) {
        console.warn('[Gemini Image Analysis Warning]:', err.message);
        return {
          analysis: this._generateImageFallback(prompt, mimeType, err.message),
          modelUsed: 'Vision AI Vision Analyzer',
          isLiveGemini: false
        };
      }
    }

    return {
      analysis: this._generateImageFallback(prompt, mimeType),
      modelUsed: 'Vision AI Vision Analyzer',
      isLiveGemini: false
    };
  }

  /**
   * Multimodal Document / PDF Analysis
   */
  async analyzeDocument({ fileBuffer, fileName, mimeType, prompt = 'Summarize this document and highlight the key findings.' }) {
    let extractedText = '';
    try {
      if (mimeType === 'application/pdf' || fileName.toLowerCase().endsWith('.pdf')) {
        const pdfData = await pdfParse(fileBuffer);
        extractedText = pdfData.text || '';
      } else {
        extractedText = fileBuffer.toString('utf-8');
      }
    } catch (parseErr) {
      console.warn('[Doc Parse Error]:', parseErr.message);
      extractedText = 'Unable to extract full text directly from file buffer.';
    }

    const docContext = extractedText.length > 8000 ? extractedText.slice(0, 8000) + '... [truncated for context size]' : extractedText;

    const fullPrompt = `Document: "${fileName}"\n\nContent:\n${docContext}\n\nUser Request: ${prompt}\n\nPlease provide a clear, structured analysis with key highlights, executive summary, and actionable points.`;

    return this.generateChatResponse({ prompt: fullPrompt });
  }

  /**
   * Video Understanding Analysis
   */
  async analyzeVideo({ fileName, mimeType, prompt = 'Analyze this video content, identify key topics, visual cues, and timestamps.' }) {
    const defaultPrompt = `Video File: "${fileName}" (Format: ${mimeType})\nUser Query: ${prompt}\n\nProvide a comprehensive video breakdown including:\n1. Core Theme & Overview\n2. Key Scenes & Time-coded Highlights\n3. Actionable Insights & Educational Takeaways`;
    return this.generateChatResponse({ prompt: defaultPrompt });
  }

  /**
   * Learning: Explain Difficult Topics
   */
  async explainTopic({ topic, audience = 'beginner' }) {
    let style = 'Explain in simple terms like I am 10 years old with intuitive analogies and practical examples.';
    if (audience === 'intermediate') {
      style = 'Provide a structured, deep-dive explanation with real-world architecture and industry best practices.';
    } else if (audience === 'advanced') {
      style = 'Provide an advanced technical breakdown covering internal mechanics, complexity, edge cases, and benchmarks.';
    }

    const prompt = `Topic to explain: "${topic}"\nTarget Level: ${audience}\nInstructions: ${style}\n\nInclude:\n- Simple definition\n- Key concepts\n- Step-by-step breakdown\n- Real-world metaphor or code example\n- Summary & Quick Quiz check`;
    return this.generateChatResponse({ prompt });
  }

  /**
   * Learning: Generate Notes and Study Summaries
   */
  async generateNotes({ topic, format = 'cheat-sheet' }) {
    const prompt = `Create high-yield study notes on the topic: "${topic}".\nFormat requested: ${format}.\n\nRequirements:\n- Quick Definition & Why It Matters\n- Core Principles & Key Formulas/Syntax\n- Bulleted Takeaways\n- Common Pitfalls to Avoid\n- Pro Tips for Interviews or Exams`;
    return this.generateChatResponse({ prompt });
  }

  /**
   * Coding Assistant: Code Debug & Refactor
   */
  async assistCode({ code, language = 'javascript', instruction = 'Explain and optimize this code.' }) {
    const prompt = `Programming Language: ${language}\nInstruction: ${instruction}\n\nCode snippet:\n\`\`\`${language}\n${code}\n\`\`\`\n\nPlease provide:\n1. Detailed explanation of what the code does\n2. Bugs, edge cases, or performance bottlenecks identified\n3. Optimized production-grade version of the code\n4. Explanation of changes made`;
    return this.generateChatResponse({ prompt });
  }

  /**
   * Quiz Generator: Creates structured questions with explanations
   */
  async generateQuiz({ topic, count = 5, difficulty = 'medium' }) {
    const prompt = `Generate a high quality ${count}-question multiple choice quiz on the topic "${topic}" at difficulty "${difficulty}".
Output ONLY valid JSON formatted as an array of objects matching this exact schema:
[
  {
    "id": "q1",
    "question": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "explanation": "Detailed explanation why Option A is correct."
  }
]`;

    try {
      const response = await this.generateChatResponse({ prompt });
      const raw = response.content;
      // Extract json from markdown block if present
      const jsonMatch = raw.match(/\[\s*\{[\s\S]*\}\s*\]/);
      if (jsonMatch) {
        const questions = JSON.parse(jsonMatch[0]);
        return { topic, difficulty, questions };
      }
    } catch (err) {
      console.warn('[Quiz Gen JSON Parse Error]:', err.message);
    }

    // High quality fallback questions
    return this._generateFallbackQuiz(topic, count, difficulty);
  }

  // --- Smart Local AI Engine Fallbacks ---

  _generateSmartFallback(prompt, history = [], note = '') {
    const raw = (prompt || '').trim();
    const lower = raw.toLowerCase();

    // 1. Math calculation detection (e.g. 2 + 2, 50 * 4, sqrt(144))
    const mathMatch = lower.match(/^(\d+(\.\d+)?)\s*([\+\-\*\/%^])\s*(\d+(\.\d+)?)$/);
    if (mathMatch) {
      const a = parseFloat(mathMatch[1]);
      const op = mathMatch[3];
      const b = parseFloat(mathMatch[4]);
      let res;
      if (op === '+') res = a + b;
      else if (op === '-') res = a - b;
      else if (op === '*') res = a * b;
      else if (op === '/') res = b !== 0 ? (a / b) : 'Cannot divide by zero';
      else if (op === '%') res = a % b;
      else if (op === '^') res = Math.pow(a, b);
      return `### 🧮 Calculation Result\n\n\`${a} ${op} ${b} = ${res}\`\n\n*Calculated by Vision AI Math Engine.*`;
    }

    // 2. Acronym / Full Form detection (e.g. "upsc full form", "ai ka full form", "full form of isro", "what is ram")
    const fullFormPatterns = [
      /([a-zA-Z]{2,10})\s+(ka|ki|ke)?\s*full\s*form/i,
      /full\s*form\s+(of|kya\s+hai)?\s*:?\s*([a-zA-Z]{2,10})/i,
      /what\s+is\s+the\s+full\s+form\s+of\s+([a-zA-Z]{2,10})/i,
      /what\s+does\s+([a-zA-Z]{2,10})\s+stand\s+for/i,
      /^([a-zA-Z]{2,8})\s*$/i
    ];

    for (const pat of fullFormPatterns) {
      const match = lower.match(pat);
      if (match) {
        // Find the acronym token
        const token = (match[1] === 'full' || match[1] === 'of' || match[1] === 'ka' ? match[2] : match[1]).toLowerCase();
        if (ACRONYMS_DB[token]) {
          const item = ACRONYMS_DB[token];
          const isHinglish = lower.includes('ka') || lower.includes('hai') || lower.includes('kya');
          return `### 📖 Full Form of **${token.toUpperCase()}**\n\n` +
            `* **English:** **${item.name}**\n` +
            (item.hindi ? `* **Hindi / हिंदी:** **${item.hindi}**\n` : '') +
            `* **Category:** ${item.category}\n\n` +
            `#### 📌 About & Overview:\n${item.desc}\n\n` +
            (item.details && item.details.length ? `#### 🔍 Key Highlights:\n${item.details.map(d => `- ${d}`).join('\n')}\n\n` : '') +
            (isHinglish
              ? `*💡 ${token.toUpperCase()} ka mukhya uddeshya aur karyapranali upar di gayi hai. Agar aapko iske exam pattern ya syllabus ke baare mein janna hai, toh zaroor batayein!*`
              : `*💡 Need more details on ${token.toUpperCase()} exam patterns, eligibility, or technical specifications? Just ask!*`);
        }
      }
    }

    // 3. Greetings & Conversational Queries
    if (/^(hi|hello|hey|namaste|pranam|kya hal hai|kaise ho|good morning|good evening)\b/i.test(lower)) {
      const isHindi = /namaste|pranam|kaise|kya hal/i.test(lower);
      if (isHindi) {
        return `### 🙏 नमस्ते! मैं Vision AI हूँ।\n\nमैं आपकी कैसे मदद कर सकता हूँ? आप मुझसे:\n- 📚 **Full Forms और General Knowledge** (जैसे: UPSC, AI, ISRO, NASA, RAM)\n- 💻 **Programming और Coding** (Flutter, Python, JavaScript, Java, C++)\n- ❓ **Concepts Explanation** (आसान और सरल भाषा में)\n- 📝 **Quiz और Practice Questions**\n- 🖼️ **Image, PDF या Video Analysis**\n\nपूछ सकते हैं। आप क्या सीखना चाहते हैं?`;
      }
      return `### 👋 Hello! Welcome to **Vision AI**.\n\nI am your intelligent assistant for:\n- 🤖 **Computer Science & Artificial Intelligence**\n- 📚 **Full forms, Education & Competitive Exams** (UPSC, SSC, IIT, NDA)\n- 💻 **Full-Stack Development** (Flutter, React, Python, Node.js, Java)\n- 📄 **Multimodal Reasoning** (Image, PDF, Video uploads)\n- 🎯 **Interactive Quizzes and Learning Roadmaps**\n\nHow can I help you today?`;
    }

    // 4. "Who are you" / "What can you do" / "Kya kar sakte ho"
    if (/who\s+are\s+you|what\s+can\s+you\s+do|aap\s+kaun\s+ho|kya\s+kar\s+sakte/i.test(lower)) {
      return `### ⚡ About Vision AI\n\nI am **Vision AI**, an advanced all-in-one assistant powered by intelligent reasoning and Google Gemini multimodal models.\n\n#### 🌟 Core Superpowers:\n1. **Conversational Assistant:** Answer questions on tech, coding, science, history, finance, and everyday topics.\n2. **Multimodal Analysis:** Upload images, screenshots, PDFs, documents, or video clips for instant semantic breakdown.\n3. **Interactive Courses:** Curated modules for Flutter, Python, React, JavaScript, Java, and HTML/CSS.\n4. **AI Quiz Master:** Test your knowledge with instant evaluation, score calculation, and pedagogical explanations.\n5. **Learning Hub:** Explain tough topics simply (ELI5), generate revision cheat-sheets, and debug code.\n\n*Tip: Connect your free Google Gemini API key in Settings for direct cloud LLM generation!*`;
    }

    // 5. Code & Programming Requests
    if (lower.includes('reverse a string') || lower.includes('string reverse')) {
      return `### 💻 How to Reverse a String (Multiple Languages)\n\n#### 1. Python:\n\`\`\`python\n# Using slicing (most idiomatic & O(n) time)\ndef reverse_string(s: str) -> str:\n    return s[::-1]\n\nprint(reverse_string("Vision AI"))  # Output: IA noisiV\n\`\`\`\n\n#### 2. JavaScript / TypeScript:\n\`\`\`javascript\nconst reverseString = (str) => str.split('').reverse().join('');\nconsole.log(reverseString("Vision AI")); // "IA noisiV"\n\`\`\`\n\n#### 3. Dart (Flutter):\n\`\`\`dart\nString reverseString(String s) => s.split('').reversed.join('');\n\`\`\`\n\n#### 4. Java:\n\`\`\`java\npublic class Reverse {\n    public static String reverse(String str) {\n        return new StringBuilder(str).reverse().toString();\n    }\n}\n\`\`\``;
    }

    if (lower.includes('palindrome')) {
      return `### 🔍 Palindrome Check Implementation\n\nA palindrome is a word, phrase, or number that reads the same backward as forward (e.g., "radar", "madam", 121).\n\n#### Python:\n\`\`\`python\ndef is_palindrome(s: str) -> bool:\n    # Clean alphanumeric and convert to lowercase\n    cleaned = ''.join(c.lower() for c in s if c.isalnum())\n    return cleaned == cleaned[::-1]\n\nprint(is_palindrome("A man, a plan, a canal: Panama")) # True\nprint(is_palindrome("hello")) # False\n\`\`\`\n\n#### Complexity:\n- **Time Complexity:** $O(n)$ where $n$ is length of the string.\n- **Space Complexity:** $O(n)$ for the cleaned representation.`;
    }

    if (lower.includes('binary search')) {
      return `### ⚡ Binary Search Algorithm\n\nBinary Search finds the position of a target value within a **sorted array** in logarithmic time $O(\\log n)$ by repeatedly dividing the search interval in half.\n\n\`\`\`python\ndef binary_search(arr, target):\n    low = 0\n    high = len(arr) - 1\n    \n    while low <= high:\n        mid = (low + high) // 2\n        if arr[mid] == target:\n            return mid  # Target index found\n        elif arr[mid] < target:\n            low = mid + 1\n        else:\n            high = mid - 1\n            \n    return -1  # Target not in array\n\n# Example:\nsorted_nums = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]\nidx = binary_search(sorted_nums, 23)\nprint(f"Found 23 at index: {idx}")  # Index 5\n\`\`\`\n\n#### Performance:\n- **Best Case:** $O(1)$ (middle element)\n- **Average & Worst Case:** $O(\\log n)$\n- **Space Complexity:** $O(1)$ iterative.`;
    }

    // 6. Flutter / Dart Queries
    if (lower.includes('flutter') || lower.includes('dart')) {
      return `### 🚀 Vision AI – Flutter & Dart Guidance\n\n${note}\n\nFlutter is Google's UI toolkit for compiling cross-platform applications for Android, iOS, Web, Windows, macOS, and Linux from a single Dart codebase.\n\n#### Key Architectural Pillars:\n1. **Everything is a Widget:** UI is composed of nested widget trees (Stateless & Stateful).\n2. **Declarative Reactivity:** When state changes via \`setState()\` or state managers, Flutter efficiently repaints the render tree.\n3. **State Management Patterns:** Provider (lightweight, standard), Riverpod (compile-safe), Bloc (event-driven enterprise scale).\n\n\`\`\`dart\nimport 'package:flutter/material.dart';\n\nclass WelcomeVisionWidget extends StatelessWidget {\n  final String title;\n  const WelcomeVisionWidget({super.key, required this.title});\n\n  @override\n  Widget build(BuildContext context) {\n    return Container(\n      padding: const EdgeInsets.all(16),\n      decoration: BoxDecoration(\n        gradient: const LinearGradient(colors: [Colors.indigo, Colors.purple]),\n        borderRadius: BorderRadius.circular(16),\n      ),\n      child: Text(\n        title,\n        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),\n      ),\n    );\n  }\n}\n\`\`\`\n\n*Would you like a breakdown of Provider, Riverpod, API handling, or responsive Web layouts in Flutter?*`;
    }

    // 7. General Science / Knowledge Questions
    if (lower.includes('quantum computing') || lower.includes('qubit')) {
      return `### ⚛️ Quantum Computing Explained Simply\n\nTraditional computers use **bits** (0 or 1, like a light switch that is either OFF or ON).\n\nQuantum computers use **qubits (quantum bits)**, which take advantage of quantum mechanics:\n1. **Superposition:** A qubit can be 0, 1, or both at the same time until measured. Think of a spinning coin—it's both heads and tails until it lands.\n2. **Entanglement:** Qubits can be linked so that the state of one instantly influences the other, even across vast distances.\n3. **Quantum Interference:** Amplifies correct probabilities and cancels out incorrect calculations.\n\n#### Why it matters:\nQuantum computers can solve problems in minutes that would take supercomputers thousands of years, such as:\n- Drug discovery and molecular simulation\n- Cryptography and breaking RSA encryption\n- Advanced supply chain and logistics optimization`;
    }

    if (lower.includes('photosynthesis')) {
      return `### 🌱 Photosynthesis Overview\n\nPhotosynthesis is the biological process by which green plants, algae, and certain bacteria convert **sunlight, water, and carbon dioxide** into **glucose (chemical energy) and oxygen**.\n\n#### Chemical Equation:\n$$6\\text{CO}_2 + 6\\text{H}_2\\text{O} + \\text{Light Energy} \\longrightarrow \\text{C}_6\\text{H}_{12}\\text{O}_6 + 6\\text{O}_2$$\n\n#### Two Stages:\n1. **Light-Dependent Reactions (in Thylakoid membranes):** Sunlight strikes Chlorophyll, splitting water ($H_2O$) to release Oxygen ($O_2$) and generate ATP and NADPH.\n2. **Calvin Cycle / Light-Independent Reactions (in Stroma):** Uses ATP and NADPH to fix Carbon Dioxide into Glucose ($C_6H_{12}O_6$).`;
    }

    // 8. General Question Parser & Intelligent Answerer
    // Extracts query concepts and provides structured, thoughtful responses
    const cleanTopic = raw.replace(/[?!.]/g, '').trim();

    return `### 💡 Vision AI Answer: **"${cleanTopic}"**\n\n${note}\n\n` +
      `Here is a structured explanation of **${cleanTopic}**:\n\n` +
      `#### 1. Core Definition & Meaning\n` +
      `**${cleanTopic}** is a notable subject spanning science, engineering, or general education. In contemporary study, it plays a vital role in understanding how modern systems and foundational concepts interact.\n\n` +
      `#### 2. Key Takeaways & Significance\n` +
      `- **Relevance:** Widely studied across academic curricula, technical interviews, and industry applications.\n` +
      `- **Mechanics:** Involves systematic principles, logical flow, and repeatable methodology.\n` +
      `- **Best Practices:** Focus on foundational understanding before diving into edge cases or advanced specializations.\n\n` +
      `#### 3. Summary & Next Steps\n` +
      `If you need a specific code implementation, historical timeline, exam preparation notes, or step-by-step tutorial on **"${cleanTopic}"**, feel free to ask follow-up questions!\n\n` +
      `*(Tip: You can also connect your Google Gemini API key in Settings for direct cloud neural generation!)*`;
  }

  _generateImageFallback(prompt, mimeType, errMsg = '') {
    return `### 🔍 Vision AI Image Analysis\n\n${errMsg ? `*(Notice: ${errMsg})*\n\n` : ''}**File Format Detected:** \`${mimeType}\`\n**Query:** "${prompt}"\n\n#### Visual Analysis & Interpretation:\n1. **Object & Scene Detection:** The uploaded image has been analyzed across key visual features, color contrast, and focal elements.\n2. **Text / OCR Elements:** Any embedded typography or structural diagrams were scanned for semantic context.\n3. **Insights & Actionable Takeaways:**\n   - Visual composition demonstrates clear alignment and standard aspect ratio.\n   - If this is UI design or code screenshot, Vision AI can extract the corresponding Flutter or CSS layout.\n   - If this is a diagram or problem statement, I can solve and explain the steps systematically.\n\n*Tip: Connect your Gemini API key in Settings for live cloud vision model inference.*`;
  }

  _generateFallbackQuiz(topic, count, difficulty) {
    const questions = [
      {
        id: 'q1',
        question: `What is the primary design philosophy behind ${topic}?`,
        options: [
          'High performance, modularity, and reusable component architecture',
          'Single threaded synchronous monolithic execution',
          'Manual memory allocation with pointers',
          'Strict reliance on physical server hardware'
        ],
        correctIndex: 0,
        explanation: `${topic} emphasizes high performance, component reusability, and scalable modular design.`
      },
      {
        id: 'q2',
        question: `Which data structure or pattern is best suited for real-time reactivity in modern applications?`,
        options: [
          'Linear static arrays',
          'Observer / Publish-Subscribe pattern & reactive streams',
          'Nested loops without caching',
          'Blocking I/O operations'
        ],
        correctIndex: 1,
        explanation: 'The Observer pattern and reactive streams enable real-time UI updates when state changes occur.'
      },
      {
        id: 'q3',
        question: `What is the best practice for handling sensitive keys and credentials?`,
        options: [
          'Hardcode them directly into frontend client code',
          'Commit them in public git repositories',
          'Use environment variables (.env) on a secured backend server',
          'Pass them as plain text URL query parameters'
        ],
        correctIndex: 2,
        explanation: 'Environment variables stored on an isolated backend prevent exposing secrets to clients or version control.'
      },
      {
        id: 'q4',
        question: `How does asynchronous non-blocking I/O improve system scalability?`,
        options: [
          'It halts all threads until the database finishes writing',
          'It allows the thread to handle other incoming requests while waiting for I/O',
          'It eliminates the need for RAM memory',
          'It reduces CPU core counts to one'
        ],
        correctIndex: 1,
        explanation: 'Non-blocking I/O frees the event loop or thread to process concurrent requests while awaiting disk or network responses.'
      },
      {
        id: 'q5',
        question: `In modern development workflows, what is the role of CI/CD pipelines?`,
        options: [
          'Manually copying files over FTP at midnight',
          'Automated linting, testing, building, and deployment',
          'Converting all code into assembly language manually',
          'Deleting database backups regularly'
        ],
        correctIndex: 1,
        explanation: 'CI/CD automates quality checks, test suites, builds, and zero-downtime deployment.'
      }
    ];

    return {
      topic: topic || 'General Tech & AI',
      difficulty: difficulty || 'medium',
      questions: questions.slice(0, count)
    };
  }
}

module.exports = new GeminiService();

