const { Op } = require('sequelize');
const { Category } = require('../models');

/**
 * Creates a standard CRUD controller for a content model.
 * Reduces duplication across Duas, Podcasts, Videos, PDFs controllers.
 *
 * @param {Object} Model - Sequelize model
 * @param {Object} options - Configuration
 * @param {string[]} options.searchFields - Fields to search in
 * @param {string} options.urlField - The URL field name (e.g., 'podcast_url')
 */
function createContentController(Model, options = {}) {
  const {
    searchFields = ['title'],
    urlField = null,
  } = options;

  return {
    /**
     * GET /api/{resource} — List published items (public)
     */
    list: async (req, res, next) => {
      try {
        const page = parseInt(req.query.page) || 1;
        const limit = Math.min(parseInt(req.query.limit) || 20, 100);
        const offset = (page - 1) * limit;
        const { search, category_id } = req.query;

        const where = { is_published: true };

        if (search) {
          where[Op.or] = searchFields.map(field => ({
            [field]: { [Op.iLike]: `%${search}%` },
          }));
        }

        if (category_id) {
          where.category_id = category_id;
        }

        const { count, rows } = await Model.findAndCountAll({
          where,
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
          order: [['created_at', 'DESC']],
          limit,
          offset,
        });

        res.json({
          data: rows,
          pagination: {
            total: count,
            page,
            limit,
            totalPages: Math.ceil(count / limit),
          },
        });
      } catch (error) {
        next(error);
      }
    },

    /**
     * GET /api/{resource}/:id — Get single item (public, must be published)
     */
    getById: async (req, res, next) => {
      try {
        const item = await Model.findOne({
          where: { id: req.params.id, is_published: true },
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
        });

        if (!item) {
          return res.status(404).json({ error: 'Not found' });
        }

        res.json({ data: item });
      } catch (error) {
        next(error);
      }
    },

    /**
     * GET /api/{resource}/sync — Incremental sync (public)
     */
    sync: async (req, res, next) => {
      try {
        const { updated_since } = req.query;
        const page = parseInt(req.query.page) || 1;
        const limit = Math.min(parseInt(req.query.limit) || 50, 200);
        const offset = (page - 1) * limit;

        const where = { is_published: true };

        if (updated_since) {
          where.updated_at = { [Op.gt]: new Date(updated_since) };
        }

        const { count, rows } = await Model.findAndCountAll({
          where,
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
          order: [['updated_at', 'ASC']],
          limit,
          offset,
        });

        res.json({
          data: rows,
          pagination: {
            total: count,
            page,
            limit,
            totalPages: Math.ceil(count / limit),
          },
          sync_timestamp: new Date().toISOString(),
        });
      } catch (error) {
        next(error);
      }
    },

    // ─── Admin Operations ────────────────────────────────────────

    /**
     * GET /api/admin/{resource} — List all items (admin)
     */
    adminList: async (req, res, next) => {
      try {
        const page = parseInt(req.query.page) || 1;
        const limit = Math.min(parseInt(req.query.limit) || 20, 100);
        const offset = (page - 1) * limit;
        const { search, category_id, is_published } = req.query;

        const where = {};

        if (search) {
          where[Op.or] = searchFields.map(field => ({
            [field]: { [Op.iLike]: `%${search}%` },
          }));
        }

        if (category_id) {
          where.category_id = category_id;
        }

        if (is_published !== undefined) {
          where.is_published = is_published === 'true';
        }

        const { count, rows } = await Model.findAndCountAll({
          where,
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
          order: [['created_at', 'DESC']],
          limit,
          offset,
        });

        res.json({
          data: rows,
          pagination: {
            total: count,
            page,
            limit,
            totalPages: Math.ceil(count / limit),
          },
        });
      } catch (error) {
        next(error);
      }
    },

    /**
     * GET /api/admin/{resource}/:id — Get single item (admin, any status)
     */
    adminGetById: async (req, res, next) => {
      try {
        const item = await Model.findByPk(req.params.id, {
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
        });

        if (!item) {
          return res.status(404).json({ error: 'Not found' });
        }

        res.json({ data: item });
      } catch (error) {
        next(error);
      }
    },

    /**
     * POST /api/admin/{resource} — Create item (admin)
     */
    create: async (req, res, next) => {
      try {
        const data = { ...req.body, created_by: req.user.id };

        if (data.is_published && !data.published_at) {
          data.published_at = new Date();
        }

        const item = await Model.create(data);

        const result = await Model.findByPk(item.id, {
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
        });

        res.status(201).json({ data: result });
      } catch (error) {
        next(error);
      }
    },

    /**
     * PUT /api/admin/{resource}/:id — Update item (admin)
     */
    update: async (req, res, next) => {
      try {
        const item = await Model.findByPk(req.params.id);
        if (!item) {
          return res.status(404).json({ error: 'Not found' });
        }

        const data = { ...req.body };

        // Set published_at when first published
        if (data.is_published && !item.is_published && !data.published_at) {
          data.published_at = new Date();
        }

        await item.update(data);

        const result = await Model.findByPk(item.id, {
          include: [{ model: Category, as: 'category', attributes: ['id', 'name', 'name_ar'] }],
        });

        res.json({ data: result });
      } catch (error) {
        next(error);
      }
    },

    /**
     * DELETE /api/admin/{resource}/:id — Delete item (admin)
     */
    remove: async (req, res, next) => {
      try {
        const item = await Model.findByPk(req.params.id);
        if (!item) {
          return res.status(404).json({ error: 'Not found' });
        }

        await item.destroy();

        res.json({ message: 'Deleted successfully' });
      } catch (error) {
        next(error);
      }
    },

    /**
     * PATCH /api/admin/{resource}/:id/publish — Toggle publish (admin)
     */
    togglePublish: async (req, res, next) => {
      try {
        const item = await Model.findByPk(req.params.id);
        if (!item) {
          return res.status(404).json({ error: 'Not found' });
        }

        const is_published = !item.is_published;
        const updates = { is_published };

        if (is_published && !item.published_at) {
          updates.published_at = new Date();
        }

        await item.update(updates);

        res.json({ data: item });
      } catch (error) {
        next(error);
      }
    },
  };
}

module.exports = createContentController;
