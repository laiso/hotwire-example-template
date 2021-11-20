import { Controller } from "@hotwired/stimulus"
import dialogPolyfill from "https://cdn.skypack.dev/dialog-polyfill"

export default class extends Controller {
  initialize() {
    dialogPolyfill.registerDialog(this.element)
  }

  connect() {
    if (this.element.open) this.showModal()
  }

  showModal() {
    if (this.element.open) return
    else this.element.showModal()
  }

  breakOut(event) {
    event.preventDefault()

    this.element.close()
    event.target.src = null
    Turbo.visit(event.detail.fetchResponse)
  }
}
