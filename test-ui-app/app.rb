require 'sinatra'
require 'sinatra/reloader' if development?
require 'erb'

# Simple Sinatra app to demonstrate UI/UX modernization progress
class TestUIApp < Sinatra::Base
  configure do
    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'
    enable :sessions
  end

  # Set default theme if not already set
  before do
    session[:theme] ||= 'light'
  end

  # Home page - Dashboard demo
  get '/' do
    @page_title = "Dashboard"
    erb :dashboard
  end

  # Transactions page demo
  get '/transactions' do
    @page_title = "Transactions"
    erb :transactions
  end

  # Budgets page demo
  get '/budgets' do
    @page_title = "Budgets"
    erb :budgets
  end

  # Settings page demo
  get '/settings' do
    @page_title = "Settings"
    erb :settings
  end

  # Toggle theme
  post '/toggle_theme' do
    session[:theme] = session[:theme] == 'light' ? 'dark' : 'light'
    redirect back
  end

  # Helper method to get current theme
  helpers do
    def current_theme
      session[:theme]
    end
  end
end

# Run the application if this file is executed directly
TestUIApp.run! if __FILE__ == $0
