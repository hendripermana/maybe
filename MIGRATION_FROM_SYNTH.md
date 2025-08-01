# Migration from Synth Finance

Synth Finance has been discontinued, so Maybe has been updated to use alternative providers for exchange rates and stock prices.

## New Providers

### Exchange Rates: ExchangeRatesAPI.io
- **Free tier**: 1,000 requests per month
- **Paid plans**: Available for higher usage
- **Sign up**: https://exchangeratesapi.io/
- **Coverage**: 170+ currencies with historical data

### Stock Prices: Alpha Vantage
- **Free tier**: 25 requests per day
- **Paid plans**: Available for higher usage  
- **Sign up**: https://www.alphavantage.co/
- **Coverage**: US stocks, ETFs, and some international markets

## Migration Steps

### 1. Run the Migration Script
```bash
rails migrate:from_synth
```

This will:
- Check your current Synth configuration
- Clear potentially stale cached data
- Test new provider connections
- Provide setup instructions

### 2. Get API Keys

#### ExchangeRatesAPI.io (Optional for basic usage)
1. Visit https://exchangeratesapi.io/
2. Sign up for a free account
3. Get your API key from the dashboard
4. The free tier works without an API key but with limitations

#### Alpha Vantage (Required for stock prices)
1. Visit https://www.alphavantage.co/
2. Sign up for a free account
3. Get your API key from the dashboard

### 3. Configure API Keys

#### Environment Variables
```bash
export EXCHANGE_RATES_API_KEY=your_exchange_rates_api_key
export ALPHA_VANTAGE_API_KEY=your_alpha_vantage_api_key
```

#### Self-Hosted Settings
If you're self-hosting, you can configure the API keys in:
**Settings > Self Hosting > API Configuration**

### 4. Update Environment Files

Update your `.env` files:
```bash
# Remove old Synth key
# SYNTH_API_KEY=old_key

# Add new provider keys
EXCHANGE_RATES_API_KEY=your_exchange_rates_api_key
ALPHA_VANTAGE_API_KEY=your_alpha_vantage_api_key
```

### 5. Test the Integration

1. Try creating a transaction in a foreign currency
2. Import or create a stock trade
3. Check that exchange rates and stock prices are fetched correctly

## Differences from Synth

### Exchange Rates
- **Coverage**: Similar coverage with 170+ currencies
- **Historical data**: Available but may have different date ranges
- **Rate limits**: 1,000 requests/month on free tier vs Synth's limits
- **Accuracy**: Comparable accuracy for major currency pairs

### Stock Prices
- **Coverage**: Primarily US markets (vs Synth's global coverage)
- **Rate limits**: 25 requests/day on free tier (much lower than Synth)
- **Data quality**: High quality for US stocks, limited international coverage
- **Real-time data**: Available on paid plans

## Troubleshooting

### Exchange Rate Issues
- Verify your ExchangeRatesAPI.io key is correct
- Check you haven't exceeded the rate limit
- For free tier, some features may be limited

### Stock Price Issues
- Verify your Alpha Vantage key is correct
- Check you haven't exceeded the 25 requests/day limit
- International stocks may not be available
- Consider upgrading to a paid plan for higher limits

### General Issues
- Clear browser cache and restart the application
- Check logs for specific error messages
- Verify API keys are properly set in environment or settings

## Rollback (Not Recommended)

If you need to temporarily rollback:
1. Keep your old Synth API key
2. Restore the old provider files from git history
3. Update the provider registry

However, since Synth Finance is discontinued, this is only a temporary solution.

## Support

If you encounter issues during migration:
1. Check the application logs for detailed error messages
2. Verify your API keys are correct and active
3. Test the provider APIs directly using curl or similar tools
4. Open an issue on the Maybe GitHub repository with details

## Cost Comparison

| Provider | Free Tier | Paid Plans Start At |
|----------|-----------|-------------------|
| ExchangeRatesAPI.io | 1,000 requests/month | $10/month |
| Alpha Vantage | 25 requests/day | $25/month |
| Synth Finance | Was ~$20/month | Discontinued |

The new setup can be completely free for light usage, or cost-effective for heavier usage.