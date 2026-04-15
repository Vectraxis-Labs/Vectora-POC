"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

// Each item in the sidebar: a label and the URL it links to
const navItems = [
    { label: "Home", href: "/home" },
    { label: "Researches", href: "/researches" },
    { label: "Collections", href: "/collections" },
    { label: "Peers", href: "/peers" },
    { label: "Teams", href: "/teams" },
    { label: "Calendar", href: "/calendar" },
];

export default function Sidebar() {
    // usePathname() tells us which URL we're currently on
    // e.g. if we're on /peers, pathname = "/peers"
    const pathname = usePathname();

    return (
        <aside className="w-56 h-screen bg-white border-r border-gray-200 flex flex-col py-6 px-4 fixed left-0 top-0">
            {/* Logo / App name at the top */}
            <div className="mb-8">
                <span className="text-xl font-semibold text-gray-900">Vectora</span>
            </div>

            {/* Navigation links */}
            <nav className="flex flex-col gap-1">
                {navItems.map((item) => {
                    // Is this the page we're currently on?
                    const isActive = pathname.startsWith(item.href);

                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${isActive
                                ? "bg-gray-100 text-gray-900"   // highlighted if active
                                : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                                }`}
                        >
                            {item.label}
                        </Link>
                    );
                })}
            </nav>
        </aside>
    );
}