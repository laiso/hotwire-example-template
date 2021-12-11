import { Controller } from "@hotwired/stimulus"
import { persistResumableFields, restoreResumableFields, setForm } from "https://cdn.skypack.dev/@github/session-resume"

export default class extends Controller {
  static get values() { return { selector: String } }

  setForm(event) {
    setForm(event)
  }

  cache() {
    persistResumableFields(getPageID(), { selector: this.selectorValue })
  }

  read() {
    restoreResumableFields(getPageID())
  }
}

function getPageID() {
  return window.location.pathname
}
