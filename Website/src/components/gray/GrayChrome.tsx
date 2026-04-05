import Image from "next/image";
import Link from "next/link";

type NavLink = "login" | "request-demo";

interface GraySiteHeaderProps {
  activeLink?: NavLink;
}

const footerColumns = [
  {
    title: "Links",
    links: [
      { label: "GitHub", href: "https://github.com/Shaarav4795/Cheetah" },
    ],
  },
] as const;

export function GraySiteHeader({ activeLink }: GraySiteHeaderProps) {
  const navBaseClass =
    "inline-flex items-center rounded-full px-3 py-2 text-sm font-medium transition-colors";

  const linkClass = (link: NavLink) => {
    if (activeLink === link) {
      return `${navBaseClass} text-zinc-950`;
    }

    return `${navBaseClass} text-zinc-500 hover:text-zinc-950`;
  };

  return (
    <header className="fixed inset-x-0 top-0 z-50 px-4 pt-5 sm:px-6 lg:px-8">
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between rounded-2xl gray-border-light bg-white/90 px-4 py-3 backdrop-blur-lg sm:px-5">
        <Link
          href="/"
          className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-zinc-200 bg-white transition-colors hover:bg-zinc-50"
          aria-label="Gray home"
        >
          <Image src="/gray/images/logo.png" width={24} height={24} alt="Gray logo" />
        </Link>

        <nav aria-label="Primary">
          <ul className="flex items-center gap-2 sm:gap-3">
            <li>
              <a href="#features" className="inline-flex items-center rounded-full px-3 py-2 text-sm font-medium transition-colors text-zinc-500 hover:text-zinc-950">
                Learn More
              </a>
            </li>
            <li>
              <a href="https://github.com/Shaarav4795/Cheetah/releases/download/v1.0.0/Cheetah.1.0.dmg.zip" className="gray-button-primary text-sm">
                Download
              </a>
            </li>
          </ul>
        </nav>
      </div>
    </header>
  );
}

export function GraySiteFooter() {
  return (
    <footer className="bg-zinc-900 pb-16 pt-20 text-zinc-300">
      <div className="mx-auto w-full max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="grid gap-12 border-t border-zinc-800 pt-12 md:grid-cols-[1.4fr_1fr_1fr_1fr]">
          <div>
            <Link
              href="/"
              className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-zinc-700 bg-zinc-800"
              aria-label="Gray home"
            >
              <Image src="/gray/images/logo.png" width={24} height={24} alt="Gray logo" />
            </Link>

            <p className="mt-5 text-sm text-zinc-400">© Cheetah. All rights reserved.</p>
            <p className="mt-2 text-sm text-zinc-400">Made with love by Shaarav4795</p>

            <ul className="mt-5 flex items-center gap-2">
              <li>
                <a
                  className="inline-flex h-9 w-9 items-center justify-center rounded-full border border-zinc-700 text-zinc-400 transition-colors hover:text-zinc-100"
                  href="https://github.com/Shaarav4795/Cheetah"
                  aria-label="GitHub"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                  </svg>
                </a>
              </li>
            </ul>
          </div>

          {footerColumns.map((column) => (
            <div key={column.title}>
              <h2 className="text-sm font-semibold tracking-wide text-zinc-100">{column.title}</h2>
              <ul className="mt-4 space-y-3 text-sm text-zinc-400">
                {column.links.map((link) => (
                  <li key={link.label}>
                    <a className="transition-colors hover:text-zinc-100" href={link.href}>
                      {link.label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </footer>
  );
}
