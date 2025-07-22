# Responsive Design Manual Test Script

## Introduction

This document provides a step-by-step manual testing script to verify that the Maybe finance application works properly across all device sizes. Follow these instructions to test the responsive design implementation.

## Prerequisites

- Access to the following devices or device emulators:
  - Mobile phone (iPhone or Android)
  - Tablet (iPad or Android tablet)
  - Desktop computer
- Latest versions of Chrome, Safari, and Firefox browsers
- Test user account with sample data

## Test Procedure

### 1. Dashboard Page Testing

#### Mobile Device (Portrait)
1. Open the application on a mobile device in portrait orientation
2. Log in with test credentials
3. Verify that:
   - Header is properly sized and contains essential navigation
   - Dashboard cards stack vertically with proper spacing
   - Charts are properly sized and readable
   - No horizontal scrolling is required
   - All interactive elements have adequate touch targets (min 44px)
   - Text is readable without zooming

#### Mobile Device (Landscape)
1. Rotate the device to landscape orientation
2. Verify that:
   - Layout adjusts appropriately to landscape orientation
   - Content is still accessible without scrolling horizontally
   - Charts and cards adapt to the wider viewport
   - Navigation remains accessible

#### Tablet Device
1. Open the application on a tablet
2. Log in with test credentials
3. Verify in both portrait and landscape orientations:
   - Dashboard displays a grid layout appropriate for tablet size
   - Charts utilize available space effectively
   - Navigation is appropriate for tablet size
   - Touch targets are properly sized

#### Desktop Device
1. Open the application on a desktop browser
2. Log in with test credentials
3. Verify that:
   - Dashboard utilizes the full screen width effectively
   - Multi-column layout for cards and charts
   - Hover states work correctly on interactive elements
   - Navigation shows full menu options

### 2. Transactions Page Testing

#### Mobile Device (Portrait)
1. Navigate to the Transactions page
2. Verify that:
   - Transaction list is readable and properly formatted
   - Filters and search are accessible
   - Transaction details can be viewed without horizontal scrolling
   - Touch targets for actions are large enough

#### Mobile Device (Landscape)
1. Rotate the device to landscape orientation
2. Verify that:
   - More transaction information is visible in landscape
   - Filters and actions remain accessible
   - No horizontal scrolling is required

#### Tablet Device
1. Navigate to the Transactions page on a tablet
2. Verify in both portrait and landscape orientations:
   - Transaction list shows appropriate columns for tablet size
   - Filters and search are easily accessible
   - Transaction details display properly

#### Desktop Device
1. Navigate to the Transactions page on desktop
2. Verify that:
   - Full transaction table is visible with all columns
   - Filters and search are easily accessible
   - Hover states work correctly on interactive elements

### 3. Budgets Page Testing

#### Mobile Device (Portrait)
1. Navigate to the Budgets page
2. Verify that:
   - Budget categories stack vertically with proper spacing
   - Progress bars are readable and properly sized
   - Budget forms are usable on small screens
   - Touch targets for actions are large enough

#### Mobile Device (Landscape)
1. Rotate the device to landscape orientation
2. Verify that:
   - Budget layout adjusts appropriately
   - More budget categories are visible if applicable
   - Forms remain usable in landscape orientation

#### Tablet Device
1. Navigate to the Budgets page on a tablet
2. Verify in both portrait and landscape orientations:
   - Budget categories display in an appropriate grid layout
   - Progress bars are properly sized
   - Budget forms utilize space effectively

#### Desktop Device
1. Navigate to the Budgets page on desktop
2. Verify that:
   - Budget categories display in a multi-column grid
   - Progress bars are properly sized
   - Budget forms utilize space effectively
   - Hover states work correctly on interactive elements

### 4. Settings Page Testing

#### Mobile Device (Portrait)
1. Navigate to the Settings page
2. Verify that:
   - Settings categories are accessible via tabs or accordion
   - Form controls are usable on small screens
   - Toggle switches and checkboxes are large enough
   - Theme switcher works properly

#### Mobile Device (Landscape)
1. Rotate the device to landscape orientation
2. Verify that:
   - Settings layout adjusts appropriately
   - Forms remain usable in landscape orientation
   - No content is cut off or requires horizontal scrolling

#### Tablet Device
1. Navigate to the Settings page on a tablet
2. Verify in both portrait and landscape orientations:
   - Settings display in an appropriate layout for tablet
   - Form controls utilize space effectively
   - Toggle switches and checkboxes are properly sized

#### Desktop Device
1. Navigate to the Settings page on desktop
2. Verify that:
   - Settings display in optimal layout with sidebar navigation
   - Form controls utilize space effectively
   - Hover states work correctly on interactive elements

### 5. Touch Interaction Testing

#### Basic Touch Interactions
1. On a mobile device, test the following interactions:
   - Tap buttons and verify they respond properly
   - Tap form fields and verify they activate properly
   - Open and close dropdowns
   - Toggle checkboxes and radio buttons
   - Operate toggle switches

#### Advanced Touch Interactions
1. If implemented, test the following interactions:
   - Swipe gestures (e.g., for navigation or dismissing items)
   - Pinch-to-zoom on charts
   - Drag-and-drop interactions
   - Long-press actions

### 6. Text Scaling Testing

1. On each device, go to the browser settings and increase the font size to 200%
2. Navigate through the application and verify that:
   - Text remains readable
   - Layouts adapt to larger text sizes
   - No content is cut off or overlapping
   - Interactive elements remain usable

### 7. Orientation Change Testing

1. On mobile and tablet devices, test the following:
   - Open each main page (Dashboard, Transactions, Budgets, Settings)
   - Rotate the device between portrait and landscape orientations
   - Verify that the transition is smooth
   - Verify that no content is lost or cut off after rotation
   - Verify that interactive elements remain accessible

## Test Results Documentation

For each test scenario, document the following:

- Pass/Fail status
- Any issues encountered
- Screenshots of issues (if applicable)
- Browser and device information

Use the following format:

```
Test: [Test Name]
Device: [Device Name]
Browser: [Browser Name and Version]
Orientation: [Portrait/Landscape]
Status: [Pass/Fail]
Issues: [Description of any issues]
```

## Conclusion

After completing all tests, summarize the findings and identify any patterns or common issues that need to be addressed. Prioritize issues based on their impact on user experience and the requirements of the UI/UX modernization project.