export default defineNuxtRouteMiddleware(async (to) => {
  const user = useSupabaseUser()
  const supabase = useSupabaseClient()

  // A rota raiz '/' (Vitrine Pública Marketplace) é 100% livre (pública)
  if (to.path === '/') {
    return
  }

  const isAuthPage = to.path === '/login' || to.path === '/cadastro'

  // Se não houver sessão ativa em rotas protegidas (/dashboard, /admin/*), redireciona para /login
  if (!user.value) {
    if (!isAuthPage) {
      return navigateTo('/login')
    }
    return
  }

  // Usuário está autenticado: consulta o role real na tabela public.user_profiles
  const { data: userProfile } = await supabase
    .from('user_profiles')
    .select('role')
    .eq('id', user.value.id)
    .maybeSingle<{ role: string }>()

  const isAdmin = userProfile?.role === 'admin'

  // Se tentar acessar /login ou /cadastro já logado, redireciona conforme o perfil real do banco
  if (isAuthPage) {
    return navigateTo(isAdmin ? '/admin/dashboard' : '/dashboard')
  }

  // Trava de Segurança RBAC (Route Guard): bloqueia qualquer acesso a /admin/* se não for 'admin'
  if (to.path.startsWith('/admin') && !isAdmin) {
    return navigateTo('/dashboard')
  }
})
