// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "tailwind.config"
import "@hotwired/turbo-rails"
import "controllers"
import "trix"
import "@rails/actiontext"

const getTurboFrame = (element) => {
  const id = element.getAttribute("data-turbo-frame")
  const target = id ?
    document.querySelector(`turbo-frame#${id}:not([disabled]):not([target="_top"])`) :
    null

  return target || element.closest(`turbo-frame:not([disabled]):not([target="_top"])`)
}

addEventListener("click", ({ target }) => {
  if (target.matches("a")) {
    const frame = getTurboFrame(target)
    const rendering = target.getAttribute("data-turbo-rendering")

    if (frame && rendering) {
      const documentFragment = new DocumentFragment()

      frame.addEventListener("turbo:before-fetch-response", () => {
        documentFragment.replaceChildren(...frame.children)
      }, { once: true })

      frame.addEventListener("turbo:frame-render", () => {
        if (rendering == "append") {
          documentFragment.append(...frame.children)
        } else if (rendering == "prepend") {
          documentFragment.prepend(...frame.children)
        }
        frame.replaceChildren(documentFragment)
      }, { once: true })
    }
  }
}, { passive: true })
