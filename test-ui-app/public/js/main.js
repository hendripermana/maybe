/**
 * Main JavaScript file
 * Handles theme switching and chart functionality
 * Based on the completed tasks for UI/UX modernization
 */

document.addEventListener('DOMContentLoaded', function() {
  // Theme switching functionality
  setupThemeSwitching();
  
  // Initialize charts if they exist on the page
  initializeCharts();
  
  // Set up fullscreen functionality for charts
  setupChartFullscreen();
});

/**
 * Sets up theme switching functionality
 * Based on task #2: Establish CSS variable system for theme consistency
 */
function setupThemeSwitching() {
  const themeToggleForm = document.getElementById('theme-toggle-form');
  
  if (themeToggleForm) {
    themeToggleForm.addEventListener('submit', function(e) {
      // Form submission is handled by the server
      // This is just for visual feedback before the page reloads
      const currentTheme = document.documentElement.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', newTheme);
    });
  }
}

/**
 * Initializes charts on the dashboard
 * Part of task #9: Optimize dashboard chart containers and responsiveness
 */
function initializeCharts() {
  // Check if we're on the dashboard page and if D3.js is loaded
  const sankeyChart = document.getElementById('sankey-chart');
  if (!sankeyChart || !window.d3) return;
  
  // This is a simplified version of a Sankey chart for demonstration
  // In a real implementation, this would use actual financial data
  const width = sankeyChart.clientWidth;
  const height = sankeyChart.clientHeight || 400;
  
  const svg = d3.select('#sankey-chart')
    .append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('transform', 'translate(20, 20)');
  
  // Sample data for Sankey diagram
  const nodes = [
    { name: 'Income' },
    { name: 'Expenses' },
    { name: 'Savings' },
    { name: 'Housing' },
    { name: 'Food' },
    { name: 'Transport' },
    { name: 'Investment' },
    { name: 'Emergency Fund' }
  ];
  
  const links = [
    { source: 0, target: 1, value: 70 },
    { source: 0, target: 2, value: 30 },
    { source: 1, target: 3, value: 40 },
    { source: 1, target: 4, value: 15 },
    { source: 1, target: 5, value: 15 },
    { source: 2, target: 6, value: 20 },
    { source: 2, target: 7, value: 10 }
  ];
  
  // Create Sankey generator
  const sankey = d3.sankey()
    .nodeWidth(15)
    .nodePadding(10)
    .size([width - 40, height - 40]);
  
  // Generate the Sankey diagram
  const graph = sankey({
    nodes: nodes.map(d => Object.assign({}, d)),
    links: links.map(d => Object.assign({}, d))
  });
  
  // Add links
  svg.append('g')
    .selectAll('path')
    .data(graph.links)
    .enter()
    .append('path')
    .attr('d', d3.sankeyLinkHorizontal())
    .attr('class', 'link')
    .style('stroke', function(d) {
      // Use theme-aware colors
      return d.source.name === 'Income' ? 'var(--color-primary)' : 'var(--color-muted)';
    })
    .style('stroke-width', d => Math.max(1, d.width));
  
  // Add nodes
  const node = svg.append('g')
    .selectAll('.node')
    .data(graph.nodes)
    .enter()
    .append('g')
    .attr('class', 'node')
    .attr('transform', d => `translate(${d.x0}, ${d.y0})`);
  
  // Add node rectangles
  node.append('rect')
    .attr('height', d => d.y1 - d.y0)
    .attr('width', d => d.x1 - d.x0)
    .style('fill', function(d) {
      // Use theme-aware colors
      if (d.name === 'Income') return 'var(--color-success)';
      if (d.name === 'Expenses') return 'var(--color-destructive)';
      if (d.name === 'Savings') return 'var(--color-primary)';
      return 'var(--color-secondary)';
    });
  
  // Add node labels
  node.append('text')
    .attr('x', d => d.x0 < width / 2 ? 6 + (d.x1 - d.x0) : -6)
    .attr('y', d => (d.y1 - d.y0) / 2)
    .attr('dy', '0.35em')
    .attr('text-anchor', d => d.x0 < width / 2 ? 'start' : 'end')
    .text(d => d.name)
    .style('fill', 'var(--color-foreground)');
}

/**
 * Sets up fullscreen functionality for chart containers
 * Part of task #9: Optimize dashboard chart containers and responsiveness
 */
function setupChartFullscreen() {
  const fullscreenButtons = document.querySelectorAll('.chart-fullscreen-btn');
  
  fullscreenButtons.forEach(button => {
    button.addEventListener('click', function() {
      const chartContainer = this.closest('.chart-container');
      
      if (chartContainer.classList.contains('chart-container-fullscreen')) {
        // Exit fullscreen
        chartContainer.classList.remove('chart-container-fullscreen');
        this.textContent = 'Fullscreen';
        
        // Reinitialize chart to fit the original container
        const chartId = chartContainer.querySelector('.chart-content > div').id;
        document.getElementById(chartId).innerHTML = '';
        initializeCharts();
      } else {
        // Enter fullscreen
        chartContainer.classList.add('chart-container-fullscreen');
        this.textContent = 'Exit Fullscreen';
        
        // Reinitialize chart to fit the fullscreen container
        const chartId = chartContainer.querySelector('.chart-content > div').id;
        document.getElementById(chartId).innerHTML = '';
        setTimeout(initializeCharts, 100); // Small delay to allow the container to resize
      }
    });
  });
}