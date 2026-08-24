const express = require('express');
const router = express.Router();

const authRoutes = require('./auth');
const categoryRoutes = require('./categories');
const duaRoutes = require('./duas');
const podcastRoutes = require('./podcasts');
const videoRoutes = require('./videos');
const pdfRoutes = require('./pdfs');
const syncRoutes = require('./sync');

router.use('/auth', authRoutes);
router.use('/categories', categoryRoutes);
router.use('/duas', duaRoutes);
router.use('/podcasts', podcastRoutes);
router.use('/videos', videoRoutes);
router.use('/pdfs', pdfRoutes);
router.use('/sync', syncRoutes);

module.exports = router;
