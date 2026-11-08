<script setup lang="ts">
definePageMeta({
  middleware: ['auth']
})

const user = useSupabaseUser()

if (user.value) {
  await navigateTo('/dashboard')
} else {
  await navigateTo('/login')
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center bg-[#07161F] text-slate-300">
    <p class="text-sm tracking-wide">Redirecionando para ImobiLit...</p>
  </div>
</template>
