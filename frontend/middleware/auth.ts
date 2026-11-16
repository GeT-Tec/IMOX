export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()

  // A rota de callback OAuth '/confirm' é livre para permitir a troca do código PKCE pela sessão no cliente
  if (to.path === '/confirm') {
    return
  }

  // Se o provedor OAuth redirecionar com ?code= (PKCE) ou ?error= para qualquer outra rota (ex: /dashboard ou /),
  // encaminha para /confirm preservando os parâmetros para concluir a troca de sessão sem perder o código
  if (to.query.code || to.query.error || to.query.error_description) {
    return navigateTo({ path: '/confirm', query: to.query }, { replace: true })
  }

  // A rota raiz '/' (Vitrine Pública Marketplace) é 100% livre (pública)
  if (to.path === '/') {
    return
  }

  const isAuthPage = to.path === '/login' || to.path === '/cadastro'
  const isAdminRoute = to.path === '/admin' || to.path.startsWith('/admin/')
  const userId = user.value?.id || (user.value as { sub?: string } | null)?.sub

  // Se não houver sessão/UID válido em rotas protegidas (/dashboard, /admin/*), redireciona para /login
  if (!user.value || !userId) {
    if (!isAuthPage) {
      return navigateTo('/login', { replace: true })
    }
    return
  }

  // Usuário autenticado: consulta a role autoritativa na tabela public.user_profiles (fail-closed)
  const { data: userProfile, error } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', userId)
    .maybeSingle<{ role: string }>()

  const isAdmin = !error && userProfile?.role === 'admin'

  // Se tentar acessar /login ou /cadastro já logado, redireciona conforme o perfil real do banco
  if (isAuthPage) {
    return navigateTo(isAdmin ? '/admin/dashboard' : '/dashboard', { replace: true })
  }

  // Trava de Segurança RBAC (Route Guard): bloqueia qualquer acesso a /admin ou /admin/* se não for 'admin'
  if (isAdminRoute) {
    if (!isAdmin) {
      return navigateTo('/dashboard', { replace: true })
    }
    if (to.path === '/admin') {
      return navigateTo('/admin/dashboard', { replace: true })
    }
  }
})
