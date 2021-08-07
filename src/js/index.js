import { Elm } from "../Main.elm";

if (process.env.NODE_ENV === "development") {
  import("./mockserver").then((res) => {
    res.default();
    main();
  });
} else {
  main();
}

function main() {
  const USER_NS = "user-ns";

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
    console.log("delete");
    // localStorage.removeItem(USER_NS);
  });
}
