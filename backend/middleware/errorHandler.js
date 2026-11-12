function notFound(req, res, next) {
  res.status(404).json({
    success: false,
    message: `Resource not found at: ${req.originalUrl}`
  });
}

function errorHandler(err, req, res, next) {
  console.error('[Vision AI Error]:', err.stack || err.message);
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' ? { stack: err.stack } : {})
  });
}

module.exports = { notFound, errorHandler };

