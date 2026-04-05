import { GraySiteFooter, GraySiteHeader } from "@/components/gray/GrayChrome";

const demoHighlights = [
  {
    title: "Personal",
    description: "We can help you choose the right plan for your team.",
    iconPath:
      "M.72 16.053c-.5-.2-.8-.7-.7-1.2l4-14c.2-.6.7-.9 1.3-.8.5.2.8.7.7 1.3l-4 14c-.2.5-.7.8-1.3.7Zm13.3-.7-4-14c-.1-.6.2-1.1.7-1.3.5-.2 1.1.2 1.2.7l4 14c.2.5-.2 1.1-.7 1.2-.5.2-1-.1-1.2-.6Zm-7-11.3h2v2h-2v-2Zm0 4h2v2h-2v-2Zm0 4h2v2h-2v-2Z",
    iconWidth: 16,
    iconHeight: 17,
  },
  {
    title: "Metrics",
    description: "We can help you choose the right plan for your team.",
    iconPath:
      "M1 0a1 1 0 0 1 1 1v11a1 1 0 0 1-2 0V1a1 1 0 0 1 1-1Zm4 5a1 1 0 0 1 1 1v6a1 1 0 0 1-2 0V6a1 1 0 0 1 1-1Zm4-2a1 1 0 0 1 1 1v8a1 1 0 0 1-2 0V4a1 1 0 0 1 1-1Zm4 5a1 1 0 0 1 1 1v3a1 1 0 0 1-2 0V9a1 1 0 0 1 1-1Z",
    iconWidth: 14,
    iconHeight: 13,
  },
  {
    title: "Flexible",
    description: "We can help you choose the right plan for your team.",
    iconPath:
      "M.5 0h2a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1-.5-.5v-1A.5.5 0 0 1 .5 0Zm13 12h2a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5Zm-11-8h6a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-6a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5Zm3 4h8a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-8a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 1 .5-.5Z",
    iconWidth: 16,
    iconHeight: 14,
  },
] as const;

const communityCards = [
  {
    title: "Discord",
    description: "Engage in real time conversations with us!",
    cta: "Talk to us",
    iconWidth: 22,
    iconHeight: 16,
    iconPath:
      "M18.624 1.326A18.784 18.784 0 0 0 14.146.001a.07.07 0 0 0-.072.033c-.193.328-.408.756-.558 1.092a17.544 17.544 0 0 0-5.03 0A10.86 10.86 0 0 0 7.922.034.072.072 0 0 0 7.849 0C6.277.26 4.774.711 3.37 1.326a.063.063 0 0 0-.03.024C.49 5.416-.292 9.382.091 13.298c.002.02.013.038.029.05a18.598 18.598 0 0 0 5.493 2.65.073.073 0 0 0 .077-.025c.423-.551.8-1.133 1.124-1.744.02-.036 0-.079-.038-.093a12.278 12.278 0 0 1-1.716-.78.066.066 0 0 1-.007-.112c.115-.082.23-.168.34-.255a.07.07 0 0 1 .072-.009c3.6 1.569 7.498 1.569 11.056 0a.07.07 0 0 1 .072.008c.11.087.226.174.342.256a.066.066 0 0 1-.006.112c-.548.305-1.118.564-1.717.78a.066.066 0 0 0-.038.093c.33.61.708 1.192 1.123 1.743a.072.072 0 0 0 .078.025 18.538 18.538 0 0 0 5.502-2.65.067.067 0 0 0 .028-.048c.459-4.528-.768-8.461-3.252-11.948a.055.055 0 0 0-.03-.025ZM7.352 10.914c-1.084 0-1.977-.95-1.977-2.116 0-1.166.875-2.116 1.977-2.116 1.11 0 1.994.958 1.977 2.116 0 1.166-.876 2.116-1.977 2.116Zm7.31 0c-1.084 0-1.977-.95-1.977-2.116 0-1.166.876-2.116 1.977-2.116 1.11 0 1.994.958 1.977 2.116 0 1.166-.867 2.116-1.977 2.116Z",
  },
  {
    title: "GitHub",
    description: "Engage in real time conversations with us!",
    cta: "Contribute",
    iconWidth: 20,
    iconHeight: 19,
    iconPath:
      "M10.041 0C4.52 0 0 4.382 0 9.737c0 4.3 2.845 7.952 6.862 9.25.502.081.669-.243.669-.487v-1.622c-2.761.568-3.347-1.299-3.347-1.299-.419-1.136-1.088-1.46-1.088-1.46-1.004-.568 0-.568 0-.568 1.004.08 1.506.973 1.506.973.92 1.461 2.343 1.055 2.929.812.084-.65.335-1.055.67-1.298-2.26-.244-4.603-1.055-4.603-4.788 0-1.055.419-1.947 1.004-2.596 0-.325-.418-1.299.168-2.597 0 0 .836-.243 2.761.974.837-.244 1.673-.325 2.51-.325.837 0 1.674.081 2.51.325 1.925-1.298 2.762-.974 2.762-.974.586 1.38.167 2.353.084 2.597.669.649 1.004 1.541 1.004 2.596 0 3.733-2.343 4.544-4.603 4.788.335.324.67.892.67 1.785V18.5c0 .244.167.568.67.487 4.016-1.298 6.86-4.95 6.86-9.25C20.084 4.382 15.565 0 10.042 0Z",
  },
  {
    title: "Twitter / X",
    description: "Engage in real time conversations with us!",
    cta: "Follow us",
    iconWidth: 18,
    iconHeight: 16,
    iconPath:
      "M8.096 10.409 3.117 16H.355l6.452-7.248L0 0h5.695L9.63 5.115 14.176 0h2.76L10.91 6.78 18 16h-5.555l-4.349-5.591Zm5.111 3.966h1.53L4.864 1.54h-1.64l9.984 12.836Z",
  },
] as const;

