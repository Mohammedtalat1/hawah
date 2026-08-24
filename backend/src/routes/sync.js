const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { Category, Dua, Podcast, Video, Pdf } = require('../models');

/**
 * GET /api/sync/all — Incremental sync for all content types
 * Query: updated_since (ISO 8601)
 *
 * Returns all content updated after the given timestamp.
 * Client stores sync_timestamp and uses it for next sync.
 */
router.get('/all', async (req, res, next) => {
  try {
    const { updated_since } = req.query;
    const where = { is_published: true };
    const catWhere = { is_active: true };

    if (updated_since) {
      const since = new Date(updated_since);
      where.updated_at = { [Op.gt]: since };
      catWhere.updated_at = { [Op.gt]: since };
    }

    const categoryInclude = [
      { model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] },
    ];

    const [categories, duas, podcasts, videos, pdfs] = await Promise.all([
      Category.findAll({ where: catWhere, order: [['updated_at', 'ASC']] }),
      Dua.findAll({ where, include: categoryInclude, order: [['updated_at', 'ASC']], limit: 200 }),
      Podcast.findAll({ where, include: categoryInclude, order: [['updated_at', 'ASC']], limit: 200 }),
      Video.findAll({ where, include: categoryInclude, order: [['updated_at', 'ASC']], limit: 200 }),
      Pdf.findAll({ where, include: categoryInclude, order: [['updated_at', 'ASC']], limit: 200 }),
    ]);

    res.json({
      data: {
        categories,
        duas,
        podcasts,
        videos,
        pdfs,
      },
      sync_timestamp: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
