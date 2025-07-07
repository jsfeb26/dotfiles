module.exports = {
  defaultBrowser: "dia",
  handlers: [
    {
      // All GitHub links
      match: /^https:\/\/github\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // Local development server
      match: /^http:\/\/localhost:3000\/.*$/,
      browser: "Google Chrome",
    },
    {
      // All Ambient app environments as well as django admin
      match: /^https?:\/\/.*ambient\.ai.*$/,
      browser: "Google Chrome",
    },
    {
      // PagerDuty links
      match: /^https:\/\/ambientai\.pagerduty\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // All Figma links
      match: /^https:\/\/www\.figma\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // All Ambient Atlassian links (Jira, Confluence, etc.)
      match: /^https:\/\/ambient-ai\.atlassian\.net\/.*$/,
      browser: "Google Chrome",
    },
    {
      // All MUI links
      match: /^https:\/\/mui\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // All Loom links
      match: /^https:\/\/www\.loom\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // Ambient Sentry Links
      match: /^https:\/\/ambientai\.sentry\.io\/.*$/,
      browser: "Google Chrome",
    },
    {
      // All AWS Console links
      match: /^https:\/\/.*\.console\.aws\.amazon\.com\/.*$/,
      browser: "Google Chrome",
    },
    {
      // Google Docs
      match: /^https:\/\/docs\.google\.com\/.*$/,
      browser: "Google Chrome",
    },
  ],
};
