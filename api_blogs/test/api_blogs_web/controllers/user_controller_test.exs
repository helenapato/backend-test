defmodule ApiBlogsWeb.UserControllerTest do
  use ApiBlogsWeb.ConnCase

  import ApiBlogs.BlogFixtures

  alias ApiBlogs.Blog.User

  @create_attrs %{
    displayName: "rubens silva",
    email: "rubens@email.com",
    image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
    password: "123456"
  }
  @update_attrs %{
    displayName: "maria silva",
    email: "maria@email.com",
    image: "image.png",
    password: "654321"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders jwt when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"jwt" => jwt} = json_response(conn, 201)

      conn =
        build_conn()
        |> put_valid_jwt_header(jwt)
        |> get(Routes.user_path(conn, :index))

      assert %{"data" => [%{"id" => id}]} = json_response(conn, 200)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{"data" =>
                %{
                  "id" => ^id,
                  "displayName" => "rubens silva",
                  "email" => "rubens@email.com",
                  "image" => "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
                  "password" => "123456"
                }
              } = json_response(conn, 200)
    end

    test "renders errors when displayName has less than 8 characters", %{conn: conn} do
      invalid_user = %{
        displayName: "rubinho",
        email: "rubens@email.com",
        image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :create), user: invalid_user)
      assert %{"errors" => %{"displayName" => ["should be at least 8 character(s)"]}} = json_response(conn, 400)
    end

    test "renders errors when email has no domain", %{conn: conn} do
      invalid_user = %{
        displayName: "rubens silva",
        email: "rubinho",
        image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :create), user: invalid_user)
      assert %{"errors" => %{"email" => ["has invalid format"]}} = json_response(conn, 400)
    end

    test "renders errors when email has no prefix", %{conn: conn} do
      invalid_user = %{
        displayName: "rubens silva",
        email: "@gmail.com",
        image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :create), user: invalid_user)
      assert %{"errors" => %{"email" => ["has invalid format"]}} = json_response(conn, 400)
    end

    test "renders errors when no email is provided", %{conn: conn} do
      invalid_user = %{
        displayName: "rubens silva",
        image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :create), user: invalid_user)
      assert %{"errors" => %{"email" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders errors when password is less than 6 characters long", %{conn: conn} do
      invalid_user = %{
        displayName: "rubens silva",
        email: "rubens@email.com",
        image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
        password: "12345"
      }
      conn = post(conn, Routes.user_path(conn, :create), user: invalid_user)
      assert %{"errors" => %{"password" => ["should be at least 6 character(s)"]}} = json_response(conn, 400)
    end

    test "renders errors when no password is provided", %{conn: conn} do
      invalid_user = %{
        displayName: "rubens silva",
        email: "rubens@email.com",
        image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png"
      }
      conn = post(conn, Routes.user_path(conn, :create), user: invalid_user)
      assert %{"errors" => %{"password" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders errors when email already exists in database", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"jwt" => _} = json_response(conn, 201)

      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"errors" => %{"email" => ["Usuario ja existe"]}} = json_response(conn, 409)
    end
  end

  describe "user login" do
    setup [:add_user]

    test "renders jwt when data is valid", %{conn: conn} do
      valid_attrs = %{
        email: "rubens@email.com",
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :login), user: valid_attrs)
      assert %{"jwt" => _} = json_response(conn, 200)
    end

    test "renders errors when no email is provided", %{conn: conn} do
      invalid_attrs = %{
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :login), user: invalid_attrs)
      assert %{"message" => "\"email\" is required"} = json_response(conn, 400)
    end

    test "renders errors when no password is provided", %{conn: conn} do
      invalid_attrs = %{
        email: "rubens@email.com"
      }
      conn = post(conn, Routes.user_path(conn, :login), user: invalid_attrs)
      assert %{"message" => "\"password\" is required"} = json_response(conn, 400)
    end

    test "renders errors when email is blank", %{conn: conn} do
      invalid_attrs = %{
        email: "",
        password: "123456"
      }
      conn = post(conn, Routes.user_path(conn, :login), user: invalid_attrs)
      assert %{"message" => "\"email\" is not allowed to be empty"} = json_response(conn, 400)
    end

    test "renders errors when password is blank", %{conn: conn} do
      invalid_attrs = %{
        email: "rubens@email.com",
        password: ""
      }
      conn = post(conn, Routes.user_path(conn, :login), user: invalid_attrs)
      assert %{"message" => "\"password\" is not allowed to be empty"} = json_response(conn, 400)
    end

    test "renders errors when password is wrong", %{conn: conn} do
      invalid_attrs = %{
        email: "rubens@email.com",
        password: "1234567"
      }
      conn = post(conn, Routes.user_path(conn, :login), user: invalid_attrs)
      assert %{"message" => "Campos invalidos"} = json_response(conn, 400)
    end

    test "renders errors when user doesn't exist", %{conn: conn} do
      invalid_attrs = %{
        email: "maria@email.com",
        password: "1234567"
      }
      conn = post(conn, Routes.user_path(conn, :login), user: invalid_attrs)
      assert %{"message" => "Campos invalidos"} = json_response(conn, 400)
    end
  end

  describe "list all users" do
    setup [:add_2_users]

    test "renders all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert %{"data" => [ %{"email" => "rubens@email.com"} | [ %{"email" => "maria@email.com"} ]]} = json_response(conn, 200)
    end

    test "renders errors when jwt is invalid", %{conn: conn} do
      conn =
        build_conn()
        |> put_invalid_jwt_header()
        |> get(Routes.user_path(conn, :index))

      assert %{"message" => "Token expirado ou invalido"} = json_response(conn, 401)
    end

    test "renders errors when jwt is missing", %{conn: conn} do
      conn =
        build_conn()
        |> get(Routes.user_path(conn, :index))
      assert %{"message" => "Token nao encontrado"} = json_response(conn, 401)
    end
  end

  describe "get user by id" do
    setup [:add_user_id]

    test "renders user info", %{conn: conn, id: id} do
      conn = get(conn, Routes.user_path(conn, :show, id))
      assert %{"data" => %{"email" => "rubens@email.com"}} = json_response(conn, 200)
    end

    test "renders errors when user doesn't exist", %{conn: conn, id: id} do
      invalid_id = id + 1

      conn = get(conn, Routes.user_path(conn, :show, invalid_id))
      assert %{"message" => "Usuario nao existe"} = json_response(conn, 404)
    end

    test "renders errors when jwt is invalid", %{conn: conn, id: id} do
      conn =
        build_conn()
        |> put_invalid_jwt_header()
        |> get(Routes.user_path(conn, :show, id))

      assert %{"message" => "Token expirado ou invalido"} = json_response(conn, 401)
    end

    test "renders errors when jwt is missing", %{conn: conn, id: id} do
      conn =
        build_conn()
        |> get(Routes.user_path(conn, :show, id))
      assert %{"message" => "Token nao encontrado"} = json_response(conn, 401)
    end
  end

  describe "delete user" do
    setup [:add_user_jwt]

    test "renders deleted user", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete))
      assert "" = response(conn, 204)
    end

    test "renders errors when jwt is invalid", %{conn: conn} do
      conn =
        build_conn()
        |> put_invalid_jwt_header()
        |> delete(Routes.user_path(conn, :delete))

      assert %{"message" => "Token expirado ou invalido"} = json_response(conn, 401)
    end

    test "renders errors when jwt is missing", %{conn: conn} do
      conn =
        build_conn()
        |> delete(Routes.user_path(conn, :delete))
      assert %{"message" => "Token nao encontrado"} = json_response(conn, 401)
    end
  end

  # describe "update user" do
  #   setup [:create_user]

  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.user_path(conn, :show, id))

  #     assert %{
  #              "id" => ^id,
  #              "displayName" => "some updated displayName",
  #              "email" => "some updated email",
  #              "image" => "some updated image",
  #              "password" => "some updated password"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # defp create_user(_) do
  #   user = user_fixture()
  #   %{user: user}
  # end

  defp add_user %{conn: conn} do
    {:ok, conn: post(conn, Routes.user_path(conn, :create), user: @create_attrs)}
  end

  defp add_user_jwt %{conn: conn} do
    {:ok, conn: conn} = add_user(%{conn: conn})
    jwt = get_jwt_from_conn_response(conn)

    conn =
      build_conn()
      |> put_valid_jwt_header(jwt)

    {:ok, conn: conn}
  end

  defp add_user_id %{conn: conn} do
    {:ok, conn: conn} = add_user_jwt(%{conn: conn})

    conn = get(conn, Routes.user_path(conn, :index))
    %{"data" => [%{"id" => id}]} = json_response(conn, 200)

    {:ok, conn: conn, id: id}
  end

  defp add_2_users %{conn: conn} do
    {:ok, conn: conn} = add_user_jwt(%{conn: conn})
    conn =
      conn
      |> post(Routes.user_path(conn, :create), user: @update_attrs)

    {:ok, conn: conn}
  end

  defp get_jwt_from_conn_response(conn) do
    %{"jwt" => jwt} = json_response(conn, 201)
    jwt
  end

  defp put_invalid_jwt_header(conn) do
    put_req_header(conn, "authorization", "bearer abcd")
  end

  defp put_valid_jwt_header(conn, jwt) do
    put_req_header(conn, "authorization", "bearer " <> jwt)
  end
end
