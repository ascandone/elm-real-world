module Page exposing (Page(..))

import Page.Article
import Page.Home
import Page.Login
import Page.Register


type Page
    = Home Page.Home.Model
    | Login Page.Login.Model
    | Register Page.Register.Model
    | Settings ()
    | NewPost ()
    | Editor ()
    | Article Page.Article.Model
    | Profile ()
    | NotFound
