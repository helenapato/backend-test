defmodule ApiBlogs.Guardian do
  use Guardian, otp_app: :api_blogs
  alias ApiBlogs.Blog.User

  def subject_for_token(%User{id: user_id}, _claims) do
    sub = to_string(user_id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = ApiBlogs.Blog.get_user!(id)
    {:ok,  resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
