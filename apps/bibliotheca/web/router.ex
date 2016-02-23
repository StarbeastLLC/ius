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

    get "/account-recovery", AuthController, :forgot_password
    post "/password/", AuthController, :new_password
    get "/account-recovery/:token", AuthController, :change_password

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
    get "/register/:token", RegistrationController, :verify

    post "/facebook-login", FacebookController, :auth
    post "/google-login", GoogleController, :auth

    get "/profile", ProfileController, :profile
    put "/profile", ProfileController, :update_profile
    post "/profile-password", ProfileController, :new_password
    get "/change-password/:token", ProfileController, :change_password
    
    resources "/laws", LawController
    get "/load", LawController, :load
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bibliotheca do
  #   pipe_through :api
  # end
end
