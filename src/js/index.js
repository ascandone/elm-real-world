import { Elm } from "../Main.elm";
import "./mockserver";

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
