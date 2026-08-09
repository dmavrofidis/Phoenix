(() => {
  let deferredPrompt = null;

  window.addEventListener("load", () => {
    const updateConnectivity = () => {
      document.documentElement.dataset.phoenixOnline = String(navigator.onLine);
      window.dispatchEvent(
        new CustomEvent("phoenix-connectivity", {
          detail: { online: navigator.onLine },
        }),
      );
    };
    updateConnectivity();
    window.addEventListener("online", updateConnectivity);
    window.addEventListener("offline", updateConnectivity);

    if ("serviceWorker" in navigator) {
      void navigator.serviceWorker.register("./phoenix-service-worker.js").then(
        (registration) => {
          if (registration.waiting) {
            window.dispatchEvent(new CustomEvent("phoenix-update-ready"));
          }
          registration.addEventListener("updatefound", () => {
            const worker = registration.installing;
            worker?.addEventListener("statechange", () => {
              if (worker.state === "installed" && navigator.serviceWorker.controller) {
                window.dispatchEvent(new CustomEvent("phoenix-update-ready"));
              }
            });
          });
        },
      );
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
