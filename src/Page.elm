module Page exposing (Page(..))

import Page.Home
import Page.Login


type Page
    = Home Page.Home.Model
    | Login Page.Login.Model
    | NotFound
