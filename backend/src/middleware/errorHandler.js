/**
 * Global error handler middleware.
 * Catches all unhandled errors and returns consistent JSON responses.
 */
const errorHandler = (err, req, res, _next) => {
  console.error('Error:', err);

  // Sequelize validation error
  if (err.name === 'SequelizeValidationError') {
    const errors = err.errors.map(e => ({
      field: e.path,
      message: e.message,
    }));
    return res.status(400).json({ error: 'Validation failed', details: errors });
  }

  // Sequelize unique constraint error
  if (err.name === 'SequelizeUniqueConstraintError') {
    const fields = Object.keys(err.fields || {});
    return res.status(409).json({
      error: 'Duplicate entry',
      fields,
    });
  }

  // Sequelize foreign key constraint error
  if (err.name === 'SequelizeForeignKeyConstraintError') {
    return res.status(400).json({
      error: 'Referenced record not found',
    });
  }

  // Custom API error
  if (err.statusCode) {
    return res.status(err.statusCode).json({
      error: err.message,
    });
  }

  // Default server error
  const statusCode = err.statusCode || 500;
  const message = process.env.NODE_ENV === 'production'
    ? 'Internal server error'
    : err.message || 'Internal server error';

  res.status(statusCode).json({ error: message });
};

module.exports = errorHandler;
