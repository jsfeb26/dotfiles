module.exports = {
  defaultBrowser: "arc",
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
  ],
};
