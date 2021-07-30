import { createServer, Model } from "miragejs";
import { articles, tags, user } from "./mockdata";

function favoriteArticle(_schema, req) {
  const article = articles.articles.find((a) => a.slug === req.params.slug);
  return {
    article: {
      ...article,
      favorited: !article.favorited,
      favoritesCount: article.favoritesCount + (article.favorited ? -1 : +1),
    },
  };
}

createServer({
  models: {
    article: Model,
  },

  routes() {
    this.urlPrefix = "https://conduit.productionready.io";
    this.namespace = "api";

    this.get("/articles", () => articles);
    this.get("/articles/feed", () => articles);

    this.post("articles/:slug/favorite", favoriteArticle);
    this.delete("articles/:slug/favorite", favoriteArticle);
    this.get("articles/:slug", () => ({ article: articles.articles[1] }));

    this.get("/tags", () => ({ tags }));

    this.post("/users/login", () => ({ user }));
  },
});
