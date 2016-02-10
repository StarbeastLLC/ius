defmodule Bibliotheca.Router do
  use Bibliotheca.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Bibliotheca do
    pipe_through :browser # Use the default browser stack
    
    get "/", PageController, :index
    post "/login", AuthController, :login
    get "/logout", AuthController, :logout

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
    get "/register/:token", RegistrationController, :verify
    
    resources "/laws", LawController
    get "/load", LawController, :load
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bibliotheca do
  #   pipe_through :api
  # end
end
