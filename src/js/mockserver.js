import { createServer, Model } from "miragejs";
import { articles, tags, user } from "./mockdata";

createServer({
  models: {
    article: Model,
  },

  routes() {
    this.urlPrefix = "https://conduit.productionready.io";
    this.namespace = "api";

    this.get("/articles", () => articles);
    this.get("/articles/feed", () => articles);

    this.get("/tags", () => ({ tags }));

    this.post("/users/login", () => ({ user }));
  },
});
