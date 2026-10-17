import { MapPin } from "lucide-react";

export default function MapaPage() {
  return (
    <div className="flex-1 flex flex-col p-4 sm:p-6 lg:p-8 w-full">
      {/* Esqueleto da barra de busca do mapa */}
      <div className="mb-4 w-full">
        <div className="w-full bg-[#131A24] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-[#94A3B8]">
          Buscar bairro, rua ou condomínio...
        </div>
      </div>

      {/* Placeholder da área do mapa em largura total */}
      <div className="w-full flex-1 min-h-[550px] lg:min-h-[650px] bg-[#131A24] border border-white/[0.08] rounded-xl flex flex-col items-center justify-center p-8 text-center">
        <div className="w-14 h-14 rounded-full bg-[#2DD4A8]/10 text-[#2DD4A8] flex items-center justify-center mb-4">
          <MapPin className="w-7 h-7" />
        </div>
        <h2 className="text-lg font-bold text-white mb-2">Aba Mapa (Fase 4)</h2>
        <p className="text-sm text-[#94A3B8] max-w-md">
          Container cartográfico Leaflet / OpenStreetMap em largura total com pins interativos de São Paulo será montado na Fase 4.
        </p>
      </div>
    </div>
  );
}
