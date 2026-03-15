#!/usr/bin/env node

const { decompressFromEncodedURIComponent } = require("lz-string");
const { fromUnixTime, differenceInYears } = require("date-fns");
const { formatInTimeZone } = require("date-fns-tz");

const queryString = process.argv[2];
if (!queryString) {
  console.error("No query string provided");
  process.exit(1);
}

function formatTimestamp(key, value) {
  const isKnownTimestampKey = ["endTs", "startTs", "timestamp", "ts"].includes(
    key
  );

  const isNumeric = Number(value) !== NaN;
  if (!isNumeric) return value;

  const numValue = Number(value);
  let date;

  if (value.length === 10) {
    date = fromUnixTime(numValue);
  } else if (value.length === 13) {
    date = new Date(numValue);
  } else if (isKnownTimestampKey) {
    if (value.length < 10) {
      date = fromUnixTime(numValue);
    } else {
      date = new Date(numValue);
    }
  } else {
    return value;
  }

  try {
    const now = new Date();
    const yearsDiff = Math.abs(differenceInYears(date, now));

    if (yearsDiff > 30) {
      return value;
    }

    let timeZone;
    try {
      timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    } catch {
      timeZone = "America/Chicago";
    }

    const formattedDate = formatInTimeZone(
      date,
      timeZone,
      "MMM d, yyyy h:mm:ss a zzz"
    );

    return `${value} (date ${formattedDate})`;
  } catch (error) {
    console.error(`Error parsing timestamp: ${error}`);
    return value;
  }
}

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

for (const [key, value] of Object.entries(paramsObj)) {
  if (key === "filters") {
    if (Array.isArray(value)) {
      results[key] = value.map((item) => {
        try {
          const decompressed = decompressFromEncodedURIComponent(item);
          if (decompressed) {
            try {
              return JSON.parse(decompressed);
            } catch {
              return decompressed;
            }
          }
          return item;
        } catch {
          return item;
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
  } else if (Array.isArray(value)) {
    results[key] = value.map((item) => formatTimestamp(key, item));
  } else {
    results[key] = formatTimestamp(key, value);
  }
}

console.log(JSON.stringify(results, null, 2));

if (duplicateKeys.size > 0) {
  console.error("\nDUPLICATE KEYS DETECTED:");
  for (const key of duplicateKeys) {
    console.error(`\n${key} duplicates:`);
    duplicateValues[key].forEach((value) => {
      console.error(`  "${value}",`);
    });
  }
}
