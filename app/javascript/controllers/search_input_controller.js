import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search-input"
export default class extends Controller {
  static targets = [
    "input",
    "relationshipInput",
    "occasionInput",
    "interestsInput",
    "buttons" // Ajout d'une target pour les boutons
  ];

  connect() {}

  animate(event) {
    const section = event.target.dataset.searchInputValue;
    const searchInput = this[`${section}InputTarget`];
    const buttons = this.buttonsTarget;
    const xMark = document.querySelector("#x-mark");
    const reset = document.querySelector("#reset");

    searchInput.style.border = "1px solid #ccc";


    if (searchInput.style.width === "0px" || searchInput.style.width === "") {
      searchInput.focus();



      // Utilisation de requestAnimationFrame pour gérer les transitions
      requestAnimationFrame(() => {
        searchInput.style.width = "auto";
        searchInput.style.padding = "0.25em 0.5em 0.25em 2.5em";
        const finalWidth = searchInput.getBoundingClientRect().width + "px";
        searchInput.style.padding = "0.25em 0em 0.25em 1em";
        searchInput.style.width = "0px"; // Réinitialisation

        requestAnimationFrame(() => {
          searchInput.style.transition = "width 1s ease-in-out, padding 1s ease-in-out";
          searchInput.style.padding = "0.25em 0.5em 0.25em 2.5em";
          searchInput.style.width = finalWidth;

          // Afficher les boutons après l'animation de l'ouverture du champ
          setTimeout(() => {
            buttons.style.opacity = "1"; // Affiche les boutons après l'animation
            buttons.style.marginLeft = `calc(${finalWidth} - 27px)`;


            if (section === "interests") {
              xMark.style.opacity = "1";
              reset.style.opacity = "1";
            }
          }, 500); // Durée de l'animation
        });
      });
    } else {
      // Fermer le champ et réinitialiser la position des boutons
      searchInput.value = "";
      searchInput.style.width = "0px";
      searchInput.style.padding = "0.25em 0em 0.25em 1em";
      buttons.style.transition = "opacity 1s ease-in-out";
      buttons.style.opacity = "0"; // Masque les boutons

      if (section === "interests") {
        xMark.style.opacity = "0";
        reset.style.opacity = "0";
      }
    }
  }


  normalizeText(text) {
    return text
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/·/g, "")
      .toUpperCase();
  }

  filterList(event) {
    this.deleteUnchecked();

    let input,
      filter,
      ul,
      i,
      txtValue,
      atLeastOneVisible = false,
      span,
      sectionName;

    const spanElement = event.target.parentElement.querySelector("span");

    if (!spanElement) {
      console.error("Impossible de trouver l'élément span ou son dataset.");
      return;
    }

    sectionName = spanElement.dataset.searchInputValue;

    if (!sectionName) {
      console.error("Le dataset 'searchInputValue' est manquant.");
      return;
    }

    input = this[`${sectionName}InputTarget`];
    filter = this.normalizeText(input.value);
    ul = document.querySelector(`.gift_${sectionName}`);
    span = ul?.getElementsByTagName("span");

    if (!span) {
      console.error("Impossible de trouver les éléments span pour la liste.");
      return;
    }

    for (i = 0; i < span.length; i++) {
      txtValue = span[i].textContent || span[i].innerText;
      if (this.normalizeText(txtValue).indexOf(filter) > -1) {
        span[i].style.display = ""; // Afficher l'élément
        atLeastOneVisible = true;
      } else {
        span[i].style.display = "none"; // Masquer l'élément
      }
    }

    if (sectionName === "interests" && !atLeastOneVisible) {
      this.addIfNeeded(input.value);
    }
  }

  addIfNeeded(input) {
    const search = input.charAt(0).toUpperCase() + input.slice(1);
    const searchLower = search.toLowerCase().replace(/\s/g, "");
    const div = document.querySelector("div.gift_interests");
    const checkboxes = Array.from(
      document.querySelectorAll("span[class='checkbox']")
    );
    const lastElement = checkboxes[checkboxes.length - 1];

    const content = `
          <input class="check_boxes optional tempGift" type="checkbox" value="${search}" name="gift[interests][]" id="gift_interests_${searchLower}">
          <label class="collection_check_boxes" for="gift_interests_${searchLower}" id="new-gift-${searchLower}">
            <i class="fa-solid fa-square-plus"></i>
            ${search}
          </label>
        `;

    const newCheckboxes = document.querySelectorAll(
      ".interests span[class='tempGift'] input[type='checkbox']:not(:checked)"
    );

    if (newCheckboxes.length > 0) {
      lastElement.innerHTML = content;
      lastElement.style.display = "";
    } else {
      const span = document.createElement("span");
      span.classList.add("checkbox");
      div.appendChild(span);
      span.innerHTML = content;
    }
  }

  empty() {
    this.interestsInputTarget.value = "";
    this.interestsInputTarget.focus();
    this.filterList({ target: this.interestsInputTarget }); // Passer directement l'input

    // Rendre tous les éléments `span` visibles
    const spans = document.querySelectorAll(".gift_interests span.checkbox");
    spans.forEach(span => {
        span.style.display = ""; // Réinitialiser le display
    });
  }

  reset() {
    const checkboxes = document.querySelectorAll(
      ".interests input[type='checkbox']:checked"
    );
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false;
    });
    if (document.querySelectorAll("[id^='new-gift-']")) {
      const newGifts = document.querySelectorAll("[id^='new-gift-']");
      newGifts.forEach((newGift) => {
        newGift.parentElement.remove();
      });
    }

    // Rendre tous les éléments `span` visibles
    const spans = document.querySelectorAll(".gift_interests span.checkbox");
    spans.forEach(span => {
        span.style.display = ""; // Réinitialiser le display
    });

    this.empty();
  }

  deleteUnchecked() {
    const checkboxes = document.querySelectorAll(
      ".interests input[type='checkbox']:not(:checked)"
    );
    checkboxes.forEach((checkbox) => {
      if (checkbox.classList.contains("tempGift")) {
        checkbox.parentElement.remove();
      }
    });
  }
}
