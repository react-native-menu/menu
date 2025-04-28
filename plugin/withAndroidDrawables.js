const { withDangerousMod } = require('@expo/config-plugins');
const fs = require('fs');
const path = require('path');

/**
 * This config plugin copies files from the specified paths, like the assets
 * directory, to the Android drawable directory.
 */
function withAndroidDrawables(config, { drawableFiles }) {
  return withDangerousMod(config, [
    'android',
    (config) => {
      // Validate drawableFiles
      if (!Array.isArray(drawableFiles)) {
        throw new Error('drawableFiles must be an array of file paths');
      }

      // Define the target drawable directory
      const drawableDir = path.join(
        config.modRequest.projectRoot,
        'android/app/src/main/res/drawable',
      );

      // Create the drawable directory if it doesn't exist
      if (!fs.existsSync(drawableDir)) {
        fs.mkdirSync(drawableDir, { recursive: true });
      }

      // Copy each drawable file to the drawable directory
      drawableFiles.forEach((filePath) => {
        const sourcePath = path.resolve(config.modRequest.projectRoot, filePath);
        const fileName = path.basename(filePath);
        const destPath = path.join(drawableDir, fileName);

        if (!fs.existsSync(sourcePath)) {
          console.warn(`Warning: Drawable file not found: ${sourcePath}`);
          return;
        }

        // Copy the file
        fs.copyFileSync(sourcePath, destPath);
      });

      return config;
    },
  ]);
}

module.exports = withAndroidDrawables;
