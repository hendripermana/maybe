# Provider Setup Guide

This guide helps you configure the external data providers that Maybe uses for exchange rates and stock prices.

## Overview

Maybe uses two external providers:
- **ExchangeRatesAPI.io** for currency exchange rates
- **Alpha Vantage** for stock prices and security information

Both offer free tiers that work well for personal use.

## ExchangeRatesAPI.io Setup (Exchange Rates)

### Free Tier
- **Requests**: 1,000 per month
- **Features**: Current and historical exchange rates for 170+ currencies
- **Limitations**: HTTPS requires paid plan, limited to EUR base currency on free tier

### Getting Started
1. Visit https://exchangeratesapi.io/
2. Click "Get Free API Key"
3. Sign up with your email
4. Verify your email address
5. Copy your API key from the dashboard

### Configuration
Add to your `.env` file:
```bash
EXCHANGE_RATES_API_KEY=your_api_key_here
```

Or configure in **Settings > Self Hosting** if you're self-hosting.

### Testing
```bash
# Test the connection
rails runner "puts Provider::Registry.get_provider(:exchange_rates_api).healthy?.success?"
```

## Alpha Vantage Setup (Stock Prices)

### Free Tier
- **Requests**: 25 per day
- **Features**: Real-time and historical stock data, company information
- **Coverage**: Primarily US markets (NYSE, NASDAQ)

### Getting Started
1. Visit https://www.alphavantage.co/
2. Click "Get your free API key today"
3. Fill out the form (choose "Individual" for personal use)
4. Verify your email address
5. Copy your API key from the confirmation email

### Configuration
Add to your `.env` file:
```bash
ALPHA_VANTAGE_API_KEY=your_api_key_here
```

Or configure in **Settings > Self Hosting** if you're self-hosting.

### Testing
```bash
# Test the connection
rails runner "puts Provider::Registry.get_provider(:alpha_vantage)&.healthy?&.success? || 'Not configured'"
```

## Complete Setup Example

Your `.env` file should include:
```bash
# Exchange rates (optional for basic usage)
EXCHANGE_RATES_API_KEY=your_exchange_rates_api_key

# Stock prices (required for investment tracking)
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_api_key
```

## Usage Monitoring

### Check API Usage
```bash
# Check exchange rates API usage
rails runner "puts Provider::Registry.get_provider(:exchange_rates_api).usage.data.inspect"

# Check Alpha Vantage usage
rails runner "puts Provider::Registry.get_provider(:alpha_vantage)&.usage&.data&.inspect"
```

### Rate Limits
- **ExchangeRatesAPI.io**: 1,000 requests/month (resets monthly)
- **Alpha Vantage**: 25 requests/day (resets daily at midnight EST)

## Troubleshooting

### Common Issues

#### "Invalid API key" errors
- Double-check your API key is correct
- Ensure no extra spaces or characters
- Verify the key is active in the provider's dashboard

#### Rate limit exceeded
- **ExchangeRatesAPI.io**: Wait until next month or upgrade plan
- **Alpha Vantage**: Wait until next day or upgrade plan

#### No data returned
- Check if the symbol/currency pair is supported
- Verify the date range is valid
- Some providers have delays for real-time data

### Debug Mode
Enable debug logging to see API requests:
```bash
# In development
RAILS_LOG_LEVEL=debug rails server
```

### Manual Testing
Test the APIs directly:

```bash
# Test ExchangeRatesAPI.io
curl "https://api.exchangeratesapi.io/v1/latest?access_key=YOUR_KEY&base=USD&symbols=EUR"

# Test Alpha Vantage
curl "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=AAPL&apikey=YOUR_KEY"
```

## Upgrading to Paid Plans

### When to Upgrade
- You exceed the free tier limits
- You need more frequent updates
- You require additional features (HTTPS, more currencies, etc.)

### ExchangeRatesAPI.io Paid Plans
- **Basic**: $10/month - 10,000 requests
- **Professional**: $25/month - 100,000 requests
- **Enterprise**: Custom pricing

### Alpha Vantage Paid Plans
- **Basic**: $25/month - 75 requests/minute
- **Standard**: $50/month - 300 requests/minute
- **Premium**: $150/month - 600 requests/minute

## Alternative Providers

If you need different providers, you can:
1. Implement a new provider class following the existing patterns
2. Update the provider registry
3. Configure the new provider in settings

See the existing provider implementations in `app/models/provider/` for examples.

## Support

For provider-specific issues:
- **ExchangeRatesAPI.io**: https://exchangeratesapi.io/documentation
- **Alpha Vantage**: https://www.alphavantage.co/support/

For Maybe-specific issues:
- Check the application logs
- Open an issue on the Maybe GitHub repository