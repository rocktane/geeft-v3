import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["icon"];

  connect() {
    console.log("Icon Calendar controller connected");
  }

  openCalendar() {
    this.iconTarget.focus();

    if (this.iconTarget._flatpickr) {
      this.iconTarget._flatpickr.open();
    }
  }
}
