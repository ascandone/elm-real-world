module Page exposing (Page(..))

import Page.Article
import Page.Editor
import Page.Home
import Page.Login
import Page.NewPost
import Page.Profile
import Page.Register
import Page.Settings


type Page
    = Home Page.Home.Model
    | Login Page.Login.Model
    | Register Page.Register.Model
    | Settings Page.Settings.Model
    | NewPost Page.NewPost.Model
    | Editor Page.Editor.Model
    | Article Page.Article.Model
    | Profile String Page.Profile.Model
    | NotFound
