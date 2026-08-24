const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Pdf = sequelize.define('Pdf', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    title: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    cover_url: {
      type: DataTypes.STRING(1000),
      allowNull: true,
    },
    pdf_url: {
      type: DataTypes.STRING(1000),
      allowNull: false,
    },
    author: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    file_size: {
      type: DataTypes.STRING(50),
      allowNull: true,
    },
    page_count: {
      type: DataTypes.INTEGER,
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
    is_downloadable: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    published_at: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    created_by: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'users', key: 'id' },
    },
  }, {
    tableName: 'pdfs',
    indexes: [
      { fields: ['category_id'] },
      { fields: ['is_published'] },
      { fields: ['published_at'] },
      { fields: ['created_at'] },
      { fields: ['updated_at'] },
    ],
  });

  return Pdf;
};
