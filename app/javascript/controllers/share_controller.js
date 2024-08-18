import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="share"
export default class extends Controller {
  static values = {
    url: String,
  };

  share(event) {
    event.preventDefault();
    const url = this.urlValue;

    if (navigator.share) {
      this.shareMenu(url);
    } else if (navigator.clipboard) {
      this.copyUrlToClipboard(url);
    }
  }

  async shareMenu(url) {
    try {
      await navigator.share({
        title: "Partager",
        text: "Partagez cet évènement !",
        url: url,
      });
    } catch (error) {
      console.error("Le partage a échoué:", error);
    }
  }

  async copyUrlToClipboard(url) {
    try {
      await navigator.clipboard.writeText(url);
      alert("Lien copié dans le presse-papiers");
    } catch (error) {
      console.error("Échec de la copie du lien:", error);
      alert("Impossible de copier le lien. Veuillez essayer manuellement.");
    }
  }
}
