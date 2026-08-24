const fs = require('fs');
const path = require('path');

const src = path.join(__dirname, '..', 'Hawah.jpg');
const destDir = path.join(__dirname, '..', 'mobile', 'assets', 'images');
const dest = path.join(destDir, 'app_icon.jpg');

if (!fs.existsSync(destDir)) {
  fs.mkdirSync(destDir, { recursive: true });
}

if (fs.existsSync(src)) {
  fs.copyFileSync(src, dest);
  console.log('Icon copied successfully to assets/images/app_icon.jpg');
} else {
  console.log('Source Hawah.jpg not found');
}
