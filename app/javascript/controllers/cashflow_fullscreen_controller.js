import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="cashflow-fullscreen"
export default class extends Controller {
  static targets = ["dialog", "fullscreenChart", "periodLabel"];
  static params = ["sankeyData", "currencySymbol", "period"];

  open() {
    // Set period label
    this.periodLabelTarget.textContent = this.periodParam;

    // Get the fullscreen chart element
    const chartElement = this.fullscreenChartTarget;
    
    // Set up the Sankey chart data
    chartElement.setAttribute("data-sankey-chart-data-value", this.sankeyDataParam);
    chartElement.setAttribute("data-sankey-chart-currency-symbol-value", this.currencySymbolParam);

    // Open the dialog first
    this.dialogTarget.showModal();

    // Force the Stimulus controller to connect and render after dialog is shown
    setTimeout(() => {
      // Manually trigger a connection event on the chart element
      const event = new CustomEvent('stimulus:connect', { 
        bubbles: true, 
        cancelable: true 
      });
      chartElement.dispatchEvent(event);
      
      // Also trigger a resize to ensure proper sizing
      window.dispatchEvent(new Event("resize"));
    }, 150);
  }

  close() {
    this.dialogTarget.close();
  }

  // Handle ESC key and dialog backdrop clicks
  dialogClick(event) {
    if (event.target === this.dialogTarget) {
      this.close();
    }
  }

  connect() {
    // Bind the dialog click handler
    if (this.hasDialogTarget) {
      this.dialogTarget.addEventListener("click", this.dialogClick.bind(this));
    }
  }

  disconnect() {
    // Clean up event listeners
    if (this.hasDialogTarget) {
      this.dialogTarget.removeEventListener("click", this.dialogClick.bind(this));
    }
  }
}
