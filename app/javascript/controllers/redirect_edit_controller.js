import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const urlParams = new URLSearchParams(window.location.search);
    const notification = urlParams.get("notification");
    if (notification) {
      const message = atob(notification); // Decode the message from base64
      const flashContainer = document.createElement("ul");
      flashContainer.classList.add("flashes");
      flashContainer.innerHTML = `<li class="flash-success">${message}</li>`;
      document.body.insertAdjacentElement("afterbegin", flashContainer);

      // Remove the query parameter from the URL without reloading the page
      window.history.replaceState({}, document.title, window.location.pathname);
    }
  }

  redirectToShow(event) {
    event.preventDefault();

    const form = this.element.closest("form");
    const userId = form.dataset.userId; //

    if (!userId) {
      console.error("User ID is undefined");
      return;
    }

    fetch(form.action, {
      method: form.method,
      body: new FormData(form),
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "X-CSRF-Token": document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content"),
      },
    }).then((response) => {
      if (response.ok) {
        // window.location.href = `/users/${userId}`;

        const message = btoa("Utilisateur modifié avec succès."); // Encode the message into base64
        window.location.href = `/users/${userId}/?notification=${message}`;
      } else {
        response.text().then((html) => {
          document.body.innerHTML = html;
        });
      }
    });
  }
}
