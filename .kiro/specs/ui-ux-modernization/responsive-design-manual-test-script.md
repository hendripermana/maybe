# Responsive Design Manual Test Script

## Overview

This test script provides step-by-step instructions for manually testing the responsive design of modernized pages across different device sizes and orientations. Follow these instructions to verify that all pages adapt correctly to different viewport sizes and provide a consistent user experience.

## Test Environment Setup

### Required Devices/Emulators
- Desktop computer (1920×1080 or higher resolution)
- Tablet device or emulator (iPad or similar, 768×1024)
- Mobile device or emulator (iPhone or similar, 375×667)

### Browsers to Test
- Chrome (desktop and mobile)
- Safari (desktop and mobile)
- Firefox (desktop)

### Device Orientations
- Portrait (default for mobile and tablet)
- Landscape (rotated mobile and tablet)

## Test Procedure

### 1. Dashboard Page Tests

#### Desktop View (1920×1080)
1. Navigate to the dashboard page
2. Verify that the layout uses the full width of the screen appropriately
3. Verify that charts and cards are arranged in a multi-column grid
4. Verify that all dashboard elements are visible without scrolling (except for intentionally scrollable areas)
5. Toggle between light and dark themes and verify appearance

#### Tablet View (768×1024)
1. Navigate to the dashboard page
2. Verify that the layout adapts to the smaller screen size
3. Verify that charts and cards are arranged in a 2-column grid
4. Verify that all important information is visible without excessive scrolling
5. Rotate to landscape orientation and verify layout adjusts appropriately
6. Toggle between light and dark themes and verify appearance

#### Mobile View (375×667)
1. Navigate to the dashboard page
2. Verify that the layout adapts to the mobile screen size
3. Verify that charts and cards are stacked in a single column
4. Verify that navigation is accessible (hamburger menu or similar)
5. Verify that all content is readable without zooming
6. Rotate to landscape orientation and verify layout adjusts appropriately
7. Toggle between light and dark themes and verify appearance

### 2. Transactions Page Tests

#### Desktop View (1920×1080)
1. Navigate to the transactions page
2. Verify that the transaction list displays with all columns visible
3. Verify that filters and search are easily accessible
4. Verify that pagination controls are visible and functional
5. Click on a transaction and verify details display correctly
6. Toggle between light and dark themes and verify appearance

#### Tablet View (768×1024)
1. Navigate to the transactions page
2. Verify that the transaction list adapts to the smaller screen size
3. Verify that less important columns are hidden or collapsed
4. Verify that filters and search remain accessible
5. Click on a transaction and verify details display correctly
6. Rotate to landscape orientation and verify layout adjusts appropriately
7. Toggle between light and dark themes and verify appearance

#### Mobile View (375×667)
1. Navigate to the transactions page
2. Verify that the transaction list is optimized for mobile viewing
3. Verify that only essential information is shown for each transaction
4. Verify that filters and search are accessible but don't take up too much space
5. Verify that touch targets are large enough (at least 44×44 pixels)
6. Click on a transaction and verify details display correctly
7. Rotate to landscape orientation and verify layout adjusts appropriately
8. Toggle between light and dark themes and verify appearance

### 3. Budgets Page Tests

#### Desktop View (1920×1080)
1. Navigate to the budgets page
2. Verify that budget cards display in a multi-column grid
3. Verify that progress bars and budget information are clearly visible
4. Click on a budget and verify details display correctly
5. Test budget creation/editing functionality
6. Toggle between light and dark themes and verify appearance

#### Tablet View (768×1024)
1. Navigate to the budgets page
2. Verify that budget cards adapt to the smaller screen size
3. Verify that all important budget information remains visible
4. Click on a budget and verify details display correctly
5. Test budget creation/editing functionality
6. Rotate to landscape orientation and verify layout adjusts appropriately
7. Toggle between light and dark themes and verify appearance

#### Mobile View (375×667)
1. Navigate to the budgets page
2. Verify that budget cards stack in a single column
3. Verify that all budget information is readable without zooming
4. Verify that touch targets are large enough
5. Click on a budget and verify details display correctly
6. Test budget creation/editing functionality
7. Rotate to landscape orientation and verify layout adjusts appropriately
8. Toggle between light and dark themes and verify appearance

### 4. Settings Page Tests

#### Desktop View (1920×1080)
1. Navigate to the settings page
2. Verify that settings navigation is displayed on the left side
3. Verify that settings content is displayed on the right side
4. Test various settings controls (toggles, dropdowns, etc.)
5. Verify that theme switching works correctly
6. Toggle between light and dark themes and verify appearance

#### Tablet View (768×1024)
1. Navigate to the settings page
2. Verify that settings layout adapts to the smaller screen size
3. Verify that navigation remains accessible
4. Test various settings controls
5. Verify that theme switching works correctly
6. Rotate to landscape orientation and verify layout adjusts appropriately
7. Toggle between light and dark themes and verify appearance

#### Mobile View (375×667)
1. Navigate to the settings page
2. Verify that settings navigation collapses to a dropdown or tabs
3. Verify that settings content is stacked vertically
4. Verify that all form controls are large enough for touch input
5. Test various settings controls
6. Verify that theme switching works correctly
7. Rotate to landscape orientation and verify layout adjusts appropriately
8. Toggle between light and dark themes and verify appearance

### 5. Touch Interaction Tests (Mobile and Tablet)

1. Verify that all buttons and links have touch targets of at least 44×44 pixels
2. Verify that there is adequate spacing between touch targets
3. Test swipe gestures if implemented
4. Verify that hover states are properly translated to touch states
5. Test form inputs for touch-friendly behavior
6. Verify that dropdowns and menus are easy to use with touch

### 6. Keyboard Navigation Tests (Desktop)

1. Navigate through each page using only the Tab key
2. Verify that focus order is logical and follows visual layout
3. Verify that focus indicators are clearly visible in both themes
4. Test keyboard shortcuts if implemented
5. Verify that all interactive elements can be activated with keyboard

### 7. Screen Size Transition Tests

1. Use browser developer tools to gradually resize from desktop to mobile
2. Note the breakpoints where layout changes occur
3. Verify that layout transitions smoothly between breakpoints
4. Verify that no content becomes inaccessible at any viewport size
5. Verify that text remains readable at all sizes without zooming

## Reporting Issues

For each issue found, document the following:

1. **Page**: Which page the issue occurs on
2. **Device/Viewport**: The device or viewport size where the issue occurs
3. **Orientation**: Portrait or landscape
4. **Browser**: Which browser and version
5. **Theme**: Light or dark theme
6. **Description**: Clear description of the issue
7. **Screenshots**: Visual evidence of the issue
8. **Severity**: Critical, Major, Minor, or Cosmetic
9. **Steps to Reproduce**: Detailed steps to reproduce the issue

## Test Results Summary

| Page | Desktop | Tablet (Portrait) | Tablet (Landscape) | Mobile (Portrait) | Mobile (Landscape) |
|------|---------|-------------------|-------------------|-------------------|-------------------|
| Dashboard |  |  |  |  |  |
| Transactions |  |  |  |  |  |
| Budgets |  |  |  |  |  |
| Settings |  |  |  |  |  |

Use the following ratings:
- ✅ Pass: No issues found
- ⚠️ Minor: Minor visual or functional issues that don't impact usability
- ❌ Fail: Significant issues that impact usability or functionality