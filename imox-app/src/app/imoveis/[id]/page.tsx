import Link from "next/link";
import { ArrowLeft, Building2 } from "lucide-react";

interface PropertyDetailPageProps {
  params: {
    id: string;
  };
}

export default function PropertyDetailPage({ params }: PropertyDetailPageProps) {
  const { id } = params;

  return (
    <div className="flex-1 flex flex-col p-4 sm:p-6 lg:p-8 w-full max-w-4xl mx-auto">
      {/* Botão de retorno para lista de imóveis */}
      <div className="mb-4">
        <Link
          href="/imoveis"
          className="inline-flex items-center gap-2 text-xs font-semibold text-[#94A3B8] hover:text-[#2DD4A8] transition-colors"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Voltar para Imóveis</span>
        </Link>
      </div>

      {/* Placeholder da página de detalhe analítico */}
      <div className="bg-[#131A24] border border-white/[0.08] rounded-xl p-8 flex flex-col items-center justify-center text-center min-h-[460px]">
        <div className="w-14 h-14 rounded-full bg-[#2DD4A8]/10 text-[#2DD4A8] flex items-center justify-center mb-4">
          <Building2 className="w-7 h-7" />
        </div>
        <span className="text-xs font-mono text-[#2DD4A8] bg-[#2DD4A8]/10 px-2.5 py-1 rounded-full mb-2">
          ID: {id}
        </span>
        <h2 className="text-xl font-bold text-white mb-2">Detalhes Analíticos do Imóvel</h2>
        <p className="text-sm text-[#94A3B8] max-w-md">
          Visão aprofundada com histórico completo de 24 meses, eventos de alteração de preço, custos de condomínio e IPTU (Fase 5).
        </p>
      </div>
    </div>
  );
}
