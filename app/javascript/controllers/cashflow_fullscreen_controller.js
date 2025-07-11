import { Controller } from "@hotwired/stimulus";
import { sankey, sankeyLinkHorizontal } from "d3-sankey";
import { select } from "d3-selection";
import { scaleOrdinal } from "d3-scale";
import { format } from "d3-format";

// Connects to data-controller="cashflow-fullscreen"
export default class extends Controller {
  static targets = ["dialog", "fullscreenChart", "periodLabel"];
  static values = { 
    sankeyData: Object, 
    currencySymbol: String, 
    period: String 
  };

  connect() {
    // Ensure dialog is hidden on load
    if (this.hasDialogTarget) {
      this.dialogTarget.style.display = 'none';
    }
  }

  open() {
    if (!this.hasSankeyDataValue || !this.sankeyDataValue.links || this.sankeyDataValue.links.length === 0) {
      console.warn("No sankey data available for fullscreen view");
      return;
    }

    // Set period label
    if (this.hasPeriodLabelTarget) {
      this.periodLabelTarget.textContent = this.periodValue;
    }

    // Show dialog
    this.dialogTarget.style.display = 'flex';
    document.body.style.overflow = 'hidden';

    // Render chart in fullscreen with a small delay to ensure dialog is fully rendered
    setTimeout(() => {
      this.renderFullscreenChart();
    }, 100);
  }

  close() {
    this.dialogTarget.style.display = 'none';
    document.body.style.overflow = '';
  }

  renderFullscreenChart() {
    const container = this.fullscreenChartTarget;
    container.innerHTML = ''; // Clear any existing content

    const containerRect = container.getBoundingClientRect();
    const margin = { top: 20, right: 40, bottom: 20, left: 40 };
    const width = containerRect.width - margin.left - margin.right;
    const height = containerRect.height - margin.top - margin.bottom;

    if (width <= 0 || height <= 0) {
      console.warn("Invalid container dimensions for fullscreen chart");
      return;
    }

    const svg = select(container)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom);

    const g = svg.append("g")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    // Create sankey generator
    const sankeyGenerator = sankey()
      .nodeWidth(20)
      .nodePadding(15)
      .extent([[1, 1], [width - 1, height - 1]]);

    // Process data
    const data = this.sankeyDataValue;
    const graph = sankeyGenerator(data);

    // Color scale
    const color = scaleOrdinal()
      .domain(graph.nodes.map(d => d.name))
      .range(["#3b82f6", "#ef4444", "#10b981", "#f59e0b", "#8b5cf6", "#f97316", "#06b6d4", "#84cc16"]);

    // Format numbers
    const formatNumber = format(",.0f");
    const currencySymbol = this.currencySymbolValue || "$";

    // Add links
    g.append("g")
      .selectAll("path")
      .data(graph.links)
      .join("path")
      .attr("d", sankeyLinkHorizontal())
      .attr("stroke", d => color(d.source.name))
      .attr("stroke-width", d => Math.max(1, d.width))
      .attr("fill", "none")
      .attr("opacity", 0.6)
      .on("mouseover", function(event, d) {
        select(this).attr("opacity", 0.8);
      })
      .on("mouseout", function(event, d) {
        select(this).attr("opacity", 0.6);
      })
      .append("title")
      .text(d => `${d.source.name} → ${d.target.name}\n${currencySymbol}${formatNumber(d.value)}`);

    // Add nodes
    const node = g.append("g")
      .selectAll("g")
      .data(graph.nodes)
      .join("g");

    node.append("rect")
      .attr("x", d => d.x0)
      .attr("y", d => d.y0)
      .attr("height", d => d.y1 - d.y0)
      .attr("width", d => d.x1 - d.x0)
      .attr("fill", d => color(d.name))
      .attr("opacity", 0.8)
      .attr("rx", 3)
      .append("title")
      .text(d => `${d.name}\n${currencySymbol}${formatNumber(d.value)}`);

    // Add node labels
    node.append("text")
      .attr("x", d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
      .attr("y", d => (d.y1 + d.y0) / 2)
      .attr("dy", "0.35em")
      .attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
      .style("font-size", "14px")
      .style("font-weight", "500")
      .style("fill", "#374151")
      .text(d => d.name);

    // Add value labels
    node.append("text")
      .attr("x", d => d.x0 < width / 2 ? d.x1 + 6 : d.x0 - 6)
      .attr("y", d => (d.y1 + d.y0) / 2)
      .attr("dy", "1.5em")
      .attr("text-anchor", d => d.x0 < width / 2 ? "start" : "end")
      .style("font-size", "12px")
      .style("fill", "#6b7280")
      .text(d => `${currencySymbol}${formatNumber(d.value)}`);
  }
}
