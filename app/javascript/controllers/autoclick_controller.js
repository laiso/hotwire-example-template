import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() { return [ "appearance" ] }

  initialize() {
    this.intersection = new IntersectionObserver(this.observe)
  }

  appearanceTargetConnected(target) {
    this.intersection.observe(target)
  }

  appearanceTargetDisconnected(target) {
    this.intersection.unobserve(target)
  }

  observe = (entries, observer) => {
    for (const { isIntersecting, target } of entries) {
      if (isIntersecting) {
        observer.unobserve(target)
        target.click()
      }
    }
  }
}
