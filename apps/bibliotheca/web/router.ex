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

    get "/account-deletion", ProfileController, :close_account
    get "/account-deletion/:token", ProfileController, :delete_account

    post "/facebook-login", SocialConnectController, :auth
    post "/google-login", SocialConnectController, :auth

    get "/profile", ProfileController, :profile
    put "/profile", ProfileController, :update_profile
    post "/profile-password", ProfileController, :new_password
    get "/change-password/:token", ProfileController, :change_password

    get "/leyes-federales", LawController, :search
    
    post "/leyes-federales", LawController, :search
    post "/leyes-federales/articulos-por-ley", LawController, :search_title
    get "/leyes-federales/:id", LawController, :show

    post "/tesis", TesisController, :search
    get "/tesis", TesisController, :search
    get "/tesis/:ius", TesisController, :show
    post "/tesis-ius", TesisController, :search_ius

    get "/search-3", PageController, :search_3
    get "/search-4", PageController, :search_4
    get "/search-5", PageController, :search_5
    
    resources "/laws", LawController
    get "/load", LawController, :load
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bibliotheca do
  #   pipe_through :api
  # end
end
