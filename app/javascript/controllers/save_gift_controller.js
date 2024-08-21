import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["saveList", "gift"];
  static values = { url: String };

  connect() {}

  newList() {
    // Recover the 5 gifts displayed
    const old_list = this.giftTargets.slice(0, 5);
    let new_list = [];
    old_list.forEach((gift) => {
      new_list.push(gift.firstChild.nodeValue.trim());
    });
    return new_list;
  }

  async save(event) {
    event.preventDefault();

    const giftId = this.saveListTarget.dataset.giftId || "";
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const env = this.urlValue || "";
    const url = `${env}/updatelist/${giftId}`;

    const newList = this.newList();

    console.log(newList);

    try {
      const response = await fetch(url, {
        method: "PATCH",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
        body: JSON.stringify({ generated_list: newList }),
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const data = await response.json();

      if (data.success) {
        window.location.href = `/gifts/${data.id}`;
      } else {
        console.error("Update failed:", data.errors);
      }
    } catch (error) {
      console.error("Une erreur s'est produite : ", error);
    }
  }
}
