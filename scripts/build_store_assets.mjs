import { access, copyFile, mkdir, readdir } from "node:fs/promises";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";

const repositoryRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
);
const sharpModulePath = process.argv[2];

if (!sharpModulePath) {
  throw new Error("Pass the absolute path of the installed sharp module.");
}

const require = createRequire(import.meta.url);
const sharp = require(sharpModulePath);

const rawDirectory = path.join(
  repositoryRoot,
  "docs",
  "store-assets",
  "screenshots",
  "raw",
);
const finalDirectory = path.join(
  repositoryRoot,
  "docs",
  "store-assets",
  "screenshots",
  "final",
);
const iconDirectory = path.join(
  repositoryRoot,
  "docs",
  "store-assets",
  "icon",
);
const sourceIcon = path.join(
  repositoryRoot,
  "mobile",
  "ios",
  "Runner",
  "Assets.xcassets",
  "AppIcon.appiconset",
  "Icon-App-1024x1024@1x.png",
);

await Promise.all([
  access(rawDirectory),
  access(sourceIcon),
  mkdir(finalDirectory, { recursive: true }),
  mkdir(iconDirectory, { recursive: true }),
]);

const screenshotNames = (await readdir(rawDirectory))
  .filter((name) => /^\d{2}-.+\.png$/i.test(name))
  .sort();

for (const sourceName of screenshotNames) {
  const outputName = sourceName.replace(/\.png$/i, "-1290x2796.png");
  await sharp(path.join(rawDirectory, sourceName))
    .resize(1290, 2796, { fit: "fill", kernel: "lanczos3" })
    .png({ compressionLevel: 9, palette: false })
    .toFile(path.join(finalDirectory, outputName));
}

const storeIcon = path.join(iconDirectory, "phoenix-store-icon-1024.png");
await copyFile(sourceIcon, storeIcon);

const featureBackground = Buffer.from(`
  <svg width="1024" height="500" viewBox="0 0 1024 500"
       xmlns="http://www.w3.org/2000/svg">
    <defs>
      <radialGradient id="glow" cx="26%" cy="42%" r="74%">
        <stop offset="0" stop-color="#22362f"/>
        <stop offset="0.58" stop-color="#111b17"/>
        <stop offset="1" stop-color="#090d0f"/>
      </radialGradient>
      <linearGradient id="line" x1="0" y1="0" x2="1" y2="0">
        <stop offset="0" stop-color="#ff6b4a"/>
        <stop offset="1" stop-color="#ffb34d"/>
      </linearGradient>
    </defs>
    <rect width="1024" height="500" fill="url(#glow)"/>
    <circle cx="230" cy="250" r="170" fill="#ffffff" opacity="0.035"/>
    <rect x="464" y="144" width="92" height="8" rx="4" fill="url(#line)"/>
    <text x="464" y="216" fill="#f3f6f5" font-family="Arial, sans-serif"
          font-size="54" font-weight="800" letter-spacing="2">PHOENIX</text>
    <text x="464" y="271" fill="#a9bcb4" font-family="Arial, sans-serif"
          font-size="28" font-weight="600">FITNESS FOR REAL LIFE</text>
    <text x="464" y="337" fill="#d7dfdc" font-family="Arial, sans-serif"
          font-size="24">Small steps. Real progress.</text>
    <text x="464" y="383" fill="#87a394" font-family="Arial, sans-serif"
          font-size="20">Private · Local-first · No account</text>
  </svg>
`);

const resizedIcon = await sharp(sourceIcon)
  .resize(310, 310)
  .png()
  .toBuffer();

await sharp(featureBackground)
  .composite([{ input: resizedIcon, left: 75, top: 95 }])
  .flatten({ background: "#090d0f" })
  .removeAlpha()
  .png({ compressionLevel: 9 })
  .toFile(path.join(iconDirectory, "phoenix-feature-graphic-1024x500.png"));

console.log(
  JSON.stringify(
    {
      screenshots: screenshotNames.length,
      screenshotSize: "1290x2796",
      storeIcon,
      featureGraphic: path.join(
        iconDirectory,
        "phoenix-feature-graphic-1024x500.png",
      ),
    },
    null,
    2,
  ),
);
