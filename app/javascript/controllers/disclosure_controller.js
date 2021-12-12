import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() { return [ "details" ] }
  static get values() { return { state: Object } }

  detailsTargetConnected(target) {
    const { id } = target

    if (id in this.stateValue) target.open = this.stateValue[id]
  }

  detailsTargetDisconnected({ id, open }) {
    if (id) this.stateValue = { ...this.stateValue, [id]: open }
  }

  invalidate({ detail: { url } }) {
    const { pathname } = new URL(url)

    if (window.location.pathname != pathname) this.stateValue = {}
  }
}