export function GrayLoginPage() {
  return (
    <div className="min-h-screen bg-white text-zinc-900">
      <GraySiteHeader activeLink="login" />

      <main className="pt-28">
        <section className="px-4 pb-24 pt-12 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <header className="mx-auto max-w-3xl text-center">
              <h1 className="font-heading text-4xl font-semibold tracking-tight sm:text-5xl">
                Log in to Gray
              </h1>
            </header>

            <div className="mx-auto mt-10 max-w-xl rounded-3xl gray-border-light p-8 sm:p-10">
              <form className="space-y-5">
                <div>
                  <label htmlFor="email" className="text-sm font-semibold text-zinc-700">
                    Email
                  </label>
                  <input
                    id="email"
                    type="email"
                    required
                    placeholder="mark@acmecorp.com"
                    className="mt-2 h-11 w-full rounded-xl border border-zinc-200 px-3 text-sm text-zinc-900 placeholder:text-zinc-400 focus:border-zinc-400 focus:outline-none"
                  />
                </div>

                <div>
                  <div className="flex items-center justify-between">
                    <label htmlFor="password" className="text-sm font-semibold text-zinc-700">
                      Password
                    </label>
                    <a href="#0" className="text-sm text-zinc-500 transition-colors hover:text-zinc-900">
                      Forgot?
                    </a>
                  </div>
                  <input
                    id="password"
                    type="password"
                    required
                    className="mt-2 h-11 w-full rounded-xl border border-zinc-200 px-3 text-sm text-zinc-900 placeholder:text-zinc-400 focus:border-zinc-400 focus:outline-none"
                  />
                </div>

                <button type="submit" className="gray-button-primary w-full justify-center">
                  Log in
                </button>
              </form>

              <div className="my-7 flex items-center gap-4">
                <span className="h-px flex-1 bg-zinc-200" />
                <span className="text-sm text-zinc-500">Or</span>
                <span className="h-px flex-1 bg-zinc-200" />
              </div>

              <button
                type="button"
                className="flex h-11 w-full items-center justify-center gap-3 rounded-xl border border-zinc-200 bg-white text-sm font-medium text-zinc-700 transition-colors hover:bg-zinc-50"
              >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" className="h-4 w-4 text-zinc-700" fill="currentColor">
                  <path d="M15.679 6.545H8.043v3.273h4.328c-.692 2.182-2.401 2.91-4.363 2.91a4.727 4.727 0 1 1 3.035-8.347l2.378-2.265A8 8 0 1 0 8.008 16c4.41 0 8.4-2.909 7.67-9.455Z" />
                </svg>
                Continue With Google
              </button>

              <p className="mt-6 text-center text-sm text-zinc-500">
                By loggin in you agree with our <a href="#0" className="text-zinc-700 hover:text-zinc-900">Terms</a>
              </p>
            </div>
          </div>
        </section>
      </main>

      <GraySiteFooter />
    </div>
  );
}

