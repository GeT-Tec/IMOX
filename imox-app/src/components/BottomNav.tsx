"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Map, LayoutGrid, BarChart3, User } from "lucide-react";

export default function BottomNav() {
  const pathname = usePathname();

  const tabs = [
    { name: "Mapa", href: "/", icon: Map },
    { name: "Imóveis", href: "/imoveis", icon: LayoutGrid },
    { name: "Estatísticas", href: "/estatisticas", icon: BarChart3 },
    { name: "Perfil", href: "/perfil", icon: User },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-[#0F151E]/95 backdrop-blur-md border-t border-white/[0.08]">
      <div className="w-full max-w-7xl mx-auto h-16 grid grid-cols-4 px-2 sm:px-6 lg:px-8">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive =
            tab.href === "/"
              ? pathname === "/"
              : pathname.startsWith(tab.href);

          return (
            <Link
              key={tab.name}
              href={tab.href}
              className={`flex flex-col items-center justify-center gap-1 transition-colors ${
                isActive ? "text-[#2DD4A8]" : "text-[#94A3B8] hover:text-white"
              }`}
            >
              <Icon className="w-5 h-5" strokeWidth={isActive ? 2.2 : 1.8} />
              <span className="text-[11px] font-medium tracking-tight">
                {tab.name}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
