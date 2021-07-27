import { createServer, Model } from "miragejs";
import { articles, tags } from "./mockdata";

createServer({
  models: {
    article: Model,
  },

  routes() {
    this.urlPrefix = "https://conduit.productionready.io";
    this.namespace = "api";

    this.get("/articles", () => articles);

    this.get("/tags", () => ({ tags }));

    this.post("/users/login", () => ({
      user: {
        email: "jake@jake.jake",
        token: "jwt.token.here",
        username: "jake",
        bio: "I work at statefarm",
        image: null,
      },
    }));
  },
});
