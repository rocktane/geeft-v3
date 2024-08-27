import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button"];

  connect() {
    this.updateButtonPosition();
    window.addEventListener("scroll", () => this.updateButtonPosition());
    window.addEventListener("resize", () => this.updateButtonPosition());
  }

  disconnect() {
    window.removeEventListener("scroll", () => this.updateButtonPosition());
    window.removeEventListener("resize", () => this.updateButtonPosition());
  }

  updateButtonPosition() {
    const button = this.buttonTarget;
    const footer = document.getElementById("global-footer");

    if (!footer) return;

    const windowBottom = window.innerHeight;
    const footerTop = footer.getBoundingClientRect().top;

    if (windowBottom >= footerTop) {
      button.style.bottom = `${windowBottom - footerTop +32}px`;
    } else {
      button.style.position = "fixed";
      button.style.bottom = "2em";
    }
  }
}
