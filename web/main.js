// ── Configure before launch ──────────────────────────────────────────────
// Leave a value empty until it exists: store buttons then read "Coming soon"
// and the contact link is hidden, so the page never links somewhere broken.
const CONFIG = {
  appStoreUrl: "https://apps.apple.com/us/app/offroad-ai/id6778114511",
  playStoreUrl: "https://play.google.com/store/apps/details?id=com.odibillz.offroad",
  contactEmail: "", // e.g. hello@yourdomain.com
};

// Store buttons
document.querySelectorAll("[data-store]").forEach((link) => {
  const url = link.dataset.store === "appstore" ? CONFIG.appStoreUrl : CONFIG.playStoreUrl;
  if (url) {
    link.href = url;
    link.target = "_blank";
    link.rel = "noopener noreferrer";
  } else {
    link.setAttribute("aria-disabled", "true");
    link.removeAttribute("href");
    link.querySelector("small").textContent = "Coming soon to";
  }
});

// Contact link
document.querySelectorAll("[data-contact]").forEach((link) => {
  if (CONFIG.contactEmail) link.href = `mailto:${CONFIG.contactEmail}`;
  else link.remove();
});

// GitHub star count on the header button. Fetched in the visitor's browser,
// cached for an hour (the API allows 60 unauthenticated calls per hour), and
// only shown once there's at least one star; on any failure the button just
// reads "Star".
(async () => {
  const link = document.querySelector("[data-gh-stars]");
  if (!link) return;
  const KEY = "offroad:gh-stars";
  const show = (n) => {
    if (!(n > 0)) return;
    const el = link.querySelector(".gh-count");
    el.textContent = n >= 1000 ? `${(n / 1000).toFixed(n >= 10000 ? 0 : 1)}k` : String(n);
    el.hidden = false;
    link.setAttribute("aria-label", `Star OffRoad on GitHub, ${n} stars`);
  };
  try {
    const cached = JSON.parse(localStorage.getItem(KEY) || "null");
    if (cached && Date.now() - cached.at < 3600_000) return show(cached.n);
  } catch {}
  try {
    const res = await fetch("https://api.github.com/repos/Odinachi/offroad", {
      headers: { Accept: "application/vnd.github+json" },
    });
    if (!res.ok) return;
    const n = (await res.json()).stargazers_count;
    show(n);
    try {
      localStorage.setItem(KEY, JSON.stringify({ n, at: Date.now() }));
    } catch {}
  } catch {}
})();

document.getElementById("year").textContent = new Date().getFullYear();

// Nav border once the page scrolls
const nav = document.querySelector(".nav");
const onScroll = () => nav.classList.toggle("scrolled", window.scrollY > 8);
onScroll();
window.addEventListener("scroll", onScroll, { passive: true });

// Fade sections in as they enter the viewport
const reveals = document.querySelectorAll(".reveal");
if ("IntersectionObserver" in window) {
  const io = new IntersectionObserver(
    (entries) => {
      for (const e of entries) {
        if (e.isIntersecting) {
          e.target.classList.add("in");
          io.unobserve(e.target);
        }
      }
    },
    { rootMargin: "0px 0px -8% 0px", threshold: 0.08 },
  );
  reveals.forEach((el) => io.observe(el));
} else {
  reveals.forEach((el) => el.classList.add("in"));
}

// Respect reduced motion: don't autoplay the demo video.
const video = document.querySelector(".phone video");
if (video && window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  video.removeAttribute("autoplay");
  video.pause();
  video.controls = true;
}
