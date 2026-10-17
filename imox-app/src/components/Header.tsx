import Link from "next/link";

export default function Header() {
  return (
    <header className="sticky top-0 z-50 h-14 w-full bg-[#131A24]/90 backdrop-blur-md border-b border-white/[0.08] px-4 sm:px-6 lg:px-8 flex items-center justify-between">
      {/* Esquerda: Logo IMOX */}
      <Link href="/" className="flex items-center gap-2">
        <span className="w-2 h-2 rounded-full bg-[#2DD4A8] shadow-[0_0_8px_#2DD4A8]" />
        <span className="text-lg font-extrabold tracking-tight text-white">IMOX</span>
      </Link>

      {/* Direita: ponto verde + sigla "VP" + badge "PROTÓTIPO" */}
      <div className="flex items-center gap-2.5">
        <span className="w-2 h-2 rounded-full bg-[#2DD4A8] animate-pulse" />
        <span className="text-xs font-semibold text-[#E6EDF3]">VP</span>
        <span className="text-[10px] font-bold tracking-wider px-2.5 py-0.5 rounded-full bg-[#2DD4A8]/10 text-[#2DD4A8] border border-[#2DD4A8]/30 uppercase">
          PROTÓTIPO
        </span>
      </div>
    </header>
  );
}
