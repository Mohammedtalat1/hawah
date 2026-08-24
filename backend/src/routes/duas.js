const express = require('express');
const router = express.Router();
const { Dua } = require('../models');
const createContentController = require('../controllers/contentController');
const { authenticate, requireAdmin } = require('../middleware/auth');
const { duaRules, uuidParam, paginationQuery, syncQuery, validate } = require('../middleware/validation');

const controller = createContentController(Dua, {
  searchFields: ['title', 'arabic_text'],
});

// Public
router.get('/', paginationQuery, validate, controller.list);
router.get('/sync', syncQuery, validate, controller.sync);
router.get('/:id', uuidParam, validate, controller.getById);

// Admin
router.get('/admin/all', authenticate, requireAdmin, paginationQuery, validate, controller.adminList);
router.get('/admin/:id', authenticate, requireAdmin, uuidParam, validate, controller.adminGetById);
router.post('/admin', authenticate, requireAdmin, duaRules, validate, controller.create);
router.put('/admin/:id', authenticate, requireAdmin, uuidParam, validate, controller.update);
router.delete('/admin/:id', authenticate, requireAdmin, uuidParam, validate, controller.remove);
router.patch('/admin/:id/publish', authenticate, requireAdmin, uuidParam, validate, controller.togglePublish);

module.exports = router;
