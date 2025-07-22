// CSS Bundle Size Analyzer
// This script analyzes CSS files to identify unused styles and optimize bundle size

const fs = require('fs');
const path = require('path');
const glob = require('glob');

// Configuration
const cssDir = 'app/assets/tailwind';
const componentsDir = 'app/components';
const viewsDir = 'app/views';
const outputFile = 'css-analysis-report.md';

// Find all CSS files
const cssFiles = glob.sync(`${cssDir}/**/*.css`);
console.log(`Found ${cssFiles.length} CSS files to analyze`);

// Find all template files that might use CSS classes
const templateFiles = [
  ...glob.sync(`${componentsDir}/**/*.html.erb`),
  ...glob.sync(`${viewsDir}/**/*.html.erb`)
];
console.log(`Found ${templateFiles.length} template files to check for CSS usage`);

// Extract CSS classes from CSS files
function extractCssClasses(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const classRegex = /\.([a-zA-Z0-9_-]+)(?:\s*[,{])/g;
  const classes = [];
  let match;
  
  while ((match = classRegex.exec(content)) !== null) {
    classes.push(match[1]);
  }
  
  return classes;
}

// Extract CSS classes used in template files
function extractUsedClasses(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  
  // Look for class="..." patterns
  const classAttributeRegex = /class=["']([^"']+)["']/g;
  const usedClasses = new Set();
  let match;
  
  while ((match = classAttributeRegex.exec(content)) !== null) {
    const classNames = match[1].split(/\s+/);
    classNames.forEach(className => {
      if (className) usedClasses.add(className);
    });
  }
  
  return Array.from(usedClasses);
}

// Analyze CSS files
let allCssClasses = [];
let cssFileSizes = {};
let totalCssSize = 0;

cssFiles.forEach(file => {
  const stats = fs.statSync(file);
  const fileSizeKB = stats.size / 1024;
  totalCssSize += stats.size;
  cssFileSizes[file] = fileSizeKB.toFixed(2);
  
  const classes = extractCssClasses(file);
  allCssClasses = [...allCssClasses, ...classes];
  console.log(`Extracted ${classes.length} CSS classes from ${file}`);
});

// Deduplicate CSS classes
const uniqueCssClasses = [...new Set(allCssClasses)];
console.log(`Found ${uniqueCssClasses.length} unique CSS classes across all files`);

// Find used classes in templates
let allUsedClasses = [];
templateFiles.forEach(file => {
  const usedClasses = extractUsedClasses(file);
  allUsedClasses = [...allUsedClasses, ...usedClasses];
});

// Deduplicate used classes
const uniqueUsedClasses = [...new Set(allUsedClasses)];
console.log(`Found ${uniqueUsedClasses.length} unique CSS classes used in templates`);

// Find unused classes
const unusedClasses = uniqueCssClasses.filter(cls => !uniqueUsedClasses.includes(cls));
console.log(`Found ${unusedClasses.length} potentially unused CSS classes`);

// Generate report
const report = `# CSS Bundle Analysis Report

## Summary
- Total CSS Size: ${(totalCssSize / 1024).toFixed(2)} KB
- Total CSS Files: ${cssFiles.length}
- Total Unique CSS Classes: ${uniqueCssClasses.length}
- Total Used CSS Classes: ${uniqueUsedClasses.length}
- Total Potentially Unused CSS Classes: ${unusedClasses.length}
- Potential Savings: ~${((unusedClasses.length / uniqueCssClasses.length) * 100).toFixed(2)}% of CSS bundle

## CSS File Sizes
${Object.entries(cssFileSizes)
  .sort((a, b) => parseFloat(b[1]) - parseFloat(a[1]))
  .map(([file, size]) => `- ${file}: ${size} KB`)
  .join('\n')}

## Top 20 Potentially Unused CSS Classes
${unusedClasses.slice(0, 20).map(cls => `- \`.${cls}\``).join('\n')}

## Recommendations
1. Consider removing unused CSS classes to reduce bundle size
2. Consolidate duplicate styles across files
3. Use CSS variables for consistent theming
4. Implement lazy loading for non-critical CSS
5. Consider using PurgeCSS to automatically remove unused styles

*Note: This analysis is based on static class name extraction and may not catch dynamically generated class names or classes used in JavaScript.*
`;

fs.writeFileSync(outputFile, report);
console.log(`Report written to ${outputFile}`);