import { User, FileText, Home, BarChart2, Bell } from "lucide-react";

export default function PerfilPage() {
  return (
    <div className="flex-1 flex flex-col p-4 sm:p-6 lg:p-8 w-full max-w-5xl mx-auto">
      {/* Hero do corretor */}
      <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-6 flex items-center gap-5 mb-6">
        <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-full border-2 border-[#2DD4A8] bg-[#1C2534] flex items-center justify-center text-[#2DD4A8] shrink-0">
          <User className="w-8 h-8 sm:w-10 sm:h-10" />
        </div>
        <div>
          <h2 className="text-lg sm:text-xl font-bold text-white">Carolina Mendes</h2>
          <div className="text-sm text-[#2DD4A8] font-semibold mt-0.5">
            CRECI 189.420-F • Consultora Senior
          </div>
          <div className="text-xs text-[#94A3B8] mt-1">IMOX Prime São Paulo</div>
        </div>
      </div>

      {/* Grid de Métricas: 1 col mobile, 3 col tablet/desktop */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-5 text-center">
          <div className="text-2xl font-bold text-white">15</div>
          <div className="text-xs uppercase text-[#94A3B8] mt-1">Imóveis Ativos</div>
        </div>
        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-5 text-center">
          <div className="text-2xl font-bold text-white">28</div>
          <div className="text-xs uppercase text-[#94A3B8] mt-1">Fechados 2024</div>
        </div>
        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-5 text-center">
          <div className="text-2xl font-bold text-white">R$ 64M</div>
          <div className="text-xs uppercase text-[#94A3B8] mt-1">Volume VGV</div>
        </div>
      </div>

      {/* Grid de Ações / Ferramentas: 1 col mobile, 2 col tablet/desktop */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <FileText className="w-5 h-5 text-[#94A3B8]" />
            <span className="text-sm font-medium text-white">Exportar Relatório PDF</span>
          </div>
          <span className="text-[#94A3B8]">→</span>
        </div>

        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Home className="w-5 h-5 text-[#94A3B8]" />
            <span className="text-sm font-medium text-white">Gerenciar Meus 15 Imóveis</span>
          </div>
          <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-[#2DD4A8]/10 text-[#2DD4A8]">15</span>
        </div>

        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <BarChart2 className="w-5 h-5 text-[#94A3B8]" />
            <span className="text-sm font-medium text-white">Inteligência de Mercado (CMA)</span>
          </div>
          <span className="text-[#94A3B8]">→</span>
        </div>

        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Bell className="w-5 h-5 text-[#94A3B8]" />
            <span className="text-sm font-medium text-white">Alertas de Redução de Preço</span>
          </div>
          <span className="text-xs text-[#2DD4A8]">6 ativos</span>
        </div>
      </div>
    </div>
  );
}
