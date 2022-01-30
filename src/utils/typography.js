import Typography from "typography";
import Wordpress2016 from "typography-theme-wordpress-2016";

Wordpress2016.overrideThemeStyles = () => ({
  body: {
    color: "rgb(51 65 85)",
  },
  "a.gatsby-resp-image-link": {
    boxShadow: "none",
  },
  // Code highlighting blocks and fragments
  code: {
    fontFamily:
      'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace',
    fontSize: "0.9rem",
  },
  // Code formatting of inline fragments
  "code:not(.grvsc-code)": {
    background: "rgb(239 246 255)",
    borderRadius: "3px",
    fontSize: "0.9rem",
    letterSpacing: "-0.5px",
    padding: "4.5px 6px",
  },
  "h2,h3": {
    lineHeight: "1.5",
  },
});

delete Wordpress2016.googleFonts;

const typography = new Typography(Wordpress2016);

// Hot reload typography in development.
if (process.env.NODE_ENV !== "production") {
  typography.injectStyles();
}

export default typography;
export const rhythm = typography.rhythm;
export const scale = typography.scale;
