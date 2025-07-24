require 'net/http'
require 'uri'
require 'json'

class SlackNotifier
  # Send a notification to Slack
  def self.notify(title, message, category, severity)
    return unless webhook_url.present?
    
    # Don't send notifications in test environment
    return if Rails.env.test?
    
    # Prepare the payload
    payload = {
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "🚨 UI Monitoring Alert: #{title}",
            emoji: true
          }
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: "*Category:*\n#{category.to_s.humanize}"
            },
            {
              type: "mrkdwn",
              text: "*Severity:*\n#{severity.to_s.humanize}"
            },
            {
              type: "mrkdwn",
              text: "*Time:*\n#{Time.current.strftime("%Y-%m-%d %H:%M:%S %Z")}"
            },
            {
              type: "mrkdwn",
              text: "*Environment:*\n#{Rails.env}"
            }
          ]
        },
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Alert Details:*\n```#{message}```"
          }
        },
        {
          type: "actions",
          elements: [
            {
              type: "button",
              text: {
                type: "plain_text",
                text: "View Monitoring Dashboard",
                emoji: true
              },
              url: monitoring_url
            }
          ]
        }
      ]
    }
    
    # Send the notification asynchronously
    Thread.new do
      begin
        uri = URI.parse(webhook_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        
        request = Net::HTTP::Post.new(uri.request_uri)
        request.content_type = 'application/json'
        request.body = payload.to_json
        
        response = http.request(request)
        
        unless response.code.to_i == 200
          Rails.logger.error "Failed to send Slack notification: #{response.code} - #{response.body}"
        end
      rescue => e
        Rails.logger.error "Error sending Slack notification: #{e.message}"
      ensure
        Thread.exit
      end
    end
  end
  
  private
  
  def self.webhook_url
    ENV['SLACK_WEBHOOK_URL']
  end
  
  def self.monitoring_url
    Rails.application.routes.url_helpers.monitoring_url(host: ENV.fetch('APPLICATION_HOST', 'localhost:3000'))
  end
end