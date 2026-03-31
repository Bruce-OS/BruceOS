<script setup>
import DefaultTheme from 'vitepress/theme'
import { useData } from 'vitepress'

const { Layout } = DefaultTheme
const { frontmatter } = useData()
</script>

<template>
  <Layout>
    <template #home-features-before>
      <div v-if="frontmatter.layout === 'home'" class="screenshot-wrapper">
        <img src="/screenshot.png" alt="BruceOS Desktop" class="screenshot" />
      </div>
    </template>
  </Layout>
</template>

<style scoped>
.screenshot-wrapper {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 1.5rem 2rem;
}
.screenshot {
  width: 100%;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.4);
}
</style>
