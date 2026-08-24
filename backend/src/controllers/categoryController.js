const { Op } = require('sequelize');
const { Category } = require('../models');

exports.list = async (req, res, next) => {
  try {
    const { type } = req.query;
    const where = { is_active: true };
    if (type) {
      where.type = type;
    }

    const categories = await Category.findAll({
      where,
      order: [['sort_order', 'ASC'], ['name_ar', 'ASC']],
    });

    res.json({ data: categories });
  } catch (error) {
    next(error);
  }
};

exports.getById = async (req, res, next) => {
  try {
    const category = await Category.findByPk(req.params.id);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }
    res.json({ data: category });
  } catch (error) {
    next(error);
  }
};

// ─── Admin Operations ────────────────────────────────

exports.adminList = async (req, res, next) => {
  try {
    const { type } = req.query;
    const where = {};
    if (type) where.type = type;

    const categories = await Category.findAll({
      where,
      order: [['type', 'ASC'], ['sort_order', 'ASC'], ['name_ar', 'ASC']],
    });

    res.json({ data: categories });
  } catch (error) {
    next(error);
  }
};

exports.create = async (req, res, next) => {
  try {
    const category = await Category.create(req.body);
    res.status(201).json({ data: category });
  } catch (error) {
    next(error);
  }
};

exports.update = async (req, res, next) => {
  try {
    const category = await Category.findByPk(req.params.id);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    await category.update(req.body);
    res.json({ data: category });
  } catch (error) {
    next(error);
  }
};

exports.remove = async (req, res, next) => {
  try {
    const category = await Category.findByPk(req.params.id);
    if (!category) {
      return res.status(404).json({ error: 'Category not found' });
    }

    await category.destroy();
    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    next(error);
  }
};

exports.syncCategories = async (req, res, next) => {
  try {
    const { updated_since } = req.query;
    const where = { is_active: true };

    if (updated_since) {
      where.updated_at = { [Op.gt]: new Date(updated_since) };
    }

    const categories = await Category.findAll({
      where,
      order: [['updated_at', 'ASC']],
    });

    res.json({
      data: categories,
      sync_timestamp: new Date().toISOString(),
    });
  } catch (error) {
    next(error);
  }
};
