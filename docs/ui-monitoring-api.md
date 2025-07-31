# UI Monitoring API Documentation

## Overview

The UI Monitoring API provides endpoints for collecting client-side UI events, errors, and performance metrics. This system helps track UI/UX issues and provides valuable data for improving the application.

## Authentication

The API uses CSRF tokens for security. Include the CSRF token in the request headers:

```javascript
headers: {
  'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
}
```

## Endpoints

### POST /api/ui_monitoring_events

Creates a new UI monitoring event.

#### Request Format

```javascript
{
  "event_type": "ui_error|performance_metric|component_error",
  "data": {
    // Event-specific data (see Event Types section)
  }
}
```

#### Response Format

**Success (200 OK):**
```javascript
{
  "status": "success",
  "event_id": 123
}
```

**Error (422 Unprocessable Entity):**
```javascript
{
  "status": "error",
  "errors": ["Event type can't be blank"]
}
```

## Event Types

### UI Error Events

Used for tracking JavaScript errors and component failures.

```javascript
{
  "event_type": "ui_error",
  "data": {
    "error_type": "TypeError",
    "message": "Cannot read property 'foo' of undefined",
    "stack": "Error: Cannot read property...\n    at component.js:42:15",
    "component_name": "TransactionList",
    "context": "{\"operation\":\"render\",\"props\":{\"accountId\":123}}",
    "url": "https://app.maybe.co/accounts/123",
    "user_agent": "Mozilla/5.0..."
  }
}
```

**Required Fields:**
- `error_type`: The type/name of the error
- `message`: Error message
- `url`: Current page URL

**Optional Fields:**
- `stack`: Error stack trace
- `component_name`: Name of the component where error occurred
- `context`: Additional context as JSON string
- `user_agent`: Browser user agent string

### Performance Metric Events

Used for tracking performance measurements.

```javascript
{
  "event_type": "performance_metric",
  "data": {
    "metric_name": "theme_switch_duration",
    "value": 1250.5,
    "component_name": "ThemeToggle",
    "event_name": "theme_switched",
    "duration": 1250.5,
    "timestamp": 1640995200000
  }
}
```

**Required Fields:**
- `metric_name`: Name of the performance metric
- `value`: Numeric value of the metric

**Optional Fields:**
- `component_name`: Component being measured
- `event_name`: Specific event being measured
- `duration`: Duration in milliseconds
- `timestamp`: Event timestamp

### Component Error Events

Used for tracking component-specific errors.

```javascript
{
  "event_type": "component_error",
  "data": {
    "component_name": "FeedbackForm",
    "error_type": "RenderError",
    "message": "Failed to render component",
    "props": "{\"userId\":123,\"theme\":\"dark\"}",
    "lifecycle_stage": "mount|update|unmount"
  }
}
```

## Client-Side Integration

### JavaScript Service

Use the `UiMonitoringService` for consistent event reporting:

```javascript
// Import the service
import { UiMonitoringService } from 'services/ui_monitoring';

// Report an error
try {
  // Your code here
} catch (error) {
  UiMonitoringService.captureError(error, 'ComponentName', {
    operation: 'data_fetch',
    userId: currentUser.id
  });
}

// Report performance metrics
const startTime = performance.now();
// ... operation ...
const duration = performance.now() - startTime;

UiMonitoringService.sendEvent('performance_metric', {
  metric_name: 'data_load_time',
  value: duration,
  component_name: 'Dashboard'
});
```

### Global Error Handler

The system automatically captures unhandled JavaScript errors:

```javascript
window.addEventListener('error', (event) => {
  UiMonitoringService.captureError(event.error);
});

window.addEventListener('unhandledrejection', (event) => {
  UiMonitoringService.captureError(event.reason);
});
```

### Stimulus Controller Integration

For Stimulus controllers, errors are automatically captured:

```javascript
// app/javascript/controllers/my_controller.js
import { Controller } from "@hotwired/stimulus"
import { UiMonitoringService } from "services/ui_monitoring"

export default class extends Controller {
  connect() {
    try {
      // Your initialization code
    } catch (error) {
      UiMonitoringService.captureError(error, 'MyController', {
        element: this.element.tagName,
        action: 'connect'
      });
      throw error; // Re-throw to maintain normal error handling
    }
  }
}
```

## Server-Side Processing

### Automatic Processing

Events are automatically processed when received:

1. **User Association**: Events are linked to the current user if authenticated
2. **Session Tracking**: Session ID is recorded for debugging
3. **IP and User Agent**: Captured for context
4. **Alert Detection**: System checks if the event should trigger alerts

### Alert Triggers

The system automatically triggers alerts for:

- **UI Errors**: When 3+ similar errors occur within 1 hour
- **Performance Issues**: When theme switching takes >2 seconds
- **Component Failures**: When critical components fail repeatedly

## Rate Limiting

The API implements basic rate limiting:

- **Per Session**: 100 events per minute
- **Per User**: 500 events per hour
- **Global**: 10,000 events per minute

Exceeded limits return HTTP 429 (Too Many Requests).

## Data Retention

- **UI Events**: Retained for 90 days
- **Performance Metrics**: Retained for 30 days
- **Error Events**: Retained for 180 days

## Privacy Considerations

- Personal data is automatically anonymized
- IP addresses are hashed after 24 hours
- User agents are sanitized to remove identifying information
- No sensitive form data is captured

## Testing

### Development Environment

In development, events are logged to the console:

```javascript
// This will log the event instead of sending to server
UiMonitoringService.captureError(error, 'TestComponent');
```

### Test Helpers

Use the test helpers for integration testing:

```ruby
# test/test_helper.rb
def assert_monitoring_event_created(event_type, &block)
  assert_difference 'UiMonitoringEvent.count', 1 do
    yield
  end
  
  event = UiMonitoringEvent.last
  assert_equal event_type, event.event_type
  event
end
```

## Troubleshooting

### Common Issues

**Events not being sent:**
- Check CSRF token is included in headers
- Verify network connectivity
- Check browser console for JavaScript errors

**High error rates:**
- Review error patterns in monitoring dashboard
- Check for recent code deployments
- Verify third-party service availability

**Performance alerts:**
- Monitor theme switching performance
- Check for large DOM manipulations
- Review CSS animation performance

### Debug Mode

Enable debug mode in development:

```javascript
// In browser console
localStorage.setItem('ui_monitoring_debug', 'true');

// This will log all events to console
UiMonitoringService.debug = true;
```

## API Changelog

### v1.0.0 (Current)
- Initial API release
- Support for ui_error, performance_metric, and component_error events
- Automatic alert detection
- CSRF protection

## Support

For API issues or questions:
- Check the monitoring dashboard for event delivery status
- Review server logs for processing errors
- Contact the development team with event IDs for specific issues