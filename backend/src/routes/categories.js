const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { authenticate, requireAdmin } = require('../middleware/auth');
const { categoryRules, uuidParam, validate } = require('../middleware/validation');

// Public
router.get('/', categoryController.list);
router.get('/:id', uuidParam, validate, categoryController.getById);

// Admin
router.get('/admin/all', authenticate, requireAdmin, categoryController.adminList);
router.post('/admin', authenticate, requireAdmin, categoryRules, validate, categoryController.create);
router.put('/admin/:id', authenticate, requireAdmin, uuidParam, validate, categoryController.update);
router.delete('/admin/:id', authenticate, requireAdmin, uuidParam, validate, categoryController.remove);

module.exports = router;
