module View.Pagination exposing (Pagination, getData, init, view)

import Html exposing (..)
import Html.Attributes exposing (class, classList, href)
import Html.Events as E
import Html.Lazy exposing (lazy2)


type Pagination
    = Pagination
        { page : Int
        , pageSize : Int
        }


init : { pageSize : Int } -> Pagination
init { pageSize } =
    Pagination { page = 0, pageSize = pageSize }


getData : Pagination -> { offset : Int, limit : Int }
getData (Pagination data) =
    { offset = data.page * data.pageSize
    , limit = data.pageSize
    }



-- WINDOW := 10
-- init
-- off = 0
-- > api/articles?offset=0&limit=10
-- Selected 4:
-- off = 4 * window = 40
-- > api/articles?offset=40


type Msg
    = PageSelected Int


view_ : Int -> Pagination -> Html Msg
view_ articlesCount pagination =
    let
        (Pagination data) =
            pagination

        pagesNumber =
            ceiling (toFloat articlesCount / 10)

        pages =
            List.range 0 (pagesNumber - 1)
    in
    ul [ class "pagination" ]
        (pages
            |> List.map
                (\index ->
                    li [ class "page-item", classList [ ( "active", index == data.page ) ] ]
                        [ a [ class "page-link", href "", E.onClick (PageSelected index) ]
                            [ text (String.fromInt (index + 1)) ]
                        ]
                )
        )


selectPagination : Int -> Pagination -> Pagination
selectPagination newPage (Pagination data) =
    Pagination { data | page = newPage }


view : { articlesCount : Int, pagination : Pagination, onSelected : Pagination -> msg } -> Html msg
view props =
    Html.map (\(PageSelected page) -> props.onSelected (selectPagination page props.pagination)) <|
        lazy2 view_ props.articlesCount props.pagination
