#!/usr/bin/env node

function getLZString() {
  // Try default require first
  try {
    return require("lz-string");
  } catch (e) {
    const fs = require("fs");
    const searchPaths = [];

    // First priority: Try all NVM node versions (most likely location)
    const nvmNodeDir = `${process.env.HOME}/.nvm/versions/node`;
    try {
      const nodeVersions = fs.readdirSync(nvmNodeDir);
      for (const version of nodeVersions) {
        searchPaths.push(`${nvmNodeDir}/${version}/lib/node_modules/lz-string`);
      }
    } catch (nvmError) {
      // NVM directory doesn't exist or can't be read, skip
    }

    // Second priority: Common global paths (fallback)
    searchPaths.push(
      "/usr/local/lib/node_modules/lz-string", // Homebrew Intel
      "/opt/homebrew/lib/node_modules/lz-string", // Homebrew Apple Silicon
      "/usr/lib/node_modules/lz-string" // System
    );

    // Try each path in priority order
    for (const globalPath of searchPaths) {
      try {
        return require(globalPath);
      } catch (pathError) {
        // Continue trying other paths
      }
    }

    // If we get here, nothing was found
    console.error("❌ lz-string package not found!");
    console.error("");
    console.error("Searched paths:");
    searchPaths.forEach((path) => console.error(`  - ${path}`));
    console.error("");
    console.error("Node.js module search paths:");
    module.paths.forEach((path) => console.error(`  - ${path}`));
    console.error("");
    console.error("Please install lz-string globally:");
    console.error("  npm install -g lz-string");
    console.error("");
    console.error("Or create a local node_modules in the script directory:");
    console.error("  cd raycast/script-commands");
    console.error("  npm init -y");
    console.error("  npm install lz-string");
    process.exit(1);
  }
}

// Load lz-string
const LZString = getLZString();

// Get query string from command line argument
const queryString = process.argv[2];
if (!queryString) {
  console.error("❌ No query string provided");
  process.exit(1);
}

// Parse query string using URLSearchParams (modern approach)
const params = new URLSearchParams(queryString);
const paramsObj = Object.fromEntries(params.entries());
const results = {};

// Process each parameter
for (const [key, value] of Object.entries(paramsObj)) {
  if (key === "filters") {
    // Only decompress the filters parameter
    try {
      const decompressed = LZString.decompressFromEncodedURIComponent(value);
      if (decompressed) {
        try {
          results[key] = JSON.parse(decompressed);
        } catch {
          results[key] = decompressed;
        }
      } else {
        results[key] = value;
      }
    } catch {
      results[key] = value;
    }
  } else {
    // Keep other parameters as-is
    results[key] = value;
  }
}

console.log(JSON.stringify(results, null, 2));
