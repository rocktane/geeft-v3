import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["saveList", "gift"];

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
    let env = this.saveListTarget.dataset.env || "";

    // If the environment is not defined, we set it to development
    if (env === "development") {
      env = "http://localhost:3000";
    } else {
      env = "https://www.geeft.club";
    }

    const url = `${env}/updatelist/${giftId}`;
    const origin = window.location.href;
    let redirection;

    // if (origin.includes("events")) {
    //   const regex = /events\/(\d+)\/gifts/;
    //   const eventId = url.match(regex)[1];
    //   redirection = `${env}/events/${eventId}`;
    // } else {
    //   redirection = `${env}/gifts/${giftId}/events/new`;
    // }

    const newList = this.newList();

    console.log(newList);
    // console.log(redirection);

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
        const errorData = await response.json();
        console.error("Error data:", errorData);
        throw new Error("Network response was not ok");
      }

      // window.setTimeout(() => {
      //   window.location.href = redirection;
      // }, 500);

      const redirect_url = `${env}/redirect/${giftId}`;

      fetch(redirect_url, {
        method: "PATCH",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
      });
    } catch (error) {
      console.error("Une erreur s'est produite : ", error);
    }
  }
}
