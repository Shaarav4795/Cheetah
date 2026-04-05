"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

import { GraySiteFooter, GraySiteHeader } from "@/components/gray/GrayChrome";

interface CounterStat {
  value: number;
  decimals: number;
  suffix: string;
  description: string;
}

interface FeatureTab {
  title: string;
  description: string;
  alt: string;
}

interface FeatureCard {
  title: string;
  description: string;
  image: string;
  imageWidth: number;
  imageHeight: number;
  iconPath: string;
}

interface WorkflowTab {
  title: string;
  description: string;
  iconPath: string;
  alt: string;
}

interface PricingBracket {
  contacts: string;
  plans: {
    essential: string;
    premium: string;
    enterprise: string;
  };
}

interface Testimonial {
  name: string;
  handle: string;
  image: string;
  alt: string;
}

const counterStats: CounterStat[] = [
  {
    value: 100,
    decimals: 0,
    suffix: "+",
    description: "Unique animated runners in the library, from cheetahs to dragons.",
  },
  {
    value: 60,
    decimals: 0,
    suffix: "x/s",
    description: "Real-time CPU/memory updates for instant performance insights.",
  },
  {
    value: 99.9,
    decimals: 1,
    suffix: "%",
    description: "Lightweight and efficient, barely impacts your system.",
  },
  {
    value: 2021,
    decimals: 0,
    suffix: "",
    description: "First shipped as a menu bar monitoring app for macOS.",
  },
];

const featureTabs: FeatureTab[] = [
  {
    title: "CPU Monitoring",
    description: "Real-time CPU usage tracking with per-core breakdown and detailed process analysis.",
    alt: "Feature 01",
  },
  {
    title: "Memory Tracking",
    description: "Monitor RAM usage with visual indicators and instant access to memory-heavy processes.",
    alt: "Feature 02",
  },
  {
    title: "Visual Feedback",
    description: "Animated runners reflect your Mac's performance, making monitoring fun and intuitive.",
    alt: "Feature 03",
  },
  {
    title: "Settings Customization",
    description: "Choose your favorite runner, adjust refresh rates, and customize display options.",
    alt: "Feature 04",
  },
];

const featureCards: FeatureCard[] = [
  {
    title: "Real-time CPU & Memory Graphs",
    description:
      "Visual history of your system performance with up to 2 minutes of historical data.",
    image: "/gray/images/feature-post-01.png",
    imageWidth: 721,
    imageHeight: 280,
    iconPath:
      "M17 9c.6 0 1 .4 1 1v6a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h6c.6 0 1 .4 1 1s-.4 1-1 1H4v12h12v-6c0-.6.4-1 1-1Zm-.7-6.7c.4-.4 1-.4 1.4 0 .4.4.4 1 0 1.4l-8 8c-.2.2-.4.3-.7.3-.3 0-.5-.1-.7-.3-.4-.4-.4-1 0-1.4l8-8Z",
  },
  {
    title: "Top Processes List",
    description:
      "See which apps are eating your CPU and memory - perfect for debugging performance issues.",
    image: "/gray/images/feature-post-02.png",
    imageWidth: 342,
    imageHeight: 280,
    iconPath:
      "m6.035 17.335-4-14c-.2-.8.5-1.5 1.3-1.3l14 4c.9.3 1 1.5.1 1.9l-6.6 2.9-2.8 6.6c-.5.9-1.7.8-2-.1Zm-1.5-12.8 2.7 9.5 1.9-4.4c.1-.2.3-.4.5-.5l4.4-1.9-9.5-2.7Z",
  },
  {
    title: "100+ Animated Runners",
    description: "Choose from adorable characters like cheetahs, cats, dragons, and many more.",
    image: "/gray/images/feature-post-03.png",
    imageWidth: 342,
    imageHeight: 280,
    iconPath:
      "M8.974 16c-.3 0-.7-.2-.9-.5l-2.2-3.7-2.1 2.8c-.3.4-1 .5-1.4.2-.4-.3-.5-1-.2-1.4l3-4c.2-.3.5-.4.9-.4.3 0 .6.2.8.5l2 3.3 3.3-8.1c0-.4.4-.7.8-.7s.8.2.9.6l4 8c.2.5 0 1.1-.4 1.3-.5.2-1.1 0-1.3-.4l-3-6-3.2 7.9c-.2.4-.6.6-1 .6Z",
  },
  {
    title: "System Info Dashboard",
    description: "View CPU cores, model, memory capacity, and detailed system specifications.",
    image: "/gray/images/feature-post-04.png",
    imageWidth: 342,
    imageHeight: 280,
    iconPath:
      "M9.3 11.7c-.4-.4-.4-1 0-1.4l7-7c.4-.4 1-.4 1.4 0 .4.4.4 1 0 1.4l-7 7c-.4.4-1 .4-1.4 0ZM9.3 17.7c-.4-.4-.4-1 0-1.4l7-7c.4-.4 1-.4 1.4 0 .4.4.4 1 0 1.4l-7 7c-.4.4-1 .4-1.4 0ZM2.3 12.7c-.4-.4-.4-1 0-1.4l7-7c.4-.4 1-.4 1.4 0 .4.4.4 1 0 1.4l-7 7c-.4.4-1 .4-1.4 0Z",
  },
  {
    title: "Customizable Menu Bar Display",
    description: "Toggle CPU and memory visibility in the menu bar, and adjust runner speed behavior.",
    image: "/gray/images/feature-post-05.png",
    imageWidth: 342,
    imageHeight: 280,
    iconPath:
      "M16 2H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h8.667l3.733 2.8A1 1 0 0 0 18 17V4a2 2 0 0 0-2-2Zm0 13-2.4-1.8a1 1 0 0 0-.6-.2H4V4h12v11Z",
  },
];

