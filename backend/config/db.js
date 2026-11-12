const fs = require('fs');
const path = require('path');

const DB_FILE = path.join(__dirname, '..', 'data', 'db.json');

// Default initial state with seed courses
const initialCourses = [
  {
    id: 'course-flutter',
    title: 'Flutter & Dart: Cross-Platform Mastery',
    category: 'Mobile & Web',
    icon: 'mobile_friendly',
    level: 'Beginner to Advanced',
    duration: '18 hours',
    rating: 4.9,
    studentsCount: 3420,
    description: 'Build native iOS, Android, and Web applications from a single codebase using Flutter and Dart. Master widgets, state management, animations, and API integration.',
    modules: [
      {
        id: 'm1',
        title: 'Introduction to Dart & Object-Oriented Programming',
        lessons: [
          'Dart Syntax, Variables, Null Safety',
          'Functions, Classes, and Mixins',
          'Asynchronous Programming: Futures & Streams'
        ]
      },
      {
        id: 'm2',
        title: 'Flutter UI Fundamentals & Layout System',
        lessons: [
          'Stateless vs Stateful Widgets',
          'Rows, Columns, Flex, and Stack Layouts',
          'Theming, Material 3, and Typography'
        ]
      },
      {
        id: 'm3',
        title: 'State Management & Architecture',
        lessons: [
          'Provider and Riverpod patterns',
          'Clean Architecture and Repository Pattern',
          'REST API integration with http and dio'
        ]
      },
      {
        id: 'm4',
        title: 'Advanced Features & Deployment',
        lessons: [
          'Custom Animations & Hero Transitions',
          'Web optimization and responsive layouts',
          'Building and publishing for Web & Mobile'
        ]
      }
    ]
  },
  {
    id: 'course-python',
    title: 'Python for AI & Modern Development',
    category: 'Programming & AI',
    icon: 'terminal',
    level: 'All Levels',
    duration: '22 hours',
    rating: 4.95,
    studentsCount: 5210,
    description: 'From syntax to AI algorithms. Master Python 3, object-oriented design, data manipulation with Pandas, automation, and integrating Gemini LLM APIs.',
    modules: [
      {
        id: 'm1',
        title: 'Python Essentials & Data Structures',
        lessons: [
          'Data Types, Lists, Dicts, Sets & Comprehensions',
          'Functions, *args, **kwargs, Decorators',
          'Error Handling, Context Managers & OOP'
        ]
      },
      {
        id: 'm2',
        title: 'Working with APIs and Data',
        lessons: [
          'HTTP requests, JSON parsing and web scraping',
          'Data handling with Pandas & NumPy',
          'File I/O, CSV, and SQLite integration'
        ]
      },
      {
        id: 'm3',
        title: 'Building AI Assistants & Automation',
        lessons: [
          'Integrating Google Gemini Generative AI SDK',
          'Prompt Engineering & Structured JSON Outputs',
          'Building CLI tools and FastAPI microservices'
        ]
      }
    ]
  },
  {
    id: 'course-react',
    title: 'Modern React 19 & Full-Stack Systems',
    category: 'Web Development',
    icon: 'code',
    level: 'Intermediate',
    duration: '16 hours',
    rating: 4.88,
    studentsCount: 4120,
    description: 'Learn modern React hooks, server components, state management with Zustand/Redux, Tailwind CSS, and connecting to Express REST APIs.',
    modules: [
      {
        id: 'm1',
        title: 'React Core & Modern Hooks',
        lessons: [
          'JSX, Props, useState & useEffect mastery',
          'useMemo, useCallback & Performance optimization',
          'Custom Hooks and Reusable UI components'
        ]
      },
      {
        id: 'm2',
        title: 'State Management & Routing',
        lessons: [
          'React Router 6.4+ nested routes and loaders',
          'Global State: Context API vs Zustand',
          'React Query (TanStack Query) for API data caching'
        ]
      },
      {
        id: 'm3',
        title: 'Production Full-Stack Integration',
        lessons: [
          'Connecting to Node.js & Express REST APIs',
          'Authentication flows: JWT and Protected Routes',
          'Deployment on Vercel and Netlify'
        ]
      }
    ]
  },
  {
    id: 'course-javascript',
    title: 'JavaScript: Zero to ESNext Hero',
    category: 'Web Development',
    icon: 'javascript',
    level: 'Beginner to Intermediate',
    duration: '15 hours',
    rating: 4.85,
    studentsCount: 6300,
    description: 'Master the backbone of web development: Event loops, closures, prototypes, asynchronous JavaScript, modern ES6+ features, and DOM manipulation.',
    modules: [
      {
        id: 'm1',
        title: 'Foundations & Scope',
        lessons: [
          'Variables, Datatypes, Operators and Type Coercion',
          'Execution Context, Hoisting, Scope and Closures',
          'Higher-Order Functions and Array methods'
        ]
      },
      {
        id: 'm2',
        title: 'Asynchronous JavaScript & Web APIs',
        lessons: [
          'Event Loop, Microtasks, and Callbacks',
          'Promises, Async/Await and Error Handling',
          'Fetch API, LocalStorage and Event Listeners'
        ]
      }
    ]
  },
  {
    id: 'course-java',
    title: 'Java 21 & Enterprise Architecture',
    category: 'Enterprise Software',
    icon: 'developer_board',
    level: 'Intermediate',
    duration: '20 hours',
    rating: 4.8,
    studentsCount: 2890,
    description: 'Comprehensive Java course covering modern OOP, Generics, Collections Framework, Streams API, Virtual Threads, and backend REST microservices.',
    modules: [
      {
        id: 'm1',
        title: 'OOP & Core Language',
        lessons: [
          'Polymorphism, Inheritance, Encapsulation, Abstraction',
          'Interfaces, Records, and Sealed Classes',
          'Exception Handling and Custom Exceptions'
        ]
      },
      {
        id: 'm2',
        title: 'Collections & Modern Features',
        lessons: [
          'Lists, Sets, Maps, and Hash Algorithms',
          'Streams API and Lambda Expressions',
          'Virtual Threads and Concurrency'
        ]
      }
    ]
  },
  {
    id: 'course-html-css',
    title: 'HTML5 & Modern CSS3 / Flex & Grid Mastery',
    category: 'Web Design',
    icon: 'html',
    level: 'Beginner',
    duration: '10 hours',
    rating: 4.9,
    studentsCount: 7100,
    description: 'Create stunning, accessible, responsive websites with semantic HTML5, CSS Flexbox, Grid, CSS Variables, smooth transitions, and keyframe animations.',
    modules: [
      {
        id: 'm1',
        title: 'Semantic HTML5 & Accessibility',
        lessons: [
          'Semantic Structure: Header, Nav, Main, Section, Footer',
          'Forms, Inputs, Validation and Accessibility (a11y)',
          'SEO best practices and meta tags'
        ]
      },
      {
        id: 'm2',
        title: 'Modern CSS3 Layouts & Animations',
        lessons: [
          'CSS Box Model, Positioning, and Flexbox',
          'CSS Grid for 2D responsive layouts',
          'Media Queries, Custom Properties & Glassmorphism'
        ]
      }
    ]
  }
];

