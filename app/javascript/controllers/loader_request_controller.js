import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="loader-request"
export default class extends Controller {
  static targets = ["form", "container"];
  static values = { event: Number };

  connect() {
    if (typeof Turbolinks !== "undefined") {
      document.addEventListener("turbolinks:before-cache", this.hideLoader());
    }
  }

  disconnect() {
    if (typeof Turbolinks !== "undefined") {
      document.removeEventListener("turbolinks:before-cache");
    }
    this.hideLoader();
  }

  hideLoader() {
    // Votre code existant pour cacher le loader et supprimer le flou
    const navbar = document.querySelector(".navbar");
    const loader = document.querySelector(".loader-wrapper");
    navbar.style.transition = "";
    navbar.classList.remove("blurred");
    this.containerTarget.style.transition = "";
    this.containerTarget.classList.remove("blurred");
    loader.style.display = "none";
  }

  // disconnect() {
  //   // Unblur tout + cache le loader
  //   const navbar = document.querySelector(".navbar");
  //   const loader = document.querySelector(".loader-wrapper");
  //   navbar.style.transition = "";
  //   navbar.classList.remove("blurred");
  //   this.containerTarget.style.transition = "";
  //   this.containerTarget.classList.remove("blurred");
  //   loader.style.display = "none";
  // }

  flash(message) {
    let flashContainer = document.querySelector(".flashes");
    if (!flashContainer) {
      flashContainer = document.createElement("ul");
      flashContainer.classList.add("flashes");
      document.body.insertAdjacentElement("afterbegin", flashContainer);
    }

    const flashMessage = document.createElement("li");
    flashMessage.classList.add("flash-success");
    flashMessage.textContent = message;

    flashContainer.appendChild(flashMessage);
    setTimeout(() => {
      flashContainer.removeChild(flashMessage);
    }, 10000);
  }

  checkForm(event) {
    event.preventDefault();

    const form = event.target; // Formulaire cible

    // Réinitialiser les erreurs précédentes
    clearErrors(form);

    let isValid = true;

    // Vérification de la validité native HTML5
    if (!form.checkValidity()) {
      showErrors(form);
      isValid = false;
    }

    // Validation personnalisée pour les choix multiples (checkboxes)
    const relationship = form.querySelectorAll(
      'input[name="gift[relationship]"]'
    );
    const selectedRelationship = Array.from(relationship).filter(
      (input) => input.checked
    );
    const occasion = form.querySelectorAll('input[name="gift[occasion]"]');
    const selectedOccasion = Array.from(occasion).filter(
      (input) => input.checked
    );
    const interests = form.querySelectorAll('input[name="gift[interests][]"]');
    const selectedInterests = Array.from(interests).filter(
      (input) => input.checked
    );

    if (
      selectedInterests.length === 0 ||
      selectedRelationship.length === 0 ||
      selectedOccasion.length === 0
    ) {
      isValid = false;
    }

    if (isValid) {
      this.fetchApi(event);
    } else {
      if (selectedInterests.length === 0) {
        this.flash("Aucune passion n'a été indiquée !");
      }
      if (selectedRelationship.length === 0) {
        this.flash("Il manque la relation !");
      }
      if (selectedOccasion.length === 0) {
        this.flash("Il manque l'occasion !");
      }
    }

    function clearErrors(form) {
      const errorElements = form.querySelectorAll(".error");
      errorElements.forEach((element) => element.remove());
    }

    function showErrors(form) {
      const invalidElements = form.querySelectorAll(":invalid");
      invalidElements.forEach((element) => {
        const errorMessage = document.createElement("span");
        errorMessage.className = "error";
        errorMessage.textContent = element.validationMessage;
        element.parentNode.insertBefore(errorMessage, element.nextSibling);
      });
    }
  }

  async fetchApi(event) {
    event.preventDefault();
    const url = this.formTarget.action;
    const formData = new FormData(this.formTarget);

    // Blur tout + Affiche le loader
    const navbar = document.querySelector(".navbar");
    const loader = document.querySelector(".loader-wrapper");
    navbar.style.transition = "filter ease-in-out 0.5s";
    navbar.classList.add("blurred");
    this.containerTarget.style.transition = "filter ease-in-out 0.5s";
    this.containerTarget.classList.add("blurred");
    loader.style.display = "flex";

    try {
      const response = await fetch(url, {
        method: this.formTarget.method,
        Accept: "application/json",
        body: formData,
      });

      const data = await response.json();

      window.setTimeout(() => {
        if (this.eventValue === 0) {
          window.location.href = `/gifts/${data.id}`;
        } else {
          window.location.href = `/gifts/${data.id}?event_id=${this.eventValue}`;
        }
      }, 500);
    } catch (error) {
      console.error("Une erreur s'est produite :", error);
    }
  }
}
