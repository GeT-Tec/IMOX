export default defineNuxtRouteMiddleware((to) => {
  const user = useSupabaseUser()

  const isAuthPage = to.path === '/login' || to.path === '/cadastro'

  // Se o usuário já estiver autenticado e tentar acessar /login ou /cadastro, redireciona para /dashboard
  if (user.value && isAuthPage) {
    return navigateTo('/dashboard')
  }

  // Se não houver sessão ativa e a rota não for pública de autenticação, redireciona para /login
  if (!user.value && !isAuthPage) {
    return navigateTo('/login')
  }
})