const workflowTabs: WorkflowTab[] = [
  {
    title: "Menu Bar Integration",
    description:
      "Cheetah sits quietly in your menu bar, always accessible with a single click.",
    iconPath:
      "m7.951 14.537 6.296-7.196 1.506 1.318-7.704 8.804-3.756-3.756 1.414-1.414 2.244 2.244Zm11.296-7.196 1.506 1.318-7.704 8.804-1.756-1.756 1.414-1.414.244.244 6.296-7.196Z",
    alt: "Carousel 01",
  },
  {
    title: "Live Performance Monitoring",
    description:
      "Watch your CPU and memory usage in real-time with animated visual feedback.",
    iconPath:
      "m16.997 19.056-1.78-.912A13.91 13.91 0 0 0 16.75 11.8c0-2.206-.526-4.38-1.533-6.344l1.78-.912A15.91 15.91 0 0 1 18.75 11.8c0 2.524-.602 5.01-1.753 7.256Zm-3.616-1.701-1.77-.93A9.944 9.944 0 0 0 12.75 11.8c0-1.611-.39-3.199-1.14-4.625l1.771-.93c.9 1.714 1.37 3.62 1.369 5.555 0 1.935-.47 3.841-1.369 5.555Zm-3.626-1.693-1.75-.968c.49-.885.746-1.881.745-2.895a5.97 5.97 0 0 0-.745-2.893l1.75-.968a7.968 7.968 0 0 1 .995 3.861 7.97 7.97 0 0 1-.995 3.863Zm-3.673-1.65-1.664-1.11c.217-.325.333-.709.332-1.103 0-.392-.115-.776-.332-1.102L6.082 9.59c.437.655.67 1.425.668 2.21a3.981 3.981 0 0 1-.668 2.212Z",
    alt: "Carousel 02",
  },
  {
    title: "Quick Settings Access",
    description:
      "Customize runner selection, refresh rates, and display preferences from the settings window.",
    iconPath:
      "m11.293 5.293 1.414 1.414-8 8-1.414-1.414 8-8Zm7-1 1.414 1.414-8 8-1.414-1.414 8-8Zm0 6 1.414 1.414-8 8-1.414-1.414 8-8Z",
    alt: "Carousel 03",
  },
];

