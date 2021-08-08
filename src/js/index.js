import { Elm } from "../Main.elm";

const USER_NS = "user-ns";

function main() {
  const app = Elm.Main.init({
    node: document.getElementById("elm-root"),
    flags: {
      user: localStorage.getItem(USER_NS),
    },
  });

  app.ports.logError.subscribe(console.error);

  app.ports.serializeUser.subscribe((user) => {
    localStorage.setItem(USER_NS, user);
  });

  app.ports.deleteUser.subscribe(() => {
    localStorage.removeItem(USER_NS);
  });

  window.addEventListener("storage", () => {
    app.ports.storageEvent.send(localStorage.getItem(USER_NS));
  });
}

if (process.env.NODE_ENV === "development") {
  import("./mockserver").then((res) => {
    res.default();
    main();
  });
} else {
  main();
}
