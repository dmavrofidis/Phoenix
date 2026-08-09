(() => {
  let deferredPrompt = null;

  window.addEventListener("load", () => {
    if ("serviceWorker" in navigator) {
      void navigator.serviceWorker.register("./phoenix-service-worker.js");
    }
  });

  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault();
    deferredPrompt = event;
    document.documentElement.dataset.phoenixPwaReady = "true";
    window.dispatchEvent(new CustomEvent("phoenix-pwa-ready"));
  });

  window.phoenixInstallPwa = async () => {
    if (!deferredPrompt) return false;
    deferredPrompt.prompt();
    const choice = await deferredPrompt.userChoice;
    deferredPrompt = null;
    document.documentElement.dataset.phoenixPwaReady = "false";
    return choice.outcome === "accepted";
  };

  window.addEventListener("phoenix-install-request", () => {
    void window.phoenixInstallPwa();
  });

  window.addEventListener("appinstalled", () => {
    deferredPrompt = null;
    document.documentElement.dataset.phoenixPwaReady = "false";
  });
})();
