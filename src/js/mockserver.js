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

    this.get("/tags", function (server, req) {
      return { tags };
    });
  },
});
