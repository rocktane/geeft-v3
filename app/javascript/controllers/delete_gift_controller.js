import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {}

  // Deletion of a gift on an event 'edit' page
  delete(gift) {
    const userConfirmed = confirm(
      "Êtes-vous sûr de vouloir supprimer ce cadeau ?"
    );
    // if (userConfirmed) gift.target.parentElement.remove();
    if (userConfirmed) {
      const giftId = gift.target.dataset.giftid || "";
      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      ).content;
      let env = gift.target.dataset.env || "";

      // If the environment is not defined, we set it to development
      if (env === "development") {
        env = "http://localhost:3000";
      } else {
        env = "https://www.geeft.club";
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
          return response.json(); // Ou response.text() si aucune donnée JSON n'est retournée
        })
        .then((data) => {
          // Traitez la réponse du serveur (si nécessaire)
          // Mettez à jour l'interface utilisateur pour refléter la suppression
          gift.target.closest("li").remove();
        })
        .catch((error) => {
          console.error("Erreur lors de la requête DELETE :", error);
          // Gérez l'erreur et affichez un message à l'utilisateur
        });
    }
  }
}
