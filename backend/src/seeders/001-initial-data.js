'use strict';
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');

module.exports = {
  async up(queryInterface) {
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123456';
    const hashedPassword = await bcrypt.hash(adminPassword, 12);

    // Create admin user
    await queryInterface.bulkInsert('users', [{
      id: uuidv4(),
      email: process.env.ADMIN_EMAIL || 'admin@hawah.app',
      password_hash: hashedPassword,
      name: 'مدير النظام',
      role: 'admin',
      is_active: true,
      created_at: new Date(),
      updated_at: new Date(),
    }]);

    // Create default categories
    const duaCatId1 = uuidv4();
    const duaCatId2 = uuidv4();
    const duaCatId3 = uuidv4();
    const duaCatId4 = uuidv4();
    const duaCatId5 = uuidv4();
    const duaCatId6 = uuidv4();
    const podcastCatId1 = uuidv4();
    const podcastCatId2 = uuidv4();
    const videoCatId1 = uuidv4();
    const videoCatId2 = uuidv4();
    const pdfCatId1 = uuidv4();
    const pdfCatId2 = uuidv4();

    await queryInterface.bulkInsert('categories', [
      // Dua categories
      { id: duaCatId1, name: 'Morning Adhkar', name_ar: 'أذكار الصباح', type: 'dua', sort_order: 1, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: duaCatId2, name: 'Evening Adhkar', name_ar: 'أذكار المساء', type: 'dua', sort_order: 2, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: duaCatId3, name: 'Quranic Duas', name_ar: 'أدعية القرآن', type: 'dua', sort_order: 3, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: duaCatId4, name: 'Prophets Duas', name_ar: 'أدعية الأنبياء', type: 'dua', sort_order: 4, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: duaCatId5, name: 'Travel Duas', name_ar: 'أدعية السفر', type: 'dua', sort_order: 5, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: duaCatId6, name: 'General Duas', name_ar: 'أدعية عامة', type: 'dua', sort_order: 6, is_active: true, created_at: new Date(), updated_at: new Date() },
      // Podcast categories
      { id: podcastCatId1, name: 'Quran Recitation', name_ar: 'تلاوة القرآن', type: 'podcast', sort_order: 1, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: podcastCatId2, name: 'Islamic Lectures', name_ar: 'محاضرات إسلامية', type: 'podcast', sort_order: 2, is_active: true, created_at: new Date(), updated_at: new Date() },
      // Video categories
      { id: videoCatId1, name: 'Islamic Lessons', name_ar: 'دروس إسلامية', type: 'video', sort_order: 1, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: videoCatId2, name: 'Quran Tafsir', name_ar: 'تفسير القرآن', type: 'video', sort_order: 2, is_active: true, created_at: new Date(), updated_at: new Date() },
      // PDF categories
      { id: pdfCatId1, name: 'Islamic Books', name_ar: 'كتب إسلامية', type: 'pdf', sort_order: 1, is_active: true, created_at: new Date(), updated_at: new Date() },
      { id: pdfCatId2, name: 'Fiqh', name_ar: 'فقه', type: 'pdf', sort_order: 2, is_active: true, created_at: new Date(), updated_at: new Date() },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('categories', null, {});
    await queryInterface.bulkDelete('users', null, {});
  },
};
