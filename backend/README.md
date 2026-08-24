# Hawah Backend API — حوة

خادم الواجهة الخلفية وقاعدة البيانات لتطبيق **حوة** الإسلامي مبني باستخدام **Node.js**, **Express.js**, **Sequelize ORM**, و **PostgreSQL**.

---

## 1. المتطلبات الأساسية (Prerequisites)

- **Node.js** الإصدار 18 أو أحدث
- **PostgreSQL** الإصدار 14 أو أحدث

---

## 2. الإعداد والتشغيل (Setup & Installation)

### أ. تثبيت الاعتماديات
```bash
cd backend
npm install
```

### ب. إعداد ملف البيئة (.env)
قم بإنشاء ملف `.env` في مجلد `backend` بنسخ محتويات `.env.example`:

```bash
cp .env.example .env
```

قم بتعديل المتغيرات حسب إعدادات قاعدة البيانات الخاصة بك:
```ini
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=hawah_db
DB_USER=postgres
DB_PASSWORD=your_password

JWT_SECRET=super_secret_jwt_key_for_hawah_app
ADMIN_EMAIL=admin@hawah.app
ADMIN_PASSWORD=admin_strong_password_123
```

### ج. تشغيل الترحيلات والبيانات الأولية (Migrations & Seeders)
```bash
# إنشاء الجداول في قاعدة البيانات
npm run migrate

# إضافة المستخدم المدير والتصنيفات الافتراضية
npm run seed
```

### د. تشغيل الخادم
```bash
# وضع التطوير مع إعادة التشغيل التلقائي
npm run dev

# وضع الإنتاج
npm start
```

---

## 3. توثيق نقاط النهاية (API Reference)

### المصادقة (Auth)
- `POST /api/auth/register` — إنشاء حساب مستخدم جديد
- `POST /api/auth/login` — تسجيل الدخول والحصول على JWT
- `POST /api/auth/refresh` — تجديد رمز الوصول
- `GET /api/auth/profile` — جلب بيانات الحساب الحالي (يتطلب توكن)

### الأدعية (Duas)
- `GET /api/duas` — جلب الأدعية المنشورة (دعم التصفح والبحث والتصنيف)
- `GET /api/duas/:id` — جلب دعاء محدد
- `GET /api/duas/sync` — المزامنة التزايدية للأدعية
- `POST /api/duas/admin` — إضافة دعاء (مدير فقط)
- `PUT /api/duas/admin/:id` — تعديل دعاء (مدير فقط)
- `DELETE /api/duas/admin/:id` — حذف دعاء (مدير فقط)
- `PATCH /api/duas/admin/:id/publish` — تبديل حالة النشر (مدير فقط)

### البودكاست (Podcasts)
- `GET /api/podcasts` — جلب حلقات البودكاست المنشورة
- `GET /api/podcasts/admin/all` — جلب جميع الحلقات (مدير فقط)
- `POST /api/podcasts/admin` — إضافة حلقة بودكاست (مدير فقط)
- `PUT /api/podcasts/admin/:id` — تعديل حلقة (مدير فقط)
- `DELETE /api/podcasts/admin/:id` — حذف حلقة (مدير فقط)
- `PATCH /api/podcasts/admin/:id/publish` — تبديل حالة النشر (مدير فقط)

### الفيديوهات (Videos)
- `GET /api/videos` — جلب الفيديوهات والدروس المنشورة
- `POST /api/videos/admin` — إضافة فيديو (مدير فقط)
- `PUT /api/videos/admin/:id` — تعديل فيديو (مدير فقط)
- `DELETE /api/videos/admin/:id` — حذف فيديو (مدير فقط)
- `PATCH /api/videos/admin/:id/publish` — تبديل حالة النشر (مدير فقط)

### مكتبة الكتب (PDFs)
- `GET /api/pdfs` — جلب قائمة الكتب المنشورة
- `POST /api/pdfs/admin` — إضافة كتاب جديد (مدير فقط)
- `PUT /api/pdfs/admin/:id` — تعديل بيانات كتاب (مدير فقط)
- `DELETE /api/pdfs/admin/:id` — حذف كتاب (مدير فقط)
- `PATCH /api/pdfs/admin/:id/publish` — تبديل حالة النشر (مدير فقط)

### التصنيفات (Categories)
- `GET /api/categories` — جلب التصنيفات النشطة
- `GET /api/categories/admin/all` — جلب جميع التصنيفات (مدير فقط)
- `POST /api/categories/admin` — إضافة تصنيف جديد (مدير فقط)
- `PUT /api/categories/admin/:id` — تعديل تصنيف (مدير فقط)
- `DELETE /api/categories/admin/:id` — حذف تصنيف (مدير فقط)

### المزامنة الشاملة (Sync)
- `GET /api/sync/all?updated_since=ISO_DATE` — جلب كافة التحديثات لجميع أنواع المحتوى بعد تاريخ محدد بطلب واحد سريع.
