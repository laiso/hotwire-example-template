import { Controller } from "@hotwired/stimulus"
import { TemplateInstance } from "https://cdn.skypack.dev/@github/template-parts"

export default class extends Controller {
  static get targets() { return [ "template" ] }
  static get values() { return { placeholder: String } }

  insert({ target }) {
    const id = (new Date()).getTime().toString()
    const template = new TemplateInstance(this.templateTarget, { [this.placeholderValue]: id })

    target.before(template)
  }
}
