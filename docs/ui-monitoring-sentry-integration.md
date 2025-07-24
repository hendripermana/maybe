# UI Monitoring and Sentry Integration

This document describes how the UI Monitoring system integrates with Sentry for comprehensive error tracking.

## Overview

The UI Monitoring system is integrated with Sentry to provide a unified approach to error tracking. This integration ensures that:

1. UI errors captured by the monitoring system are also sent to Sentry
2. Context information is shared between the two systems
3. Links between the systems allow for easy navigation
4. Duplicate error reporting is prevented

## Configuration

### Environment Variables

The following environment variables are used for the Sentry integration:

- `SENTRY_DSN`: The Sentry Data Source Name for your project
- `SENTRY_ORGANIZATION`: Your Sentry organization name (used for generating links)
- `SENTRY_PROJECT`: Your Sentry project ID (used for generating links)

### JavaScript Integration

The Sentry JavaScript SDK is loaded in the `_ui_monitoring.html.erb` partial when `SENTRY_DSN` is present. The integration includes:

- Browser error tracking
- Performance monitoring
- Session replay for error diagnosis
- User context when available

## How It Works

### Error Capture Flow

1. When a UI error occurs, it is captured by the `UiMonitoringService`
2. The error is sent to the UI Monitoring API endpoint
3. The API endpoint creates a `UiMonitoringEvent` record
4. The API endpoint also sends the error to Sentry with a reference to the UI Monitoring event
5. The Sentry event ID is stored in the UI Monitoring event record
6. Links between the two systems are established

### Alert Flow

1. When a UI Monitoring alert is triggered, it checks if Sentry is available
2. If available, the alert is also sent to Sentry
3. The alert includes links to both the UI Monitoring dashboard and Sentry
4. Email and Slack notifications include links to both systems

## Preventing Duplicate Reports

To prevent duplicate error reporting between the two systems:

1. The `SentryIntegrationService` maintains a cache of recently reported errors
2. Before sending an error to Sentry, it checks if a similar error was recently reported
3. If a duplicate is detected, the error is logged but not sent to Sentry
4. The cache expires entries after 5 minutes to allow for reporting of recurring issues

## Dashboard Integration

The UI Monitoring dashboard displays Sentry integration information:

1. Events with Sentry data show a "Sentry" badge
2. Event details include links to the corresponding Sentry issue
3. The event JSON data includes the Sentry event ID

## Testing

The integration includes tests to verify:

1. UI errors are properly sent to Sentry
2. Sentry event IDs are stored in UI Monitoring events
3. Alert notifications include links to both systems

## Troubleshooting

If the integration is not working as expected:

1. Verify that the `SENTRY_DSN` environment variable is set correctly
2. Check that the Sentry JavaScript SDK is loading properly
3. Look for errors in the browser console related to Sentry initialization
4. Verify that the `SentryIntegrationService` is being initialized
5. Check the Rails logs for any errors related to Sentry API calls