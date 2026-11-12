const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadDir = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Memory storage for immediate streaming/buffering to Gemini API
const storage = multer.memoryStorage();

const allowedMimeTypes = [
  // Images
  'image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/bmp',
  // Documents
  'application/pdf', 'text/plain', 'text/markdown', 'application/json',
  // Videos
  'video/mp4', 'video/webm', 'video/quicktime', 'video/x-matroska'
];

const fileFilter = (req, file, cb) => {
  if (allowedMimeTypes.includes(file.mimetype) || file.mimetype.startsWith('image/') || file.mimetype.startsWith('video/')) {
    cb(null, true);
  } else {
    cb(new Error(`Unsupported file type: ${file.mimetype}. Allowed: Images, PDFs, Text documents, and Videos.`), false);
  }
};

const maxFileSize = (parseInt(process.env.MAX_FILE_SIZE_MB, 10) || 25) * 1024 * 1024;

const upload = multer({
  storage: storage,
  limits: { fileSize: maxFileSize },
  fileFilter: fileFilter
});

module.exports = upload;

