import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  expand({ target }) {
    const selectedElements = /select/i.test(target.type) ?
      Array.from(target.selectedOptions) :
      Array.of(target)

    for (const field of this.element.elements.namedItem(target.name)) {
      if (field instanceof HTMLFieldSetElement) field.disabled = true
    }

    for (const selectedElement of selectedElements) {
      for (const element of getElementsByTokens(selectedElement.getAttribute("aria-controls"))) {
        if (element) element.disabled = false
      }
    }
  }
}

function getElementsByTokens(tokens) {
  const ids = (tokens ?? "").split(/\s+/)

  return ids.map(id => document.getElementById(id))
}
