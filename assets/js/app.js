// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import "core-js/stable"
import "regenerator-runtime/runtime"

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import requestMidiAccess from "./midi"
const navigator = window.navigator

const Hooks = {}
Hooks.ConnectMidi = {
  mounted() {
    if (!navigator.requestMIDIAccess) {
      this.el.disabled = true
      alert("This browser does not support Web MIDI. Try site in Firefox or Chrome browser.")
      return
    } else {
      const _this = this
      const handler = () => {
        const requestAccess = requestMidiAccess
        console.log('Request access...')
        requestAccess(navigator, _this)
      }
      this.el.addEventListener("click", handler)
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks})
liveSocket.connect()
