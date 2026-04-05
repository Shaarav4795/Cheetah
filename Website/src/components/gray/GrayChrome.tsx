import Image from "next/image";
import Link from "next/link";

type NavLink = "login" | "request-demo";

interface GraySiteHeaderProps {
  activeLink?: NavLink;
}

const footerColumns = [
  {
    title: "Company",
    links: [
      "About us",
      "Diversity & Inclusion",
      "Blog",
      "Careers",
      "Financial statements",
    ],
  },
  {
    title: "Resources",
    links: ["Community", "Terms of service", "Collaboration features"],
  },
  {
    title: "Legals",
    links: ["Refund policy", "Terms & Conditions", "Privacy policy", "Brand Kit"],
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
              <a href="https://github.com/Shaarav4795/Cheetah" className="gray-button-primary text-sm">
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

            <p className="mt-5 text-sm text-zinc-400">© Cruip.com. All rights reserved.</p>

            <ul className="mt-5 flex items-center gap-2">
              <li>
                <a
                  className="inline-flex h-9 w-9 items-center justify-center rounded-full border border-zinc-700 text-zinc-400 transition-colors hover:text-zinc-100"
                  href="#0"
                  aria-label="Twitter"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor">
                    <path d="m7.063 3 3.495 4.475L14.601 3h2.454l-5.359 5.931L18 17h-4.938l-3.866-4.893L4.771 17H2.316l5.735-6.342L2 3h5.063Zm-.74 1.347H4.866l8.875 11.232h1.36L6.323 4.347Z" />
                  </svg>
                </a>
              </li>
              <li>
                <a
                  className="inline-flex h-9 w-9 items-center justify-center rounded-full border border-zinc-700 text-zinc-400 transition-colors hover:text-zinc-100"
                  href="#0"
                  aria-label="Medium"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor">
                    <path d="M17 2H3a1 1 0 0 0-1 1v14a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1Zm-1.708 3.791-.858.823a.251.251 0 0 0-.1.241V12.9a.251.251 0 0 0 .1.241l.838.823v.181h-4.215v-.181l.868-.843c.085-.085.085-.11.085-.241V7.993L9.6 14.124h-.329l-2.81-6.13V12.1a.567.567 0 0 0 .156.472l1.129 1.37v.181h-3.2v-.181l1.129-1.37a.547.547 0 0 0 .146-.472V7.351A.416.416 0 0 0 5.683 7l-1-1.209V5.61H7.8l2.4 5.283 2.122-5.283h2.971l-.001.181Z" />
                  </svg>
                </a>
              </li>
              <li>
                <a
                  className="inline-flex h-9 w-9 items-center justify-center rounded-full border border-zinc-700 text-zinc-400 transition-colors hover:text-zinc-100"
                  href="#0"
                  aria-label="Telegram"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor">
                    <path d="M17.968 3.276a.338.338 0 0 0-.232-.253 1.192 1.192 0 0 0-.63.045S3.087 8.106 2.286 8.664c-.172.121-.23.19-.259.272-.138.4.293.573.293.573l3.613 1.177a.388.388 0 0 0 .183-.011c.822-.519 8.27-5.222 8.7-5.38.068-.02.118 0 .1.049-.172.6-6.606 6.319-6.64 6.354a.138.138 0 0 0-.05.118l-.337 3.528s-.142 1.1.956 0a30.66 30.66 0 0 1 1.9-1.738c1.242.858 2.58 1.806 3.156 2.3a1 1 0 0 0 .732.283.825.825 0 0 0 .7-.622S17.894 5.292 17.98 3.909c.008-.135.021-.217.021-.317a1.177 1.177 0 0 0-.032-.316Z" />
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
                  <li key={link}>
                    <a className="transition-colors hover:text-zinc-100" href="#0">
                      {link}
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
