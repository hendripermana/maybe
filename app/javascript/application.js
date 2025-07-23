// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import UiMonitoringService from "services/ui_monitoring_service";

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};

// Initialize UI monitoring service
document.addEventListener("turbo:load", () => {
  UiMonitoringService.init();
});