const workflowPoints = [
  {
    title: "60 Updates Per Second",
    description:
      "Smooth, responsive monitoring that captures every CPU spike and memory fluctuation.",
    iconPath:
      "M15 9a1 1 0 0 1 0 2c-.441 0-1.243.92-1.89 1.716.319 1.005.529 1.284.89 1.284a1 1 0 0 1 0 2 2.524 2.524 0 0 1-2.339-1.545A3.841 3.841 0 0 1 9 16a1 1 0 0 1 0-2c.441 0 1.243-.92 1.89-1.716C10.57 11.279 10.361 11 10 11a1 1 0 0 1 0-2 2.524 2.524 0 0 1 2.339 1.545A3.841 3.841 0 0 1 15 9Zm-5-1H7.51l-.02.142C6.964 11.825 6.367 16 3 16a3 3 0 0 1-3-3 1 1 0 0 1 2 0 1 1 0 0 0 1 1c1.49 0 1.984-2.48 2.49-6H3a1 1 0 1 1 0-2h2.793c.52-3.1 1.4-6 4.207-6a3 3 0 0 1 3 3 1 1 0 0 1-2 0 1 1 0 0 0-1-1C8.808 2 8.257 3.579 7.825 6H10a1 1 0 0 1 0 2Z",
  },
  {
    title: "Process Insights",
    description:
      "See which apps are consuming the most resources and optimize your workflow accordingly.",
    iconPath:
      "M13 16c-.153 0-.306-.035-.447-.105l-3.851-1.926c-.231.02-.465.031-.702.031-4.411 0-8-3.14-8-7s3.589-7 8-7 8 3.14 8 7c0 1.723-.707 3.351-2 4.63V15a1.003 1.003 0 0 1-1 1Zm-4.108-4.054c.155 0 .308.036.447.105L12 13.382v-2.187c0-.288.125-.562.341-.752C13.411 9.506 14 8.284 14 7c0-2.757-2.691-5-6-5S2 4.243 2 7s2.691 5 6 5c.266 0 .526-.02.783-.048a1.01 1.01 0 0 1 .109-.006Z",
  },
  {
    title: "Lightweight Smart Design",
    description:
      "Minimal system overhead means you can monitor without impacting your Mac's performance.",
    iconPath: "M13 0H1C.4 0 0 .4 0 1v14c0 .6.4 1 1 1h8l5-5V1c0-.6-.4-1-1-1ZM2 2h10v8H8v4H2V2Z",
  },
  {
    title: "Customizable Runners",
    description:
      "Switch between your favorite characters whenever your mood strikes.",
    iconPath:
      "M7 14c-3.86 0-7-3.14-7-7s3.14-7 7-7 7 3.14 7 7-3.14 7-7 7ZM7 2C4.243 2 2 4.243 2 7s2.243 5 5 5 5-2.243 5-5-2.243-5-5-5Zm8.707 12.293a.999.999 0 1 1-1.414 1.414L11.9 13.314a8.019 8.019 0 0 0 1.414-1.414l2.393 2.393Z",
  },
  {
    title: "Drag & Drop Settings",
    description:
      "Quick access to runner picker, CPU/memory toggles, and refresh rate controls.",
    iconPath:
      "M14.6.085 8 2.885 1.4.085c-.5-.2-1.4-.1-1.4.9v11c0 .4.2.8.6.9l7 3c.3.1.5.1.8 0l7-3c.4-.2.6-.5.6-.9v-11c0-1-.9-1.1-1.4-.9ZM2 2.485l5 2.1v8.8l-5-2.1v-8.8Zm12 8.8-5 2.1v-8.7l5-2.1v8.7Z",
  },
  {
    title: "System Info Cards",
    description:
      "Core count, model, total memory, and more - all at a glance when you need it.",
    iconPath:
      "M13 14a1 1 0 0 1 0 2H1a1 1 0 0 1 0-2h12Zm-6.707-2.293-5-5a1 1 0 0 1 1.414-1.414L6 8.586V1a1 1 0 1 1 2 0v7.586l3.293-3.293a1 1 0 1 1 1.414 1.414l-5 5a1 1 0 0 1-1.414 0Z",
  },
] as const;

