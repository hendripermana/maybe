import { Controller } from "@hotwired/stimulus";
import * as d3 from "d3";
import { sankey, sankeyLinkHorizontal } from "d3-sankey";

// Connects to data-controller="sankey-chart"
export default class extends Controller {
  static values = {
    data: Object,
    nodeWidth: { type: Number, default: 15 },
    nodePadding: { type: Number, default: 25 },
    currencySymbol: { type: String, default: "$" }
  };

  connect() {
    console.log("🔥 Sankey chart controller connected!");
    console.log("📊 Data value:", this.dataValue);
    console.log("💱 Currency:", this.currencySymbolValue);
    
    // Prevent multiple instances rendering at the same time
    if (this.isDrawing) {
      console.log("⏳ Chart already drawing, skipping...");
      return;
    }
    
    this.resizeObserver = new ResizeObserver(() => {
      // Debounce resize events
      clearTimeout(this.resizeTimeout);
      this.resizeTimeout = setTimeout(() => this.#draw(), 100);
    });
    this.resizeObserver.observe(this.element);
    
    // Small delay to ensure element is properly sized
    setTimeout(() => this.#draw(), 50);
  }

  showLoading() {
    const loadingElement = document.getElementById('sankey-loading');
    if (loadingElement) {
      loadingElement.style.display = 'flex';
    }
  }

  hideLoading() {
    const loadingElement = document.getElementById('sankey-loading');
    if (loadingElement) {
      loadingElement.style.display = 'none';
    }
  }

  disconnect() {
    clearTimeout(this.resizeTimeout);
    this.resizeObserver?.disconnect();
    this.isDrawing = false;
  }

  // Public method for fullscreen controller to trigger redraw
  redraw() {
    // Small delay to ensure container sizing is updated
    setTimeout(() => this.#draw(), 100);
  }

  // Public method for AJAX filter updates
  updateData(newData) {
    this.dataValue = newData;
    this.redraw();
  }

  #draw() {
    if (this.isDrawing) {
      console.log("⏳ Already drawing, skipping duplicate call");
      return;
    }
    
    this.isDrawing = true;
    console.log("🎨 Drawing sankey chart...");
    
    const { nodes = [], links = [] } = this.dataValue || {};
    console.log("📈 Nodes:", nodes.length, "Links:", links.length);

    if (!nodes.length || !links.length) {
      console.log("❌ No data available for sankey chart");
      this.hideLoading();
      this.isDrawing = false;
      return;
    }

    // Clear previous SVG
    d3.select(this.element).selectAll("svg").remove();

    // Get actual dimensions, ensuring it fills the container properly like a magical creature
    const containerRect = this.element.getBoundingClientRect();
    
    // Use the FULL available space from the container - be the shape of the container
    const availableWidth = this.element.offsetWidth || containerRect.width || 600;
    const availableHeight = this.element.offsetHeight || containerRect.height || 540;
    
    // Chart should be exactly the size of its container (like the magical creature)
    const width = availableWidth;
    const height = availableHeight;
    
    console.log("📏 Chart dimensions (creature size):", width, "x", height);
    console.log("📦 Container dimensions (room size):", availableWidth, "x", availableHeight);

    // Minimal margins to maximize chart area - creature fills almost the entire space
    const margin = { 
      top: 20,
      right: 60, 
      bottom: 20, 
      left: 60 
    };
    
    // Calculate the actual drawing area
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;
    
    console.log("📐 Margins (minimal):", margin);
    console.log("📏 Inner dimensions (creature body):", innerWidth, "x", innerHeight);

    const svg = d3
      .select(this.element)
      .append("svg")
      .attr("viewBox", `0 0 ${width} ${height}`)
      .attr("preserveAspectRatio", "xMidYMid meet")
      .style("background", "transparent")
      .style("overflow", "visible")
      .style("width", "100%")
      .style("height", "100%")
      .style("max-width", "none")
      .style("max-height", "none");

    const sankeyGenerator = sankey()
      .nodeWidth(this.nodeWidthValue)
      .nodePadding(this.nodePaddingValue)
      .extent([
        [margin.left, margin.top],
        [margin.left + innerWidth, margin.top + innerHeight],
      ]);

    const sankeyData = sankeyGenerator({
      nodes: nodes.map((d) => Object.assign({}, d)),
      links: links.map((d) => Object.assign({}, d)),
    });

    console.log("✅ Sankey data processed, rendering...");

    // Hide loading once we start rendering
    this.hideLoading();

    // Define gradients for links
    const defs = svg.append("defs");

    sankeyData.links.forEach((link, i) => {
      const gradientId = `link-gradient-${link.source.index}-${link.target.index}-${i}`;

      const getStopColorWithOpacity = (nodeColorInput, opacity = 0.1) => {
        let colorStr = nodeColorInput || "var(--color-gray-400)";
        if (colorStr === "var(--color-success)") {
          colorStr = "#10A861"; // Hex for --color-green-600
        }
        // Add other CSS var to hex mappings here if needed

        if (colorStr.startsWith("var(--")) { // Unmapped CSS var, use as is (likely solid)
          return colorStr;
        }

        const d3Color = d3.color(colorStr);
        return d3Color ? d3Color.copy({ opacity: opacity }) : "var(--color-gray-400)";
      };

      const sourceStopColor = getStopColorWithOpacity(link.source.color);
      const targetStopColor = getStopColorWithOpacity(link.target.color);

      const gradient = defs.append("linearGradient")
        .attr("id", gradientId)
        .attr("gradientUnits", "userSpaceOnUse")
        .attr("x1", link.source.x1)
        .attr("x2", link.target.x0);

      gradient.append("stop")
        .attr("offset", "0%")
        .attr("stop-color", sourceStopColor);

      gradient.append("stop")
        .attr("offset", "100%")
        .attr("stop-color", targetStopColor);
    });

    // Draw links - Clean approach with enhanced hover effects
    const linkElements = svg
      .append("g")
      .attr("fill", "none")
      .selectAll("path")
      .data(sankeyData.links)
      .join("path")
      .attr("d", sankeyLinkHorizontal())
      .attr("stroke", (d, i) => `url(#link-gradient-${d.source.index}-${d.target.index}-${i})`)
      .attr("stroke-width", (d) => Math.max(1, d.width))
      .style("cursor", "pointer")
      .style("opacity", 0.7) // Start visible instead of 0
      .on("mouseenter", function(event, d) {
        // Highlight this link
        d3.select(this)
          .transition()
          .duration(150) // Faster animation
          .style("opacity", 1)
          .attr("stroke-width", (d) => Math.max(2, d.width * 1.1));
        
        // Dim other links
        linkElements.filter(link => link !== d)
          .transition()
          .duration(150)
          .style("opacity", 0.3);
      })
      .on("mouseleave", function(event, d) {
        // Reset all links
        linkElements
          .transition()
          .duration(200) // Faster reset
          .style("opacity", 0.7) // Back to default visible state
          .attr("stroke-width", (d) => Math.max(1, d.width));
      })
      .append("title")
      .text((d) => `${nodes[d.source.index].name} → ${nodes[d.target.index].name}: ${this.currencySymbolValue}${Number.parseFloat(d.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })} (${d.percentage}%)`);

    // Animate links appearing - faster animation
    linkElements
      .transition()
      .duration(600) // Faster from 1000ms
      .delay((d, i) => i * 25) // Faster stagger from 50ms
      .style("opacity", 0.7); // End at visible state

    // Draw nodes
    const node = svg
      .append("g")
      .selectAll("g")
      .data(sankeyData.nodes)
      .join("g");

    const cornerRadius = 8;

    const nodeRects = node.append("path")
      .attr("d", (d) => {
        const x0 = d.x0;
        const y0 = d.y0;
        const x1 = d.x1;
        const y1 = d.y1;
        const h = y1 - y0;
        // const w = x1 - x0; // Not directly used in path string, but good for context

        // Dynamic corner radius based on node height, maxed at 8
        const effectiveCornerRadius = Math.max(0, Math.min(cornerRadius, h / 2));

        const isSourceNode = d.sourceLinks && d.sourceLinks.length > 0 && (!d.targetLinks || d.targetLinks.length === 0);
        const isTargetNode = d.targetLinks && d.targetLinks.length > 0 && (!d.sourceLinks || d.sourceLinks.length === 0);

        if (isSourceNode) { // Round left corners, flat right for "Total Income"
          if (h < effectiveCornerRadius * 2) {
            return `M ${x0},${y0} L ${x1},${y0} L ${x1},${y1} L ${x0},${y1} Z`;
          }
          return `M ${x0 + effectiveCornerRadius},${y0}
                  L ${x1},${y0}
                  L ${x1},${y1}
                  L ${x0 + effectiveCornerRadius},${y1}
                  Q ${x0},${y1} ${x0},${y1 - effectiveCornerRadius}
                  L ${x0},${y0 + effectiveCornerRadius}
                  Q ${x0},${y0} ${x0 + effectiveCornerRadius},${y0} Z`;
        }

        if (isTargetNode) { // Flat left corners, round right for Categories/Surplus
          if (h < effectiveCornerRadius * 2) {
            return `M ${x0},${y0} L ${x1},${y0} L ${x1},${y1} L ${x0},${y1} Z`;
          }
          return `M ${x0},${y0}
                  L ${x1 - effectiveCornerRadius},${y0}
                  Q ${x1},${y0} ${x1},${y0 + effectiveCornerRadius}
                  L ${x1},${y1 - effectiveCornerRadius}
                  Q ${x1},${y1} ${x1 - effectiveCornerRadius},${y1}
                  L ${x0},${y1} Z`;
        }

        // Fallback for intermediate nodes (e.g., "Cash Flow") - draw as a simple sharp-cornered rectangle
        return `M ${x0},${y0} L ${x1},${y0} L ${x1},${y1} L ${x0},${y1} Z`;
      })
      .attr("fill", (d) => d.color || "var(--color-gray-400)")
      .attr("stroke", "none")
      .style("cursor", "pointer")
      .style("opacity", 0)
      .style("transform", "scale(0.8)")
      .on("mouseenter", function(event, d) {
        d3.select(this)
          .transition()
          .duration(200)
          .style("opacity", 1)
          .style("transform", "scale(1.05)")
          .attr("filter", "drop-shadow(0 4px 8px rgba(0,0,0,0.1))");
      })
      .on("mouseleave", function(event, d) {
        d3.select(this)
          .transition()
          .duration(200)
          .style("opacity", 0.9)
          .style("transform", "scale(1)")
          .attr("filter", "none");
      });

    // Animate nodes appearing - faster animation
    nodeRects
      .transition()
      .duration(500) // Faster from 800ms
      .delay((d, i) => i * 50) // Faster stagger from 100ms
      .style("opacity", 0.9)
      .style("transform", "scale(1)");

    const stimulusControllerInstance = this;
    const nodeLabels = node
      .append("text")
      .attr("x", (d) => (d.x0 < width / 2 ? d.x1 + 8 : d.x0 - 8))
      .attr("y", (d) => (d.y1 + d.y0) / 2)
      .attr("dy", "0.35em")
      .attr("text-anchor", (d) => (d.x0 < width / 2 ? "start" : "end"))
      .attr("class", "text-xs font-medium text-primary fill-current")
      .style("user-select", "none")
      .style("pointer-events", "none")
      .style("opacity", 0)
      .each(function (d) {
        const textElement = d3.select(this);
        textElement.selectAll("tspan").remove();

        // Node Name on the first line
        textElement.append("tspan")
          .text(d.name)
          .attr("font-size", "12px");

        // Financial details on the second line
        const financialDetailsTspan = textElement.append("tspan")
          .attr("x", textElement.attr("x"))
          .attr("dy", "1.4em")
          .attr("class", "font-mono text-secondary")
          .attr("font-size", "10px");

        financialDetailsTspan.append("tspan")
          .text(stimulusControllerInstance.currencySymbolValue + Number.parseFloat(d.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
      });

    // Animate labels appearing - faster animation
    nodeLabels
      .transition()
      .duration(400) // Faster from 600ms
      .delay((d, i) => 200 + i * 50) // Start earlier and faster stagger
      .style("opacity", 1);

    console.log("🎉 Sankey chart rendered successfully!");
    this.isDrawing = false; // Reset flag when done
  }
} 