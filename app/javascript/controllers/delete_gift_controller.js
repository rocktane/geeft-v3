import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { url: String };

  connect() {}

  flash(message) {
    const flashContainer = document.createElement("ul");
    flashContainer.classList.add("flashes");
    flashContainer.innerHTML = `<li class="flash-success">${message}</li>`;
    document.body.insertAdjacentElement("afterbegin", flashContainer);
  }

  delete(gift) {
    const userConfirmed = confirm(
      "Êtes-vous sûr de vouloir supprimer ce cadeau ?"
    );
    if (userConfirmed) {
      const giftId = gift.target.dataset.giftid || "";
      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      ).content;
      let env = this.urlValue;
      if (env == "localhost:3000") {
        env = "http://" + env;
      }

      const giftIndex = gift.target.dataset.giftindex || "";

      const url = `${env}/gifts/${giftId}/deleteindex/${giftIndex}`;

      fetch(url, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error(
              `Erreur lors de la suppression : ${response.status}`
            );
          }
          return response.json();
        })
        .then((data) => {
          gift.target.closest("li").remove();
          this.flash(data.notice);
        })
        .catch((error) => {
          console.error("Erreur lors de la requête DELETE :", error);
          // Gérez l'erreur et affichez un message à l'utilisateur
        });
    }
  }
}
