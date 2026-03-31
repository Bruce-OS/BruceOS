import DefaultTheme from "vitepress/theme";
import type { Theme } from "vitepress";
import "./custom.css";
import HomeScreenshot from "./HomeScreenshot.vue";

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component("HomeScreenshot", HomeScreenshot);
  },
} satisfies Theme;
