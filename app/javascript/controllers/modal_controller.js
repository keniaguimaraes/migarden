import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  open() {
    document.body.classList.add("modal-open")
  }

  close(event) {
    if (event) event.preventDefault()
    const turboFrame = this.element.closest("turbo-frame")
    if (turboFrame) {
      turboFrame.innerHTML = ""
    } else {
      this.element.remove()
    }
    document.body.classList.remove("modal-open")
  }

  handleKeydown = (event) => {
    if (event.key === "Escape" && document.body.classList.contains("modal-open")) {
      this.close()
    }
  }
}
