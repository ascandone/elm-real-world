import { Elm } from './Main.elm'

const namespace = "user-ns"

const app = Elm.Main.init({
  node: document.getElementById('elm-root'),
  flags: {
    user: localStorage.getItem(namespace)
  }
})