export function GrayHomePage() {
  const [featureTab, setFeatureTab] = useState(0);
  const [workflowTab, setWorkflowTab] = useState(0);

  return (
    <div className="min-h-screen bg-white text-zinc-900">
      <GraySiteHeader />

      <main className="overflow-hidden pt-28">
        <section className="relative px-4 pb-20 pt-10 sm:px-6 lg:px-8">
          <div className="absolute inset-x-0 top-0 -z-10 mx-auto h-[480px] w-[680px] rounded-full bg-[radial-gradient(circle_at_center,rgba(24,24,27,0.08),transparent_72%)]" />
          <div className="mx-auto w-full max-w-6xl">
            <div className="mx-auto max-w-4xl text-center">
              <h1 className="font-heading text-4xl font-semibold leading-tight tracking-tight text-zinc-950 sm:text-5xl lg:text-6xl">
                Monitor Your Mac's Performance with
                <span className="relative mx-2 inline-block">
                  <em className="not-italic gray-heading-gradient">Adorable Runners</em>
                  <svg
                    className="absolute -bottom-3 left-0 h-5 w-full text-zinc-900/70"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 120 10"
                    fill="currentColor"
                    aria-hidden="true"
                    preserveAspectRatio="none"
                  >
                    <path d="M118.273 6.09C79.243 4.558 40.297 5.459 1.305 9.034c-1.507.13-1.742-1.521-.199-1.81C39.81-.228 79.647-1.568 118.443 4.2c1.63.233 1.377 1.943-.17 1.89Z" />
                  </svg>
                </span>
              </h1>
              <p className="mx-auto mt-6 max-w-2xl text-lg text-zinc-600">
                Real-time CPU and memory monitoring for macOS. Watch your system performance through animated characters that react to your Mac's activity.
              </p>
              <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
                <a href="https://github.com/Shaarav4795/Cheetah/releases/download/v1.0.0/Cheetah.1.0.dmg.zip" className="gray-button-primary w-full sm:w-auto">
                  Download Now
                </a>
                <a href="#features" className="gray-button-secondary w-full sm:w-auto">
                  Learn More
                </a>
              </div>
            </div>

            <div className="mt-12 rounded-[1.75rem] gray-border-light p-2 sm:mt-14">
              <Image
                src="/gray/images/hero-image.png"
                width={1104}
                height={620}
                alt="Hero"
                priority
                className="w-full rounded-[1.3rem]"
              />
            </div>
          </div>
        </section>

        <section id="features" className="bg-zinc-50 px-4 py-20 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <div className="mx-auto max-w-3xl text-center">
              <h2 className="font-heading text-3xl font-semibold tracking-tight text-zinc-950 sm:text-4xl">
                Powerful Monitoring Made Simple
              </h2>
              <p className="mt-4 text-zinc-600">
                See what's really happening on your Mac. Track CPU and memory usage with visual feedback that's both informative and fun.
              </p>
            </div>

            <div className="mt-12 grid gap-8 lg:grid-cols-[380px_1fr] lg:items-start">
              <div className="space-y-3">
                {featureTabs.map((tab, index) => {
                  const isActive = featureTab === index;

                  return (
                    <button
                      key={tab.title}
                      type="button"
                      onClick={() => setFeatureTab(index)}
                      className={`group w-full rounded-2xl p-5 text-left transition-all duration-300 ${
                        isActive
                          ? "gray-border-light bg-white shadow-sm"
                          : "border border-zinc-200 bg-white/70 hover:-translate-y-0.5 hover:border-zinc-300"
                      }`}
                    >
                      <div className="flex items-center justify-between gap-4">
                        <h3 className="font-heading text-lg font-semibold text-zinc-950">{tab.title}</h3>
                        <ArrowIcon
                          className={`transition-all duration-300 group-hover:-translate-y-0.5 group-hover:translate-x-0.5 ${
                            isActive ? "text-zinc-950" : "text-zinc-300 group-hover:text-zinc-700"
                          }`}
                        />
                      </div>
                      <p className="mt-2 text-sm text-zinc-600">{tab.description}</p>
                    </button>
                  );
                })}
              </div>

              <div key={featureTab} className="relative rounded-[1.75rem] gray-border-light p-2 gray-fade-slide-in">
                <Image
                  src="/gray/images/feature-01.png"
                  width={600}
                  height={360}
                  alt={featureTabs[featureTab].alt}
                  priority
                  loading="eager"
                  className="w-full rounded-[1.3rem]"
                />
                <Image
                  src="/gray/images/feature-illustration.png"
                  width={273}
                  height={288}
                  alt="Illustration"
                  aria-hidden="true"
                  className="pointer-events-none absolute -bottom-2 right-2 hidden w-36 md:block"
                />
              </div>
            </div>
          </div>
        </section>

        <section className="px-4 py-20 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <div className="mx-auto max-w-3xl text-center">
              <h2 className="font-heading text-3xl font-semibold tracking-tight text-zinc-950 sm:text-4xl">
                Core Features
              </h2>
              <p className="mt-4 text-zinc-600">
                Everything you need to understand your Mac's performance at a glance.
              </p>
            </div>

            <div className="mt-12 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
              {featureCards.map((card, index) => (
                <article
                  key={card.title}
                  className={`group flex h-full flex-col rounded-3xl gray-border-light p-6 transition-all duration-300 hover:-translate-y-1 hover:shadow-[0_18px_40px_rgb(24_24_27/0.08)] ${
                    index === 0 ? "md:col-span-2 xl:col-span-2" : ""
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <IconBadge path={card.iconPath} />
                    <h3 className="font-heading text-xl font-semibold text-zinc-950">{card.title}</h3>
                  </div>
                  <p className="mt-3 text-sm text-zinc-600">{card.description}</p>
                  <div className="mt-6 overflow-hidden rounded-2xl border border-zinc-200">
                    <Image
                      src={card.image}
                      width={card.imageWidth}
                      height={card.imageHeight}
                      alt={card.title}
                      className="w-full transition-transform duration-500 group-hover:scale-[1.02]"
                    />
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="bg-zinc-800 px-4 py-24 text-zinc-100 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <div className="grid gap-10 lg:grid-cols-[420px_1fr] lg:items-start">
              <div>
                <div className="inline-flex rounded-full border border-zinc-600 bg-zinc-700 px-4 py-1 text-sm text-zinc-300">
                  How It Works
                </div>
                <h2 className="mt-4 font-heading text-3xl font-semibold tracking-tight sm:text-4xl">
                  Simple, Powerful, and Always Running
                </h2>
                <p className="mt-4 text-zinc-300">
                  Cheetah runs in your menu bar and monitors your system in real-time. Choose from 100+ adorable runners, customize your settings, and enjoy performance monitoring that doesn't feel like work.
                </p>

                <div className="mt-8 space-y-3">
                  {workflowTabs.map((tab, index) => {
                    const isActive = workflowTab === index;

                    return (
                      <button
                        key={tab.title}
                        type="button"
                        onClick={() => setWorkflowTab(index)}
                        className={`group w-full rounded-2xl p-4 text-left transition-all duration-300 ${
                          isActive
                            ? "gray-border-dark bg-zinc-700 shadow-sm"
                            : "border border-zinc-700 bg-zinc-800 hover:-translate-y-0.5 hover:border-zinc-500 hover:bg-zinc-700/70"
                        }`}
                      >
                        <div className="flex gap-3">
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            width="24"
                            height="24"
                            fill="currentColor"
                            className={`transition-colors duration-300 ${
                              isActive ? "text-zinc-100" : "text-zinc-500 group-hover:text-zinc-300"
                            }`}
                          >
                            <path d={tab.iconPath} />
                          </svg>
                          <div>
                            <h3 className="font-heading text-lg font-semibold">{tab.title}</h3>
                            <p className="mt-1 text-sm text-zinc-300">{tab.description}</p>
                          </div>
                        </div>
                      </button>
                    );
                  })}
                </div>
              </div>

              <div key={workflowTab} className="relative rounded-[1.75rem] gray-border-dark bg-zinc-800 p-2 gray-fade-slide-in">
                <Image
                  src="/gray/images/carousel-illustration-01.jpg"
                  width={800}
                  priority
                  loading="eager"
                  height={620}
                  alt={workflowTabs[workflowTab].alt}
                  className="w-full rounded-[1.3rem]"
                />
                <Image
                  src="/gray/images/features-illustration.png"
                  width={173}
                  height={167}
                  alt="Features illustration"
                  aria-hidden="true"
                  className="pointer-events-none absolute -bottom-5 right-2 hidden w-24 md:block"
                />
              </div>
            </div>

            <div className="mt-12 grid gap-6 border-t border-zinc-700 pt-10 sm:grid-cols-2 lg:grid-cols-3">
              {workflowPoints.map((item, index) => (
                <div
                  key={`${item.title}${index}`}
                  className="rounded-2xl border border-zinc-700/70 bg-zinc-800/30 p-4 transition-all duration-300 hover:-translate-y-0.5 hover:border-zinc-500 hover:bg-zinc-700/40"
                >
                  <div className="flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" className="text-zinc-100">
                      <path d={item.iconPath} />
                    </svg>
                    <h3 className="font-heading text-lg font-semibold">{item.title}</h3>
                  </div>
                  <p className="mt-2 text-sm text-zinc-300">{item.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="px-4 py-20 sm:px-6 lg:px-8">
          <div className="mx-auto w-full max-w-6xl">
            <div className="mx-auto max-w-4xl rounded-3xl gray-border-light px-6 py-12 text-center sm:px-10">
              <h2 className="font-heading text-4xl font-semibold tracking-tight text-zinc-950 sm:text-5xl">
                Ready to monitor smarter?
              </h2>
              <p className="mx-auto mt-4 max-w-2xl text-zinc-600">
                Download Cheetah today and get instant insights into your Mac's performance. It's free, lightweight, and designed with you in mind.
              </p>

              <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
                <a href="https://github.com/Shaarav4795/Cheetah/releases/download/v1.0.0/Cheetah.1.0.dmg.zip" className="gray-button-primary w-full sm:w-auto">
                  Download Cheetah
                </a>
                <a href="https://github.com/Shaarav4795/Cheetah" className="gray-button-secondary w-full sm:w-auto">
                  View on GitHub
                </a>
              </div>
            </div>
          </div>
        </section>
      </main>

      <GraySiteFooter />
    </div>
  );
}

function AnimatedNumber({ target, decimals }: { target: number; decimals: number }) {
  const [value, setValue] = useState(0);

  useEffect(() => {
    let frameId = 0;
    const duration = 3000;
    const start = performance.now();

    const tick = (timestamp: number) => {
      const progress = Math.min((timestamp - start) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 5);
      setValue(target * eased);

      if (progress < 1) {
        frameId = window.requestAnimationFrame(tick);
      }
    };

    frameId = window.requestAnimationFrame(tick);

    return () => {
      window.cancelAnimationFrame(frameId);
    };
  }, [decimals, target]);

  return <span>{value.toFixed(decimals)}</span>;
}

function IconBadge({ path }: { path: string }) {
  return (
    <span className="inline-flex h-9 w-9 items-center justify-center rounded-full border border-zinc-200 bg-zinc-100 text-zinc-900">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="currentColor">
        <path d={path} />
      </svg>
    </span>
  );
}

function ArrowIcon({ className }: { className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="10"
      height="10"
      fill="currentColor"
      className={className}
      aria-hidden="true"
    >
      <path d="M8.667.186H2.675a.999.999 0 0 0 0 1.998h3.581L.971 7.469a.999.999 0 1 0 1.412 1.412l5.285-5.285v3.58a.999.999 0 1 0 1.998 0V1.186a.999.999 0 0 0-.999-.999Z" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 12" className="h-4 w-4 text-zinc-900">
      <path
        fill="currentColor"
        d="M10.28 2.28L3.989 8.575 1.695 6.28A1 1 0 00.28 7.695l3 3a1 1 0 001.414 0l7-7A1 1 0 0010.28 2.28z"
      />
    </svg>
  );
}

function FaqToggleIcon({ open }: { open: boolean }) {
  return (
    <span className="relative inline-flex h-5 w-5 items-center justify-center rounded-full border border-zinc-300">
      <span className="absolute h-0.5 w-3 rounded bg-zinc-900" />
      <span
        className={`absolute h-3 w-0.5 rounded bg-zinc-900 transition-transform duration-200 ${
          open ? "scale-y-0" : "scale-y-100"
        }`}
      />
    </span>
  );
}
