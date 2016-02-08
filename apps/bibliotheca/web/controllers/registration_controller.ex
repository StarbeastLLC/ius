defmodule Bibliotheca.RegistrationController do
  use Bibliotheca.Web, :controller
  alias Bibliotheca.User

  @from "postmaster@sandbox9ddf700296ad4bf0a817cedfe2a09d99.mailgun.org"
  @welcome "Welcome to Lexi!"

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "index.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
  	changeset = Elegua.changeset(%User{}, user_params)
  	|> User.changeset(user_params)

  	{:ok, user} = Elegua.register(changeset, :verify)
    verification_token = user.verification_token
    user_email = changeset.params["email"]
    content = "Your token: #{verification_token}"
    Elegua.send_verification_email(user_email, @from, @welcome, {:text, content})
    
  	redirect conn, to: "/"
  end
end