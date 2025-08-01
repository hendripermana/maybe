import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  start = async (event) => {
    event.preventDefault();
    const response = await fetch("/brankas/link_url");
    const { url } = await response.json();
    window.location.href = url;
  };

  connect() {
    this.element.addEventListener("click", this.start);
  }
  disconnect() {
    this.element.removeEventListener("click", this.start);
  }
}
