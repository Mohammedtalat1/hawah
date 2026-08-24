'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    // Users
    await queryInterface.createTable('users', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      email: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true,
      },
      password_hash: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      role: {
        type: Sequelize.ENUM('user', 'admin'),
        defaultValue: 'user',
        allowNull: false,
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      last_login: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    // Categories
    await queryInterface.createTable('categories', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      name_ar: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      type: {
        type: Sequelize.ENUM('dua', 'podcast', 'video', 'pdf'),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      sort_order: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    await queryInterface.addIndex('categories', ['type']);
    await queryInterface.addIndex('categories', ['is_active']);

    // Duas
    await queryInterface.createTable('duas', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      arabic_text: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      translation: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      transliteration: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      source: {
        type: Sequelize.STRING(500),
        allowNull: true,
      },
      category_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'categories', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      is_published: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      sort_order: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      created_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'users', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    await queryInterface.addIndex('duas', ['category_id']);
    await queryInterface.addIndex('duas', ['is_published']);
    await queryInterface.addIndex('duas', ['updated_at']);

    // Podcasts
    await queryInterface.createTable('podcasts', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      thumbnail_url: {
        type: Sequelize.STRING(1000),
        allowNull: true,
      },
      podcast_url: {
        type: Sequelize.STRING(1000),
        allowNull: false,
      },
      publisher: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      duration: {
        type: Sequelize.STRING(50),
        allowNull: true,
      },
      category_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'categories', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      is_published: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      published_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      created_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'users', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    await queryInterface.addIndex('podcasts', ['category_id']);
    await queryInterface.addIndex('podcasts', ['is_published']);
    await queryInterface.addIndex('podcasts', ['updated_at']);

    // Videos
    await queryInterface.createTable('videos', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      thumbnail_url: {
        type: Sequelize.STRING(1000),
        allowNull: true,
      },
      video_url: {
        type: Sequelize.STRING(1000),
        allowNull: false,
      },
      publisher: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      category_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'categories', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      is_published: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      published_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      created_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'users', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    await queryInterface.addIndex('videos', ['category_id']);
    await queryInterface.addIndex('videos', ['is_published']);
    await queryInterface.addIndex('videos', ['updated_at']);

    // PDFs
    await queryInterface.createTable('pdfs', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      title: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      cover_url: {
        type: Sequelize.STRING(1000),
        allowNull: true,
      },
      pdf_url: {
        type: Sequelize.STRING(1000),
        allowNull: false,
      },
      author: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      file_size: {
        type: Sequelize.STRING(50),
        allowNull: true,
      },
      page_count: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      category_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'categories', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      is_published: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      is_downloadable: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      published_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      created_by: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'users', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    await queryInterface.addIndex('pdfs', ['category_id']);
    await queryInterface.addIndex('pdfs', ['is_published']);
    await queryInterface.addIndex('pdfs', ['updated_at']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('pdfs');
    await queryInterface.dropTable('videos');
    await queryInterface.dropTable('podcasts');
    await queryInterface.dropTable('duas');
    await queryInterface.dropTable('categories');
    await queryInterface.dropTable('users');
  },
};
