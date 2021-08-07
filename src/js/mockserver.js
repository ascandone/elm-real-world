import { createServer, Model } from "miragejs";
import { articles, tags, user, comments } from "./mockdata";

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

function postComment(_schema, { requestBody }) {
  const { body } = JSON.parse(requestBody);

  return {
    comment: {
      id: 103512,
      createdAt: "2021-07-29T18:47:40.214Z",
      updatedAt: "2021-07-29T18:47:40.214Z",
      body,
      author: {
        username: "ascandone",
        bio: "testing new bio",
        image:
          "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8\u0026ixlib=rb-1.2.1\u0026auto=format\u0026fit=crop\u0026w=800\u0026q=80",
        following: false,
      },
    },
  };
}

function getProfile() {
  return {
    profile: {
      username: "joe",
      bio: "testing new bio",
      image:
        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8\u0026ixlib=rb-1.2.1\u0026auto=format\u0026fit=crop\u0026w=800\u0026q=80",
      following: false,
    },
  };
}

export default () =>
  createServer({
    models: {
      article: Model,
    },

    routes() {
      this.urlPrefix = "https://conduit.productionready.io";
      this.namespace = "api";

      this.get("/articles", () => articles);
      this.post("/articles", () => ({ article: articles.articles[1] }));

      this.get("/articles/feed", () => articles);

      this.get("/articles/:slug", () => ({ article: articles.articles[1] }));
      this.delete("/articles/:slug", () => ({}));
      this.put("/articles/:slug", () => ({ article: articles.articles[1] }));

      this.post("/articles/:slug/favorite", getFavoriteArticle(true));
      this.delete("/articles/:slug/favorite", getFavoriteArticle(false));

      this.get("/articles/:slug/comments", () => comments);
      this.post("/articles/:slug/comments", postComment);
      this.delete("/articles/:slug/comments/:id", () => ({}));

      this.get("/profiles/:username", getProfile);
      this.post("/profiles/:username/follow", getFollowAuthor(true));
      this.delete("/profiles/:username/follow", getFollowAuthor(false));

      this.get("/tags", () => ({ tags }));

      this.get("/user", () => ({ user }));
      this.put("/user", () => ({ user }));
      this.post("/users/login", () => ({ user }));
    },
  });
