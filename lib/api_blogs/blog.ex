defmodule ApiBlogs.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias ApiBlogs.Repo

  alias ApiBlogs.Blog.User

  alias ApiBlogs.Guardian

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns error if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      {:error, :not_found, "Usuario nao existe"}

  """
  def get_user(id) do
    user = Repo.get(User, id)
    case user do
      nil -> {:error, :not_found, "Usuario nao existe"}
      _ -> {:ok, user}
    end
  end

  @doc """
  Returns the user whose jwt token is in the conn header.

  """
  def get_user_from_conn(conn) do
    with {:ok, id} <- extract_id(conn) do
      get_user(id)
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns the id of the user whose jwt token is in the conn header.

  """
  defp extract_id(%{private: %{guardian_default_token: token}}) do
    {:ok, %{"sub" => id}} = Guardian.decode_and_verify(token)
    {:ok, id}
  end

  @doc """
  Checks if email and password were provided for login and if they are correct.
  If they are, returns a tuple of {:ok, user}.

  Returns error if anything is wrong.

  """
  def do_login(%{"email" => "", "password" => _password}), do: {:error, :bad_request, "\"email\" is not allowed to be empty"}
  def do_login(%{"email" => _email, "password" => ""}), do: {:error, :bad_request, "\"password\" is not allowed to be empty"}
  def do_login(%{"email" => email, "password" => password}) do
    User
    |> Repo.get_by(email: email)
    |> validate_login(password)
  end
  def do_login(%{"email" => _email}), do: {:error, :bad_request, "\"password\" is required"}
  def do_login(%{"password" => _password}), do: {:error, :bad_request, "\"email\" is required"}

  defp validate_login(nil, _password), do: {:error, :bad_request, "Campos invalidos"}
  defp validate_login(user, password) when user.password != password, do: {:error, :bad_request, "Campos invalidos"}
  defp validate_login(user, _password), do: {:ok, user}

  alias ApiBlogs.Blog.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Using a list of posts, creates a list of maps of the posts and it's author users.


  With a single post, creates a single map of the post and it's author.

  """
  def get_post_user([]), do: []
  def get_post_user([post | posts]) do
    with user <- get_user!(post.user_id) do
      [ %{post: post, user: user} | get_post_user(posts)]
    end
  end
  def get_post_user(post) do
    with user <- get_user!(post.user_id) do
      %{post: post, user: user}
    end
  end

  @doc """
  Returns a list of all posts in database together with their authors.

  """
  def list_posts_with_users() do
    list_posts()
    |> get_post_user()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Gets a single post.

  Returns error if the Post does not exist.

  ## Examples

      iex> get_post(123)
      %Post{}

      iex> get_post(456)
      {:error, :not_found, "Post nao existe"}

  """
  def get_post(id) do
    post = Repo.get(Post, id)
    case post do
      nil -> {:error, :not_found, "Post nao existe"}
      _ -> {:ok, post}
    end
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a map with the required parameters to create a post.

  """
  def add_params_create_post(conn, post_params) do
    {:ok, id} = extract_id(conn)
    new_post = Map.put(post_params, "user_id", id)
    {:ok, new_post}
  end

  @doc """
  Updates a post, if the update is valid.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, %{"content" => _, "title" => _} = attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end
  def update_post(%Post{} = _post, %{"content" => _} = _attrs), do: {:error, :bad_request, "\"title\" is required"}
  def update_post(%Post{} = _post, %{"title" => _} = _attrs), do: {:error, :bad_request, "\"content\" is required"}


  @doc """
  Checks if the user whose jwt token is in the conn header is allowed to edit a post.

  """
  def check_valid_user(conn, post) do
    with {:ok, user_id} <- extract_id(conn),
         int_user_id <- convert_string_to_int(user_id),
         {:ok, %Post{} = post} <- is_user_author(int_user_id, post) do
      {:ok, post}
    end
  end

  @doc """
  Converts a string number to int.

  """
  defp convert_string_to_int(string) do
    string
    |> Integer.parse()
    |> elem(0)
  end

  @doc """
  Checks if the id given is that of the post's author. In case it's not, returns error.

  """
  defp is_user_author(id, post) when id != post.user_id, do: {:error, :unauthorized, "Usuario nao autorizado"}
  defp is_user_author(_id, post), do: {:ok, post}

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Searches the database for posts with a given term in title or content.
  Returns a list of posts with users wich match the term.

  """
  def search_posts_by_term(searchTerm) do
    query =
      from p in Post,
      where: ilike(p.title, ^"%#{searchTerm}%")
        or ilike(p.content, ^"%#{searchTerm}%")
    result = Repo.all(query)
    case result do
      [] -> []
      _ -> get_post_user(result)
    end
  end
end
