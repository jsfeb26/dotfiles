module.exports = {
  defaultBrowser: "dia",
  handlers: [
    {
      match: /^https:\/\/github\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^http:\/\/localhost:3000\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https?:\/\/.*ambient\.ai.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/ambientai\.pagerduty\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/www\.figma\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/ambient-ai\.atlassian\.net\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/mui\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/www\.loom\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/ambientai\.sentry\.io\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/.*\.console\.aws\.amazon\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/.*\.awsapps\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/docs\.google\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      match: /^https:\/\/auth\.openai\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // Linear
      match: /^https:\/\/linear\.app\/.*$/,
      browser: "Google Chrome",
    },
    {
      // CoderPad
      match: /^https:\/\/app\.coderpad\.io\/.*$/,
      browser: "Google Chrome",
    },
    {
      // Ashby
      match: /^https:\/\/app\.ashbyhq\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // Statsig
      match: /^https:\/\/console\.statsig\.com\/.*$/,
      browser: "Google Chrome",
    },
  ],
};
