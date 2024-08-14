import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  redirectToShow(event) {
    event.preventDefault();

    const form = this.element.closest('form');
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
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    }).then(response => {
      if (response.ok) {
        window.location.href = `/users/${userId}`;
      } else {
        response.text().then(html => {
          document.body.innerHTML = html;
        });
      }
    });
  }
}
