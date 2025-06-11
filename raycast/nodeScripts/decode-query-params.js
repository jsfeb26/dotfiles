#!/usr/bin/env node

const { decompressFromEncodedURIComponent } = require("lz-string");

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
      const decompressed = decompressFromEncodedURIComponent(value);
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
