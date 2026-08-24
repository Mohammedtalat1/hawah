const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Dua = sequelize.define('Dua', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    arabic_text: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    translation: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    transliteration: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    source: {
      type: DataTypes.STRING(500),
      allowNull: true,
    },
    category_id: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'categories', key: 'id' },
    },
    is_published: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    sort_order: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    created_by: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'users', key: 'id' },
    },
  }, {
    tableName: 'duas',
    indexes: [
      { fields: ['category_id'] },
      { fields: ['is_published'] },
      { fields: ['created_at'] },
      { fields: ['updated_at'] },
    ],
  });

  return Dua;
};
