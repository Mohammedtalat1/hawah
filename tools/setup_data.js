/**
 * حوة — Data Preparation Tool
 *
 * Downloads required assets for the Flutter application:
 * 1. Quran text (from risan/quran-json — Tanzil.net source)
 * 2. Quran chapter metadata
 * 3. Hadith collections (from AhmedBaset/hadith-json — Sunnah.com source)
 * 4. Arabic fonts (Amiri + Cairo from Google Fonts)
 *
 * Usage:
 *   node tools/setup_data.js
 *
 * This script must be run before building the Flutter application.
 * It downloads verified religious datasets — it does NOT generate content.
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

const MOBILE_ASSETS = path.join(__dirname, '..', 'mobile', 'assets');
const DATA_DIR = path.join(MOBILE_ASSETS, 'data');
const FONTS_DIR = path.join(MOBILE_ASSETS, 'fonts');

const DOWNLOADS = [
  // Quran data — Source: Tanzil.net via risan/quran-json
  {
    name: 'Quran Text (Tanzil.net)',
    url: 'https://raw.githubusercontent.com/risan/quran-json/main/data/quran.json',
    dest: path.join(DATA_DIR, 'quran.json'),
  },
  {
    name: 'Quran Chapters Metadata',
    url: 'https://raw.githubusercontent.com/risan/quran-json/main/data/chapters/en.json',
    dest: path.join(DATA_DIR, 'chapters.json'),
  },
  // Hadith data — Source: Sunnah.com via AhmedBaset/hadith-json
  // Arabic hadith text is public domain Islamic scholarship (1200+ years old)
  {
    name: 'Sahih al-Bukhari',
    url: 'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/bukhari.json',
    dest: path.join(DATA_DIR, 'bukhari.json'),
  },
  {
    name: 'Sahih Muslim',
    url: 'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/muslim.json',
    dest: path.join(DATA_DIR, 'muslim.json'),
  },
  // Fonts — Google Fonts (Apache 2.0 / OFL licenses)
  {
    name: 'Amiri Regular',
    url: 'https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Regular.ttf',
    dest: path.join(FONTS_DIR, 'Amiri-Regular.ttf'),
  },
  {
    name: 'Amiri Bold',
    url: 'https://github.com/google/fonts/raw/main/ofl/amiri/Amiri-Bold.ttf',
    dest: path.join(FONTS_DIR, 'Amiri-Bold.ttf'),
  },
  {
    name: 'Cairo Regular',
    url: 'https://github.com/google/fonts/raw/main/ofl/cairo/Cairo%5Bslnt%2Cwght%5D.ttf',
    dest: path.join(FONTS_DIR, 'Cairo-Variable.ttf'),
  },
];

function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

function downloadFile(url, dest, redirectCount = 0) {
  if (redirectCount > 10) {
    return Promise.reject(new Error(`Too many redirects for ${url}`));
  }

  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const protocol = parsedUrl.protocol === 'http:' ? http : https;
    const options = {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) HawahApp/1.0',
        'Accept': '*/*',
      },
    };

    const request = protocol.get(url, options, (response) => {
      // Handle redirects
      if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
        response.resume(); // Consume response data to free up memory
        const nextUrl = new URL(response.headers.location, url).toString();
        return downloadFile(nextUrl, dest, redirectCount + 1).then(resolve).catch(reject);
      }

      if (response.statusCode !== 200) {
        response.resume();
        reject(new Error(`HTTP ${response.statusCode} for ${url}`));
        return;
      }

      const file = fs.createWriteStream(dest);
      response.pipe(file);

      file.on('finish', () => {
        file.close(() => resolve());
      });

      file.on('error', (err) => {
        file.close();
        if (fs.existsSync(dest)) fs.unlinkSync(dest);
        reject(err);
      });
    });

    request.on('error', (err) => {
      if (fs.existsSync(dest)) {
        try { fs.unlinkSync(dest); } catch (_) {}
      }
      reject(err);
    });

    request.setTimeout(120000, () => {
      request.destroy();
      reject(new Error(`Timeout downloading ${url}`));
    });
  });
}

async function main() {
  console.log('╔═══════════════════════════════════════════╗');
  console.log('║     حوة — Data Preparation Tool          ║');
  console.log('╚═══════════════════════════════════════════╝');
  console.log();

  const IMAGES_DIR = path.join(MOBILE_ASSETS, 'images');
  ensureDir(DATA_DIR);
  ensureDir(FONTS_DIR);
  ensureDir(IMAGES_DIR);

  // Copy Hawah.jpg as app_icon.jpg if present
  const iconSrc = path.join(__dirname, '..', 'Hawah.jpg');
  const iconDest = path.join(IMAGES_DIR, 'app_icon.jpg');
  if (fs.existsSync(iconSrc) && !fs.existsSync(iconDest)) {
    fs.copyFileSync(iconSrc, iconDest);
    console.log('✓ Copied Hawah.jpg to assets/images/app_icon.jpg');
  }

  let success = 0;
  let failed = 0;

  for (const item of DOWNLOADS) {
    if (fs.existsSync(item.dest)) {
      const stats = fs.statSync(item.dest);
      if (stats.size > 100) {
        console.log(`✓ ${item.name} (already exists, ${(stats.size / 1024 / 1024).toFixed(2)} MB)`);
        success++;
        continue;
      }
    }

    process.stdout.write(`⏳ Downloading ${item.name}...`);
    try {
      await downloadFile(item.url, item.dest);
      const stats = fs.statSync(item.dest);
      console.log(` ✓ (${(stats.size / 1024 / 1024).toFixed(2)} MB)`);
      success++;
    } catch (error) {
      console.log(` ✗ Error: ${error.message}`);
      failed++;
    }
  }

  console.log();
  console.log(`═══════════════════════════════════════════`);
  console.log(`Results: ${success} succeeded, ${failed} failed`);

  if (failed > 0) {
    console.log();
    console.log('Some downloads failed. You can re-run this script to retry.');
    console.log('Or manually download the files and place them in:');
    console.log(`  Data: ${DATA_DIR}`);
    console.log(`  Fonts: ${FONTS_DIR}`);
    process.exit(1);
  }

  console.log();
  console.log('✓ All assets downloaded successfully!');
  console.log();
  console.log('Data Sources:');
  console.log('  Quran: Tanzil.net (verbatim copy with attribution)');
  console.log('  Hadith: Sunnah.com (public domain Arabic text)');
  console.log('  Fonts: Google Fonts (OFL / Apache 2.0)');
  console.log();
  console.log('You can now build the Flutter application.');
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
