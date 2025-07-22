// Responsive Viewport Testing Script
// This script helps test the application at different viewport sizes

const viewports = {
  // Mobile viewports
  mobileSm: { width: 320, height: 568, name: 'Small Mobile' },
  mobileMd: { width: 375, height: 667, name: 'Medium Mobile (iPhone SE)' },
  mobileLg: { width: 390, height: 844, name: 'Large Mobile (iPhone 12/13)' },
  
  // Tablet viewports
  tabletSm: { width: 768, height: 1024, name: 'Small Tablet (iPad Mini)' },
  tabletLg: { width: 820, height: 1180, name: 'Large Tablet (iPad Air)' },
  
  // Desktop viewports
  desktopSm: { width: 1280, height: 800, name: 'Small Desktop' },
  desktopMd: { width: 1920, height: 1080, name: 'Medium Desktop' },
  desktopLg: { width: 2560, height: 1440, name: 'Large Desktop' }
};

// Pages to test
const pages = [
  { path: '/', name: 'Dashboard' },
  { path: '/transactions', name: 'Transactions' },
  { path: '/budgets', name: 'Budgets' },
  { path: '/settings', name: 'Settings' }
];

// Elements to check on each page
const elementsToCheck = {
  dashboard: [
    { selector: 'header', description: 'Header' },
    { selector: '.dashboard-grid', description: 'Dashboard Grid' },
    { selector: '.chart-container', description: 'Chart Container' }
  ],
  transactions: [
    { selector: 'header', description: 'Header' },
    { selector: '.transaction-list', description: 'Transaction List' },
    { selector: '.transaction-filters', description: 'Transaction Filters' }
  ],
  budgets: [
    { selector: 'header', description: 'Header' },
    { selector: '.budget-categories', description: 'Budget Categories' },
    { selector: '.progress-bar', description: 'Progress Bars' }
  ],
  settings: [
    { selector: 'header', description: 'Header' },
    { selector: '.settings-navigation', description: 'Settings Navigation' },
    { selector: '.settings-form', description: 'Settings Form' }
  ]
};

// Test function to check viewport responsiveness
function testViewportResponsiveness(viewport, page) {
  describe(`${page.name} at ${viewport.name} (${viewport.width}x${viewport.height})`, () => {
    beforeEach(() => {
      // Set viewport size
      window.resizeTo(viewport.width, viewport.height);
      // Navigate to page
      window.location.href = page.path;
    });
    
    // Get the appropriate elements to check based on the page
    const pageKey = page.name.toLowerCase();
    const elements = elementsToCheck[pageKey] || [];
    
    // Test each element
    elements.forEach(element => {
      it(`should display ${element.description} correctly`, () => {
        const el = document.querySelector(element.selector);
        expect(el).not.toBeNull();
        expect(el).toBeVisible();
        
        // Check if element is within viewport
        const rect = el.getBoundingClientRect();
        expect(rect.right).toBeLessThanOrEqual(viewport.width);
        
        // For mobile viewports, check minimum touch target size
        if (viewport.width < 640) {
          if (el.tagName === 'BUTTON' || el.tagName === 'A' || el.getAttribute('role') === 'button') {
            const minSize = 44; // Minimum recommended touch target size
            expect(rect.width).toBeGreaterThanOrEqual(minSize);
            expect(rect.height).toBeGreaterThanOrEqual(minSize);
          }
        }
      });
    });
    
    // Test orientation change for mobile and tablet
    if (viewport.width < 1024) {
      it('should handle orientation change', () => {
        // Switch to landscape
        window.resizeTo(viewport.height, viewport.width);
        
        // Check that elements are still visible
        elements.forEach(element => {
          const el = document.querySelector(element.selector);
          expect(el).toBeVisible();
        });
        
        // Check no horizontal scrolling
        expect(document.documentElement.scrollWidth).toBeLessThanOrEqual(viewport.height);
      });
    }
  });
}

// Run tests for each viewport and page combination
Object.values(viewports).forEach(viewport => {
  pages.forEach(page => {
    testViewportResponsiveness(viewport, page);
  });
});

// Export for use in other test files
export { viewports, pages, testViewportResponsiveness };