class Database {
  constructor() {
    this.data = {
      users: [],
      conversations: [],
      courses: initialCourses,
      userProgress: {}, // { userId_courseId: { completedLessons: [], progressPercent: 0 } }
      quizzes: [],
      quizResults: [],
      settings: {
        geminiApiKey: process.env.GEMINI_API_KEY || '',
        geminiModel: process.env.GEMINI_MODEL || 'gemini-1.5-flash',
        aiTemperature: 0.7,
        systemName: 'Vision AI Assistant'
      }
    };
    this.init();
  }

  init() {
    try {
      const dataDir = path.dirname(DB_FILE);
      if (!fs.existsSync(dataDir)) {
        fs.mkdirSync(dataDir, { recursive: true });
      }

      if (fs.existsSync(DB_FILE)) {
        const raw = fs.readFileSync(DB_FILE, 'utf-8');
        const parsed = JSON.parse(raw);
        this.data = {
          ...this.data,
          ...parsed,
          courses: (parsed.courses && parsed.courses.length > 0) ? parsed.courses : initialCourses
        };
      } else {
        this.save();
      }
    } catch (err) {
      console.error('[DB] Error loading database file:', err.message);
    }
  }

  save() {
    try {
      fs.writeFileSync(DB_FILE, JSON.stringify(this.data, null, 2), 'utf-8');
    } catch (err) {
      console.error('[DB] Error saving database file:', err.message);
    }
  }

  // Helper collections
  get(collection) {
    return this.data[collection] || [];
  }

  set(collection, value) {
    this.data[collection] = value;
    this.save();
  }
}

const db = new Database();
module.exports = db;

