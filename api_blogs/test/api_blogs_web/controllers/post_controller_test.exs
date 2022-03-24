defmodule ApiBlogsWeb.PostControllerTest do
  use ApiBlogsWeb.ConnCase

  import ApiBlogs.BlogFixtures

  alias ApiBlogs.Blog.Post

  @create_attrs %{
    content: "The whole text for the blog post goes here in this key",
    title: "Latest updates, August 1st"
  }
  @update_attrs %{
    content: "blablabla",
    title: "titulo"
    }
  @user_create_attrs %{
    displayName: "rubens silva",
    email: "rubens@email.com",
    image: "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png",
    password: "123456"
  }
  # @invalid_attrs %{content: nil, published: nil, title: nil, updated: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create post" do
    setup [:add_user_jwt]

    test "renders post when data is valid", %{conn: conn} do
      conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert %{
        "content" => "The whole text for the blog post goes here in this key",
        "title" => "Latest updates, August 1st"
      } = json_response(conn, 201)
    end

    test "renders errors when no title is provided", %{conn: conn} do
      invalid_attrs = %{
        content: "The whole text for the blog post goes here in this key"
      }
      conn = post(conn, Routes.post_path(conn, :create), post: invalid_attrs)
      assert %{"errors" => %{"title" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders errors when no content is provided", %{conn: conn} do
      invalid_attrs = %{
        title: "Latest updates, August 1st"
      }
      conn = post(conn, Routes.post_path(conn, :create), post: invalid_attrs)
      assert %{"errors" => %{"content" => ["can't be blank"]}} = json_response(conn, 400)
    end

    test "renders errors when jwt is invalid", %{conn: conn} do
      conn =
        build_conn()
        |> put_invalid_jwt_header()
        |> post(Routes.post_path(conn, :create), post: @create_attrs)
      assert %{"message" => "Token expirado ou invalido"} = json_response(conn, 401)
    end

    test "renders errors when jwt is missing", %{conn: conn} do
      conn =
        build_conn()
        |> post(Routes.post_path(conn, :create), post: @create_attrs)
      assert %{"message" => "Token nao encontrado"} = json_response(conn, 401)
    end
  end

  describe "list posts" do
    setup [:add_2_posts]

    test "renders all posts", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :index))

      assert %{
        "data" => [
          %{
            "content" => "The whole text for the blog post goes here in this key",
            "title" => "Latest updates, August 1st",
            "user" => %{
              "displayName" => "rubens silva",
              "email" => "rubens@email.com",
              "image" => "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png"
            }
          },
          %{
            "content" => "blablabla",
            "title" => "titulo",
            "user" => %{
              "displayName" => "rubens silva",
              "email" => "rubens@email.com",
              "image" => "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png"
            }
          }
        ]
      } = json_response(conn, 200)
    end

    test "renders errors when jwt is invalid", %{conn: conn} do
      conn =
        build_conn()
        |> put_invalid_jwt_header()
        |> get(Routes.post_path(conn, :index))
      assert %{"message" => "Token expirado ou invalido"} = json_response(conn, 401)
    end

    test "renders errors when jwt is missing", %{conn: conn} do
      conn =
        build_conn()
        |> get(Routes.post_path(conn, :index))
      assert %{"message" => "Token nao encontrado"} = json_response(conn, 401)
    end
  end

  describe "get post by id" do
    setup [:add_post_id]

    test "renders post info", %{conn: conn, id: id} do
      conn = get(conn, Routes.post_path(conn, :show, id))
      assert %{
        "data" => %{
          "content" => "The whole text for the blog post goes here in this key",
          "title" => "Latest updates, August 1st",
          "user" => %{
            "displayName" => "rubens silva",
            "email" => "rubens@email.com",
            "image" => "http://4.bp.blogspot.com/_YA50adQ-7vQ/S1gfR_6ufpI/AAAAAAAAAAk/1ErJGgRWZDg/S45/brett.png"
          }
        }
      } = json_response(conn, 200)
    end

    test "renders errors when post doesn't exist", %{conn: conn, id: id} do
      invalid_id = id + 1
      conn = get(conn, Routes.post_path(conn, :show, invalid_id))
      assert %{"message" => "Post nao existe"} = json_response(conn, 404)
    end

    test "renders errors when jwt is invalid", %{conn: conn, id: id} do
      conn =
        build_conn()
        |> put_invalid_jwt_header()
        |> get(Routes.post_path(conn, :show, id))

      assert %{"message" => "Token expirado ou invalido"} = json_response(conn, 401)
    end

    test "renders errors when jwt is missing", %{conn: conn, id: id} do
      conn =
        build_conn()
        |> get(Routes.post_path(conn, :show, id))
      assert %{"message" => "Token nao encontrado"} = json_response(conn, 401)
    end
  end

  # describe "update post" do
  #   setup [:create_post]

  #   test "renders post when data is valid", %{conn: conn, post: %Post{id: id} = post} do
  #     conn = put(conn, Routes.post_path(conn, :update, post), post: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.post_path(conn, :show, id))

  #     assert %{
  #              "id" => ^id,
  #              "content" => "some updated content",
  #              "published" => "2022-02-22T18:51:00",
  #              "title" => "some updated title",
  #              "updated" => "2022-02-22T18:51:00"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, post: post} do
  #     conn = put(conn, Routes.post_path(conn, :update, post), post: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete post" do
  #   setup [:create_post]

  #   test "deletes chosen post", %{conn: conn, post: post} do
  #     conn = delete(conn, Routes.post_path(conn, :delete, post))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.post_path(conn, :show, post))
  #     end
  #   end
  # end

  # defp create_post(_) do
  #   post = post_fixture()
  #   %{post: post}
  # end

  defp add_user_jwt %{conn: conn} do
    jwt =
      conn
      |> post(Routes.user_path(conn, :create), user: @user_create_attrs)
      |> get_jwt_from_conn_response()

    conn =
      build_conn()
      |> put_valid_jwt_header(jwt)

    {:ok, conn: conn}
  end

  defp add_post %{conn: conn} do
    {:ok, conn: conn} = add_user_jwt(%{conn: conn})
    conn = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
    {:ok, conn: conn}
  end

  defp add_post_id %{conn: conn} do
    {:ok, conn: conn} = add_post(%{conn: conn})
    conn = get(conn, Routes.post_path(conn, :index))
    %{"data" => [%{"id" => id}]} = json_response(conn, 200)
    {:ok, conn: conn, id: id}
  end

  defp add_2_posts %{conn: conn} do
    {:ok, conn: conn} = add_post(%{conn: conn})
    conn = post(conn, Routes.post_path(conn, :create), post: @update_attrs)
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
