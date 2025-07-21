# Settings Page Audit

## Current State Analysis

### Settings Pages
1. **Preferences** - User preferences including language, timezone, date format, theme
2. **Profile** - User profile information, household management
3. **API Keys** - API key management
4. **Billing** - Subscription management
5. **Hosting** - Self-hosting configuration
6. **Securities** - Securities settings

### Form Components Used
1. **Legacy Form Components**
   - `styled_form_with` - Legacy form builder
   - Form field helpers (text_field, select, etc.) with direct styling
   - Inconsistent form layouts and spacing
   - Hardcoded colors in some form elements

2. **Modern Components (Partially Implemented)**
   - Some pages have `.modernized.html.erb` versions using ViewComponents
   - Modern components exist but aren't consistently applied

### Issues Identified
1. **Inconsistent Form Styling**
   - Mix of legacy and modern form components
   - Inconsistent spacing and layout
   - Some forms lack proper feedback mechanisms

2. **Accessibility Issues**
   - Some form controls lack proper labels
   - Focus states are inconsistent
   - Missing ARIA attributes in some interactive elements

3. **Theme Inconsistencies**
   - Some form elements use hardcoded colors
   - Inconsistent application of theme variables

4. **Feedback Mechanisms**
   - Inconsistent error and success states
   - Some forms lack visual feedback on submission

## Modernization Plan

### 1. Form Components
- Replace all `styled_form_with` with `Ui::FormComponent`
- Replace direct form helpers with component equivalents
- Ensure consistent spacing and layout

### 2. Input Controls
- Replace text inputs with `Ui::InputComponent`
- Replace selects with `Ui::SelectComponent`
- Replace checkboxes with `Ui::CheckboxComponent`
- Replace radio buttons with `Ui::RadioButtonComponent`
- Replace textareas with `Ui::TextareaComponent`

### 3. Toggle Switches
- Implement proper toggle switches with `Ui::ToggleSwitchComponent`
- Add Stimulus controller for toggle switch behavior
- Ensure proper ARIA attributes and keyboard accessibility

### 4. Form Feedback
- Add clear visual feedback for form submissions
- Implement consistent error states
- Use `Ui::FormFeedbackComponent` for status messages

### 5. Theme Consistency
- Ensure all form elements use theme variables
- Test in both light and dark modes
- Remove any hardcoded colors

### 6. Accessibility Improvements
- Add proper labels for all form controls
- Ensure keyboard navigation works correctly
- Add appropriate ARIA attributes
- Test with screen readers

### 7. Layout Standardization
- Consistent spacing between form elements
- Responsive form layouts for mobile devices
- Consistent action button placement