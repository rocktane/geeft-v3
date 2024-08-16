import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text"];

  connect() {
    this.textTargets.forEach((text) => {
      this.adjustHeight(text);
      text.addEventListener('input', () => this.adjustHeight(text));
    });
  }

  adjustHeight(text) {
    text.style.height = 'auto';
    text.style.height = `${text.scrollHeight}px`;
  }
}