export function GrayRequestDemoPage() {
  return (
    <div className="min-h-screen bg-white text-zinc-900">
      <GraySiteHeader activeLink="request-demo" />

      <main className="pt-28">
        <section className="px-4 pb-20 pt-12 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <header className="mx-auto max-w-3xl text-center">
              <h1 className="font-heading text-4xl font-semibold tracking-tight sm:text-5xl">
                Get started with Gray
              </h1>
              <p className="mt-4 text-zinc-600">
                Talk to an expert about your requirements, needs, and timeline. Complete
                the form and we will make sure to reach out.
              </p>
            </header>

            <div className="mx-auto mt-10 max-w-xl rounded-3xl gray-border-light p-8 sm:p-10">
              <form className="space-y-5">
                <div>
                  <label htmlFor="name" className="text-sm font-semibold text-zinc-700">
                    Full Name
                  </label>
                  <input
                    id="name"
                    type="text"
                    required
                    placeholder="Patrick Rossi"
                    className="mt-2 h-11 w-full rounded-xl border border-zinc-200 px-3 text-sm text-zinc-900 placeholder:text-zinc-400 focus:border-zinc-400 focus:outline-none"
                  />
                </div>

                <div>
                  <label htmlFor="work-email" className="text-sm font-semibold text-zinc-700">
                    Work Email
                  </label>
                  <input
                    id="work-email"
                    type="email"
                    required
                    placeholder="mark@acmecorp.com"
                    className="mt-2 h-11 w-full rounded-xl border border-zinc-200 px-3 text-sm text-zinc-900 placeholder:text-zinc-400 focus:border-zinc-400 focus:outline-none"
                  />
                </div>

                <div>
                  <label htmlFor="channel" className="text-sm font-semibold text-zinc-700">
                    How did you hear about us?
                  </label>
                  <select
                    id="channel"
                    className="mt-2 h-11 w-full rounded-xl border border-zinc-200 px-3 text-sm text-zinc-900 focus:border-zinc-400 focus:outline-none"
                    required
                    defaultValue="Twitter"
                  >
                    <option>Twitter</option>
                    <option>Medium</option>
                    <option>Telegram</option>
                  </select>
                </div>

                <div>
                  <label htmlFor="project" className="text-sm font-semibold text-zinc-700">
                    Project Details
                  </label>
                  <textarea
                    id="project"
                    rows={4}
                    required
                    placeholder="Share your requirements"
                    className="mt-2 w-full rounded-xl border border-zinc-200 px-3 py-2 text-sm text-zinc-900 placeholder:text-zinc-400 focus:border-zinc-400 focus:outline-none"
                  />
                </div>

                <button type="submit" className="gray-button-primary w-full justify-center">
                  Request Demo
                </button>
              </form>

              <p className="mt-6 text-center text-sm text-zinc-500">
                By submitting you agree with our <a href="#0" className="text-zinc-700 hover:text-zinc-900">Terms</a>
              </p>
            </div>
          </div>
        </section>

        <section className="px-4 pb-20 sm:px-6 lg:px-8">
          <div className="mx-auto grid w-full max-w-6xl gap-5 md:grid-cols-3">
            {demoHighlights.map((item) => (
              <article key={item.title} className="rounded-2xl gray-border-light p-6">
                <span className="inline-flex h-10 w-10 items-center justify-center rounded-full border border-zinc-200 bg-zinc-100">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width={item.iconWidth}
                    height={item.iconHeight}
                    fill="currentColor"
                    className="text-zinc-900"
                  >
                    <path d={item.iconPath} />
                  </svg>
                </span>
                <h2 className="mt-4 font-heading text-xl font-semibold text-zinc-950">{item.title}</h2>
                <p className="mt-2 text-sm text-zinc-600">{item.description}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="bg-zinc-50 px-4 py-20 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <h2 className="text-center font-heading text-3xl font-semibold tracking-tight text-zinc-950 sm:text-4xl">
              Join the Community
            </h2>

            <div className="mt-10 grid gap-5 md:grid-cols-3">
              {communityCards.map((card) => (
                <article key={card.title} className="rounded-2xl border border-zinc-200 bg-white p-6">
                  <span className="inline-flex h-10 w-10 items-center justify-center rounded-full bg-zinc-900 text-white">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width={card.iconWidth}
                      height={card.iconHeight}
                      fill="currentColor"
                    >
                      <path d={card.iconPath} />
                    </svg>
                  </span>

                  <h3 className="mt-4 font-heading text-xl font-semibold text-zinc-950">{card.title}</h3>
                  <p className="mt-2 text-sm text-zinc-600">{card.description}</p>

                  <a
                    href="#0"
                    className="mt-5 inline-flex items-center gap-2 text-sm font-medium text-zinc-900 transition-colors hover:text-zinc-600"
                  >
                    {card.cta}
                    <svg xmlns="http://www.w3.org/2000/svg" width="9" height="9" fill="currentColor">
                      <path d="m1.285 8.514-.909-.915 5.513-5.523H1.663l.01-1.258h6.389v6.394H6.794l.01-4.226z" />
                    </svg>
                  </a>
                </article>
              ))}
            </div>
          </div>
        </section>
      </main>

      <GraySiteFooter />
    </div>
  );
}
