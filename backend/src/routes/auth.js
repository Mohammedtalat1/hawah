const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const { loginRules, registerRules, validate } = require('../middleware/validation');

router.post('/register', registerRules, validate, authController.register);
router.post('/login', loginRules, validate, authController.login);
router.post('/refresh', authController.refreshToken);
router.get('/profile', authenticate, authController.getProfile);

module.exports = router;
