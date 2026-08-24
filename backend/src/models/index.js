const { Sequelize } = require('sequelize');
const config = require('../config/database');

const env = process.env.NODE_ENV || 'development';
const dbConfig = config[env];

const sequelize = new Sequelize(
  dbConfig.database,
  dbConfig.username,
  dbConfig.password,
  {
    host: dbConfig.host,
    port: dbConfig.port,
    dialect: dbConfig.dialect,
    logging: dbConfig.logging,
    define: dbConfig.define,
    pool: dbConfig.pool,
  }
);

// Import models
const User = require('./User')(sequelize);
const Category = require('./Category')(sequelize);
const Dua = require('./Dua')(sequelize);
const Podcast = require('./Podcast')(sequelize);
const Video = require('./Video')(sequelize);
const Pdf = require('./Pdf')(sequelize);

// Associations
Category.hasMany(Dua, { foreignKey: 'category_id', as: 'duas' });
Dua.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

Category.hasMany(Podcast, { foreignKey: 'category_id', as: 'podcasts' });
Podcast.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

Category.hasMany(Video, { foreignKey: 'category_id', as: 'videos' });
Video.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

Category.hasMany(Pdf, { foreignKey: 'category_id', as: 'pdfs' });
Pdf.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

User.hasMany(Dua, { foreignKey: 'created_by', as: 'createdDuas' });
User.hasMany(Podcast, { foreignKey: 'created_by', as: 'createdPodcasts' });
User.hasMany(Video, { foreignKey: 'created_by', as: 'createdVideos' });
User.hasMany(Pdf, { foreignKey: 'created_by', as: 'createdPdfs' });

module.exports = {
  sequelize,
  Sequelize,
  User,
  Category,
  Dua,
  Podcast,
  Video,
  Pdf,
};
