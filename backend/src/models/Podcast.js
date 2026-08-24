const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Podcast = sequelize.define('Podcast', {
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
    thumbnail_url: {
      type: DataTypes.STRING(1000),
      allowNull: true,
    },
    podcast_url: {
      type: DataTypes.STRING(1000),
      allowNull: false,
    },
    publisher: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    duration: {
      type: DataTypes.STRING(50),
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
    tableName: 'podcasts',
    indexes: [
      { fields: ['category_id'] },
      { fields: ['is_published'] },
      { fields: ['published_at'] },
      { fields: ['created_at'] },
      { fields: ['updated_at'] },
    ],
  });

  return Podcast;
};
