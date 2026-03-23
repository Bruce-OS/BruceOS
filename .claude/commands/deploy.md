Build and deploy the BruceOS docs site to Cloudflare Pages.

Run these commands in sequence:

1. Build the docs:
```
npm run docs:build
```

2. Deploy to Cloudflare Pages:
```
wrangler pages deploy docs/.vitepress/dist --project-name bruceos --branch main
```

Report the deployment URL when complete.
