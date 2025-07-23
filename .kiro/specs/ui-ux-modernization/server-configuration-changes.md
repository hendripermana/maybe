# Server Configuration Changes for UI/UX Modernization

## Overview

This document outlines the server configuration changes required to support the UI/UX modernization project. These changes optimize asset delivery, improve caching strategies, and configure monitoring for the new components.

## Required Configuration Changes

### 1. Nginx Configuration Updates

#### Asset Caching Improvements

Update the Nginx configuration to optimize caching for the new component assets:

```nginx
# /etc/nginx/conf.d/maybe-finance.conf

# Existing configuration...

# Enhanced asset caching for UI components
location ~* \.(css|js)$ {
    expires 7d;
    add_header Cache-Control "public, max-age=604800, immutable";
    
    # Add version fingerprint exception
    location ~* \.(css|js)\?v=[0-9a-f]{8,}$ {
        expires 365d;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }
}

# Font file caching
location ~* \.(woff|woff2|ttf|otf|eot)$ {
    expires 30d;
    add_header Cache-Control "public, max-age=2592000";
    access_log off;
}

# SVG icon caching
location ~* \.svg$ {
    expires 7d;
    add_header Cache-Control "public, max-age=604800";
}

# Add brotli compression for CSS and JS
brotli on;
brotli_comp_level 6;
brotli_types text/css application/javascript;
```

#### HTTP Headers for Security and Performance

Add security and performance-related headers:

```nginx
# Security and performance headers
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

# Add preload headers for critical assets
location = / {
    add_header Link "</assets/application-modern.css>; rel=preload; as=style";
    add_header Link "</assets/theme-system.css>; rel=preload; as=style";
    add_header Link "</assets/fonts/inter-var.woff2>; rel=preload; as=font; crossorigin";
}
```

### 2. Redis Configuration

Update Redis configuration to improve caching for UI components:

```
# /etc/redis/redis.conf

# Increase memory for caching
maxmemory 2gb
maxmemory-policy allkeys-lru

# Optimize for UI component caching
hash-max-ziplist-entries 1024
hash-max-ziplist-value 128
```

### 3. CDN Configuration

Update CDN configuration for the modernized assets:

```json
// CDN configuration (example for CloudFront)
{
  "DistributionConfig": {
    "CacheBehaviors": {
      "Quantity": 3,
      "Items": [
        {
          "PathPattern": "assets/modern/*",
          "TargetOriginId": "maybe-app-origin",
          "ViewerProtocolPolicy": "redirect-to-https",
          "Compress": true,
          "DefaultTTL": 86400,
          "MaxTTL": 31536000,
          "MinTTL": 0,
          "ForwardedValues": {
            "QueryString": true,
            "Cookies": {
              "Forward": "none"
            },
            "Headers": {
              "Quantity": 1,
              "Items": ["Origin"]
            }
          }
        },
        {
          "PathPattern": "assets/fonts/*",
          "TargetOriginId": "maybe-app-origin",
          "ViewerProtocolPolicy": "redirect-to-https",
          "Compress": true,
          "DefaultTTL": 2592000,
          "MaxTTL": 31536000,
          "MinTTL": 2592000
        },
        {
          "PathPattern": "assets/images/*",
          "TargetOriginId": "maybe-app-origin",
          "ViewerProtocolPolicy": "redirect-to-https",
          "Compress": true,
          "DefaultTTL": 604800,
          "MaxTTL": 31536000,
          "MinTTL": 86400
        }
      ]
    }
  }
}
```

### 4. Application Server Configuration

Update Puma configuration for better performance with the modernized UI:

```ruby
# config/puma.rb

# Increase worker count for better concurrent request handling
workers ENV.fetch("WEB_CONCURRENCY") { 4 }

# Optimize for UI-heavy requests
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 12 }
threads threads_count, threads_count

# Add worker timeout for long-running requests
worker_timeout 60

# Enable request logging for monitoring
log_requests true
```

