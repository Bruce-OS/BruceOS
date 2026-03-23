import { defineConfig } from "vitepress";

export default defineConfig({
  title: "BruceOS",
  description:
    "A custom Linux distribution built on Fedora 43+ for kids, VFX artists, and gamers.",
  lang: "en-US",
  cleanUrls: true,
  appearance: "dark",

  head: [
    ["link", { rel: "icon", href: "/logo.svg", type: "image/svg+xml" }],
    [
      "link",
      {
        rel: "preconnect",
        href: "https://fonts.googleapis.com",
      },
    ],
    [
      "link",
      {
        rel: "preconnect",
        href: "https://fonts.gstatic.com",
        crossorigin: "",
      },
    ],
    [
      "link",
      {
        rel: "stylesheet",
        href: "https://fonts.googleapis.com/css2?family=Red+Hat+Display:wght@400;500;600;700;800;900&family=Red+Hat+Text:wght@300;400;500;600;700&display=swap",
      },
    ],
    ["meta", { property: "og:type", content: "website" }],
    ["meta", { property: "og:title", content: "BruceOS" }],
    [
      "meta",
      {
        property: "og:description",
        content:
          "A custom Linux distribution built on Fedora 43+ for kids, VFX artists, and gamers.",
      },
    ],
    ["meta", { property: "og:url", content: "https://bruceos.com" }],
    ["meta", { property: "og:image", content: "https://bruceos.com/og.png" }],
    ["meta", { name: "twitter:card", content: "summary_large_image" }],
    ["meta", { name: "twitter:title", content: "BruceOS" }],
    [
      "meta",
      {
        name: "twitter:description",
        content:
          "A custom Linux distribution built on Fedora 43+ for kids, VFX artists, and gamers.",
      },
    ],
  ],

  themeConfig: {
    logo: "/logo.svg",
    siteTitle: "BruceOS",

    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/getting-started" },
      { text: "Reference", link: "/reference/kickstart-config" },
    ],

    sidebar: {
      "/guide/": [
        {
          text: "Guide",
          items: [
            { text: "Getting Started", link: "/guide/getting-started" },
            { text: "Installation", link: "/guide/installation" },
            {
              text: "Building from Source",
              link: "/guide/building-from-source",
            },
            { text: "First Boot", link: "/guide/first-boot" },
          ],
        },
      ],
      "/reference/": [
        {
          text: "Reference",
          items: [
            {
              text: "Kickstart Config",
              link: "/reference/kickstart-config",
            },
            { text: "Package List", link: "/reference/package-list" },
            { text: "Terminal Stack", link: "/reference/terminal-stack" },
            { text: "AI Stack", link: "/reference/ai-stack" },
          ],
        },
      ],
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/Bruce-OS/BruceOS" },
    ],

    search: {
      provider: "local",
    },

    footer: {
      message: "Released under the GPL-2.0 License.",
      copyright: "Copyright &copy; 2024-present BruceOS Inc.",
    },
  },
});
