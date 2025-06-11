#!/usr/bin/env node

const { decompressFromEncodedURIComponent } = require("lz-string");
const { fromUnixTime, differenceInYears } = require("date-fns");
const { formatInTimeZone } = require("date-fns-tz");

// Get query string from command line argument
const queryString = process.argv[2];
if (!queryString) {
  console.error("❌ No query string provided");
  process.exit(1);
}

// Function to detect and format timestamps
function formatTimestamp(key, value) {
  // Known timestamp keys or detect numeric values that look like timestamps
  const isKnownTimestampKey = ["endTs", "startTs", "timestamp", "ts"].includes(
    key
  );

  const isNumeric = Number(value) !== NaN;
  if (!isNumeric) return value;

  const numValue = Number(value);
  let date;

  // Determine if it's seconds (10 digits) or milliseconds (13 digits)
  if (value.length === 10) {
    date = fromUnixTime(numValue); // Convert seconds to Date
  } else if (value.length === 13) {
    date = new Date(numValue); // Already milliseconds
  } else if (isKnownTimestampKey) {
    // If it's a known timestamp key but unusual length, try to handle it
    if (value.length < 10) {
      date = fromUnixTime(numValue); // Assume seconds
    } else {
      date = new Date(numValue); // Assume milliseconds
    }
  } else {
    return value; // Not a timestamp
  }

  try {
    // Check if the date is reasonable (within 50 years of now)
    const now = new Date();
    const yearsDiff = Math.abs(differenceInYears(date, now));

    if (yearsDiff > 30) {
      return value; // Probably not a timestamp
    }

    // Get system timezone, fallback to Central
    let timeZone;
    try {
      timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    } catch {
      timeZone = "America/Chicago"; // Central timezone fallback
    }

    const formattedDate = formatInTimeZone(
      date,
      timeZone,
      "MMM d, yyyy h:mm:ss a zzz"
    );

    return `${value} (📆 ${formattedDate})`;
  } catch (e) {
    console.error(`❌📅 Error parsing timestamp: ${e}`);
    return value;
  }
}

// Parse query string manually to handle duplicate keys
function parseQueryString(queryStr) {
  const params = {};
  const duplicateKeys = new Set();
  const duplicateValues = {};
  const pairs = queryStr.split("&");

  for (const pair of pairs) {
    const [key, value = ""] = pair.split("=");
    const decodedKey = decodeURIComponent(key);
    const decodedValue = decodeURIComponent(value);

    if (params[decodedKey]) {
      duplicateKeys.add(decodedKey);
      if (!duplicateValues[decodedKey]) {
        duplicateValues[decodedKey] = [params[decodedKey]];
      }
      duplicateValues[decodedKey].push(decodedValue);

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
    // Handle timestamps and keep other parameters as-is
    if (Array.isArray(value)) {
      results[key] = value.map((v) => formatTimestamp(key, v));
    } else {
      results[key] = formatTimestamp(key, value);
    }
  }
}

console.log(JSON.stringify(results, null, 2));

// Show warning if duplicates were detected
if (duplicateKeys.size > 0) {
  console.error(`\n⚠️  DUPLICATE KEYS DETECTED:`);
  for (const key of duplicateKeys) {
    console.error(`\n${key} duplicates:`);
    duplicateValues[key].forEach((value) => {
      console.error(`  "${value}",`);
    });
  }
}
