const { body, param, query, validationResult } = require('express-validator');

/**
 * Process validation results and return 400 if any errors exist.
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array().map(e => ({
        field: e.path,
        message: e.msg,
      })),
    });
  }
  next();
};

// Auth validations
const loginRules = [
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
];

const registerRules = [
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').isEmail().withMessage('Valid email is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
];

// Content validations
const duaRules = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('arabic_text').trim().notEmpty().withMessage('Arabic text is required'),
  body('category_id').optional().isUUID().withMessage('Invalid category ID'),
  body('is_published').optional().isBoolean(),
];

const podcastRules = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('podcast_url').trim().isURL().withMessage('Valid podcast URL is required'),
  body('category_id').optional().isUUID().withMessage('Invalid category ID'),
  body('is_published').optional().isBoolean(),
];

const videoRules = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('video_url').trim().isURL().withMessage('Valid video URL is required'),
  body('category_id').optional().isUUID().withMessage('Invalid category ID'),
  body('is_published').optional().isBoolean(),
];

const pdfRules = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('pdf_url').trim().isURL().withMessage('Valid PDF URL is required'),
  body('category_id').optional().isUUID().withMessage('Invalid category ID'),
  body('is_published').optional().isBoolean(),
];

const categoryRules = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('name_ar').trim().notEmpty().withMessage('Arabic name is required'),
  body('type').isIn(['dua', 'podcast', 'video', 'pdf']).withMessage('Type must be dua, podcast, video, or pdf'),
];

// Common param/query validations
const uuidParam = [
  param('id').isUUID().withMessage('Invalid ID format'),
];

const paginationQuery = [
  query('page').optional().isInt({ min: 1 }).toInt(),
  query('limit').optional().isInt({ min: 1, max: 100 }).toInt(),
  query('search').optional().trim(),
  query('category_id').optional().isUUID(),
];

const syncQuery = [
  query('updated_since').optional().isISO8601().withMessage('updated_since must be ISO 8601 date'),
];

module.exports = {
  validate,
  loginRules,
  registerRules,
  duaRules,
  podcastRules,
  videoRules,
  pdfRules,
  categoryRules,
  uuidParam,
  paginationQuery,
  syncQuery,
};
