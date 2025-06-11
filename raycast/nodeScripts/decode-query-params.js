#!/usr/bin/env node

const { decompressFromEncodedURIComponent } = require("lz-string");

// Get query string from command line argument
const queryString = process.argv[2];
if (!queryString) {
  console.error("❌ No query string provided");
  process.exit(1);
}

// Parse query string manually to handle duplicate keys
// since the keys can be duplicate we can't just purely use URLSearchParams
function parseQueryString(queryStr) {
  const params = {};
  const duplicateKeys = new Set();
  const duplicateValues = {}; // Track all values for duplicate keys
  const pairs = queryStr.split("&");

  for (const pair of pairs) {
    const [key, value = ""] = pair.split("=");
    const decodedKey = decodeURIComponent(key);
    const decodedValue = decodeURIComponent(value);

    if (params[decodedKey]) {
      // Mark as duplicate
      duplicateKeys.add(decodedKey);

      // Track duplicate values
      if (!duplicateValues[decodedKey]) {
        duplicateValues[decodedKey] = [params[decodedKey]]; // Add the first value
      }
      duplicateValues[decodedKey].push(decodedValue);

      // If key already exists, convert to array or add to existing array
      if (Array.isArray(params[decodedKey])) {
        params[decodedKey].push(decodedValue);
      } else {
        params[decodedKey] = [params[decodedKey], decodedValue];
      }
    } else {
      params[decodedKey] = decodedValue;
    }
  }

  return { params, duplicateKeys, duplicateValues };
}

const {
  params: paramsObj,
  duplicateKeys,
  duplicateValues,
} = parseQueryString(queryString);
const results = {};

// Process each parameter
for (const [key, value] of Object.entries(paramsObj)) {
  if (key === "filters") {
    // Only decompress the filters parameter (handle arrays if needed)
    if (Array.isArray(value)) {
      results[key] = value.map((v) => {
        try {
          const decompressed = decompressFromEncodedURIComponent(v);
          if (decompressed) {
            try {
              return JSON.parse(decompressed);
            } catch {
              return decompressed;
            }
          } else {
            return v;
          }
        } catch {
          return v;
        }
      });
    } else {
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
    }
  } else {
    // Keep other parameters as-is (including arrays for duplicates)
    results[key] = value;
  }
}

console.log(JSON.stringify(results, null, 2));

// Show warning if duplicates were detected with their values
if (duplicateKeys.size > 0) {
  console.error(`\n⚠️  DUPLICATE KEYS DETECTED:`);
  for (const key of duplicateKeys) {
    console.error(`\n${key} duplicates:`);
    duplicateValues[key].forEach((value) => {
      console.error(`  "${value}",`);
    });
  }
}
