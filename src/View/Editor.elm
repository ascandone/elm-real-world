module View.Editor exposing
    ( ArticleForm
    , emptyForm
    , view
    )

import Html exposing (..)
import Html.Attributes as A exposing (class, value)
import Html.Events exposing (onInput, onSubmit)


emptyForm : ArticleForm
emptyForm =
    { title = ""
    , description = ""
    , body = ""
    , tags = ""
    }


type alias ArticleForm =
    { title : String
    , description : String
    , body : String
    , tags : String
    }


view :
    { onInput : ArticleForm -> msg
    , onSubmit : ArticleForm -> msg
    }
    -> ArticleForm
    -> Html msg
view props article =
    div [ class "editor-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-10 offset-md-1 col-xs-12" ]
                    [ form [ onSubmit (props.onSubmit article) ]
                        [ Html.map props.onInput <|
                            fieldset []
                                [ fieldset [ class "form-group" ]
                                    [ input
                                        [ A.type_ "text"
                                        , class "form-control form-control-lg"
                                        , A.placeholder "Article Title"
                                        , value article.title
                                        , onInput <| \s -> { article | title = s }
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ A.type_ "text"
                                        , class "form-control"
                                        , A.placeholder "What's this article about?"
                                        , value article.description
                                        , onInput <| \s -> { article | description = s }
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ textarea
                                        [ class "form-control"
                                        , A.rows 8
                                        , A.placeholder "Write your article (in markdown)"
                                        , value article.body
                                        , onInput <| \s -> { article | body = s }
                                        ]
                                        []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ input
                                        [ A.type_ "text"
                                        , class "form-control"
                                        , A.placeholder "Enter tags"
                                        , value article.tags
                                        , onInput <| \s -> { article | tags = s }
                                        ]
                                        []
                                    , div [ class "tag-list" ] []
                                    ]
                                , button
                                    [ class "btn btn-lg pull-xs-right btn-primary"
                                    , A.type_ "submit"
                                    ]
                                    [ text "Publish Article" ]
                                ]
                        ]
                    ]
                ]
            ]
        ]