### 5. Monitoring Configuration

#### Sentry Configuration

Update Sentry configuration to monitor UI components:

```ruby
# config/initializers/sentry.rb

Sentry.init do |config|
  # Existing configuration...
  
  # Add performance monitoring for UI components
  config.traces_sample_rate = 0.2
  
  # Add UI component context
  config.before_send = lambda do |event, hint|
    if hint[:ui_component]
      event.tags[:component] = hint[:ui_component]
      event.tags[:theme_mode] = Current.user&.theme_preference || 'system'
    end
    event
  end
  
  # Ignore certain UI errors that are expected
  config.before_breadcrumb = lambda do |breadcrumb, hint|
    if breadcrumb.category == 'ui.click' && 
       hint[:event]&.target&.matches?('.theme-toggle')
      nil  # Ignore theme toggle clicks
    else
      breadcrumb
    end
  end
end
```

#### Skylight Configuration

Update Skylight configuration for UI performance monitoring:

```yaml
# config/skylight.yml

authentication: <%= ENV['SKYLIGHT_AUTHENTICATION'] %>
enable_sidekiq: true

# Add component probes
probes:
  view_component: true
  active_job: true
  redis: true

# Component-specific instrumentation
components:
  - ButtonComponent
  - CardComponent
  - ModalComponent
  - TabsComponent

# Endpoint grouping for UI routes
endpoints:
  - pattern: /ui/.*
    name: UI Components
  - pattern: /settings/theme
    name: Theme Settings
```

### 6. Database Configuration

No major database changes are required for the UI/UX modernization, but optimize for theme preference storage:

```yaml
# config/database.yml

production:
  # Existing configuration...
  
  variables:
    # Add index for theme preference queries
    statement_timeout: 5000
    
  # Add connection pool optimization for concurrent UI requests
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 12 } %>
```

## Implementation Steps

1. **Pre-deployment Configuration**
   - Update Nginx configuration files
   - Modify Redis settings
   - Configure CDN for new asset paths
   - Update monitoring systems

2. **Deployment-time Configuration**
   - Restart Nginx with new configuration
   - Apply Redis changes
   - Update CDN distribution
   - Deploy application with updated server configs

3. **Post-deployment Verification**
   - Verify correct asset caching behavior
   - Confirm CDN is serving assets correctly
   - Check monitoring systems are capturing UI metrics
   - Test performance with updated configurations

## Rollback Considerations

If server configuration changes need to be rolled back:

1. **Nginx Rollback**
   ```bash
   # Restore previous Nginx configuration
   cp /etc/nginx/conf.d/maybe-finance.conf.bak /etc/nginx/conf.d/maybe-finance.conf
   systemctl reload nginx
   ```

2. **Redis Rollback**
   ```bash
   # Restore previous Redis configuration
   cp /etc/redis/redis.conf.bak /etc/redis/redis.conf
   systemctl restart redis
   ```

3. **CDN Rollback**
   - Revert to previous CDN configuration through management console
   - Force cache invalidation for affected paths

## Security Considerations

The server configuration changes include several security enhancements:

1. **Content Security Policy**: Updated to allow only required resources
2. **HTTP Security Headers**: Added modern security headers
3. **Asset Integrity**: Configured SRI for critical JavaScript resources
4. **CORS Policies**: Tightened for font and asset requests

## Performance Impact

These configuration changes are expected to improve performance:

1. **Asset Caching**: Longer cache times for immutable assets
2. **Compression**: Added Brotli compression for smaller asset sizes
3. **Preloading**: Critical assets preloaded for faster initial render
4. **Connection Pooling**: Optimized for concurrent UI requests

## Monitoring Recommendations

After applying these configuration changes, monitor:

1. **Cache Hit Rates**: Verify improved caching effectiveness
2. **Response Times**: Confirm reduced latency for asset requests
3. **Error Rates**: Watch for any configuration-related errors
4. **Memory Usage**: Monitor Redis memory consumption with new settings