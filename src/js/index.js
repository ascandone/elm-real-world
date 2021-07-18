import { Elm } from "../Main.elm";
import "./mockserver";

const namespace = "user-ns";

const app = Elm.Main.init({
  node: document.getElementById("elm-root"),
  flags: {
    user: localStorage.getItem(namespace),
  },
});

app.ports.logError.subscribe(console.error);
