import { BarChart3 } from "lucide-react";

export default function EstatisticasPage() {
  return (
    <div className="flex-1 flex flex-col p-4 sm:p-6 lg:p-8 w-full">
      {/* Esqueleto do seletor */}
      <div className="mb-6 w-full max-w-md">
        <div className="text-[11px] font-semibold text-[#94A3B8] uppercase mb-1.5">
          SELECIONE O BAIRRO DE SÃO PAULO
        </div>
        <div className="w-full bg-[#131A24] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white font-medium">
          Jardins (Jardim Paulista / Europa)
        </div>
      </div>

      {/* Grid responsivo de cards: 1 col mobile, 2 col tablet, 4 col desktop */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6 w-full mb-6">
        {["Preço Médio", "Preço / m² Médio", "Estoque Ativo", "Taxa de Absorção"].map((kpi, idx) => (
          <div
            key={idx}
            className="bg-[#131A24] border border-white/[0.08] rounded-xl p-5 flex flex-col gap-1"
          >
            <span className="text-xs uppercase text-[#94A3B8] font-medium">{kpi}</span>
            <span className="text-xl font-bold text-white">—</span>
            <span className="text-xs text-[#2DD4A8] font-medium mt-1">Carregando métricas...</span>
          </div>
        ))}
      </div>

      {/* Gráficos em grid responsivo: 1 col mobile, 2 col desktop */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6 w-full">
        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-6 min-h-[320px] flex flex-col items-center justify-center text-center">
          <BarChart3 className="w-8 h-8 text-[#2DD4A8] mb-3" />
          <h3 className="text-base font-bold text-white mb-1">Evolução do Preço Médio / m²</h3>
          <p className="text-xs text-[#94A3B8]">Gráfico de colunas Recharts (Fase 6)</p>
        </div>

        <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-6 min-h-[320px] flex flex-col items-center justify-center text-center">
          <div className="w-10 h-10 rounded-full border-4 border-[#2DD4A8] border-t-[#38BDF8] mb-3" />
          <h3 className="text-base font-bold text-white mb-1">Distribuição de Tipologia</h3>
          <p className="text-xs text-[#94A3B8]">Gráfico Donut Recharts (Fase 6)</p>
        </div>
      </div>
    </div>
  );
}
