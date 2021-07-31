import { createServer, Model } from "miragejs";
import { articles, tags, user } from "./mockdata";

const getFavoriteArticle = (favorited) =>
  function favoriteArticle(_schema, req) {
    const article = articles.articles.find((a) => a.slug === req.params.slug);
    return {
      article: {
        ...article,
        favorited,
        favoritesCount: article.favoritesCount + (favorited ? +1 : 0),
      },
    };
  };
const getFollowAuthor = (following) =>
  function followAuthor(_schema, req) {
    const profile = articles.articles.find(
      (a) => a.author.username === req.params.username
    ).author;

    return {
      profile: {
        ...profile,
        following,
      },
    };
  };

createServer({
  models: {
    article: Model,
  },

  routes() {
    this.urlPrefix = "https://conduit.productionready.io";
    this.namespace = "api";

    this.get("/articles", () => articles);
    this.get("/articles/feed", () => articles);

    this.post("/articles/:slug/favorite", getFavoriteArticle(true));
    this.delete("/articles/:slug/favorite", getFavoriteArticle(false));
    this.get("/articles/:slug", () => ({ article: articles.articles[1] }));

    this.post("/profiles/:username/follow", getFollowAuthor(true));
    this.delete("/profiles/:username/follow", getFollowAuthor(false));

    this.get("/tags", () => ({ tags }));

    this.post("/users/login", () => ({ user }));
  },
});
