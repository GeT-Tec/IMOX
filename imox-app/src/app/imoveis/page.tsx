import { Building2 } from "lucide-react";

export default function ImoveisPage() {
  return (
    <div className="flex-1 flex flex-col p-4 sm:p-6 lg:p-8 w-full">
      {/* Esqueleto da barra de busca de imóveis */}
      <div className="mb-6 w-full">
        <div className="w-full bg-[#131A24] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-[#94A3B8]">
          Filtrar imóveis listados...
        </div>
      </div>

      {/* Grid responsivo: 1 col mobile, 2 col tablet, 3 col desktop */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6 w-full">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <div
            key={i}
            className="bg-[#131A24] border border-white/[0.08] rounded-xl p-6 flex flex-col items-center justify-center text-center min-h-[260px]"
          >
            <div className="w-12 h-12 rounded-full bg-[#2DD4A8]/10 text-[#2DD4A8] flex items-center justify-center mb-3">
              <Building2 className="w-6 h-6" />
            </div>
            <h3 className="text-base font-bold text-white mb-1">
              Card de Imóvel {i}
            </h3>
            <p className="text-xs text-[#94A3B8]">
              Grid fluido: 1 col (&lt;640px), 2 col (640-1024px), 3 col (&gt;1024px).
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
