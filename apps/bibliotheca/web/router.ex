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
    resources "/laws", LawController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bibliotheca do
  #   pipe_through :api
  # end
end
