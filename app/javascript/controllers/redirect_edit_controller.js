import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  redirectToShow(event) {
    event.preventDefault();

    const form = this.element.closest("form");
    const userId = form.dataset.userId; //

    if (!userId) {
      console.error("User ID is undefined");
      return;
    }

    // Soumettre le formulaire
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
        window.location.href = `/users/${userId}`;

        this.showNotification("Utilisateur modifié avec succès.");
      } else {
        response.text().then((html) => {
          document.body.innerHTML = html;
        });
      }
    });
  }

  showNotification(message) {
    const bodyContainer = document.getElementsByTagName("body")[0];
    const flashContainer = document.createElement("ul");
    flashContainer.insertAdjacentHTML(
      "afterbegin",
      `<li class="flash-success">${message}</li>`
    );
    bodyContainer.insertAdjacentElement("afterbegin", flashContainer);

    // bodyContainer.style.display = "block";

    // Masquer la notification après quelques secondes
    setTimeout(() => {
      bodyContainer.style.display = "none";
    }, 3000);
  }
}
