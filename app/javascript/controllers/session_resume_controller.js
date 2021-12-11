import { Controller } from "@hotwired/stimulus"
import { persistResumableFields, restoreResumableFields, setForm } from "https://cdn.skypack.dev/@github/session-resume"

export default class extends Controller {
  static get targets() { return [ "field" ] }

  setForm(event) {
    setForm(event)
  }

  cache() {
    const selector = `[data-${this.identifier}-target="field"]`

    persistResumableFields(getPageID(), { selector })
  }

  fieldTargetConnected() {
    restoreResumableFields(getPageID())
  }
}

function getPageID() {
  return window.location.pathname
}
