defmodule BloodstoneWeb.PageController do
  use BloodstoneWeb, :controller
  alias Bloodstone.Accounts
  alias Bloodstone.Accounts.User

  def index(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "index.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do

    {:ok, email} = Map.fetch(user_params, "email")
    case String.equivalent?(email, "") do
      true -> 
        changeset = User.changeset(%User{})
        render(conn, "index.html", changeset: changeset)
      false ->
        Accounts.create_user(user_params)
        changeset = User.changeset(%User{})
        render(conn, "thank_you.html")
    end
  end

  def list_user(conn, _params) do
    users = Accounts.list_users()
    render(conn, "list_user.html", users: users)
  end

  def demo(conn, %{"path" => path_array, "ref" => ref}) do
    path = Enum.join(path_array,"/")
    version_list = get_version_list()
    content_list = get_content_list(ref, path)
    #{:ok, download_url} = get_download_url(ref, path)
    #{:ok, markdown} = get_markdown(download_url)
    {:ok, html, []} = Earmark.as_html("# Helo")
    render(conn, "demo.html", markdown: html, ref: ref, version_list: version_list, content_list: content_list)
  end

  def get_download_url(version,path) do
    url = "https://api.github.com/repos/valehelle/srs/contents/#{path}?ref=#{version}"
    headers = ["Authorization": "Bearer #{Application.get_env(:bloodstone, Bloodstone.Repo)[:github_key]}", "Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    body
     |> Poison.decode!
     |> Map.fetch("download_url")
  end

  def get_markdown(url) do
    headers = ["Authorization": "Bearer #{Application.get_env(:bloodstone, Bloodstone.Repo)[:github_key]}", "Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    {:ok, body}
  end

 
  def get_version_list() do
    url = "https://api.github.com/repos/valehelle/srs/branches"
    headers = ["Authorization": "Bearer #{Application.get_env(:bloodstone, Bloodstone.Repo)[:github_key]}", "Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    body
     |> Poison.decode!
  end
  
  def get_content_list(version, path) do
    url = "https://api.github.com/repos/valehelle/srs/contents/#{path}?ref=#{version}"
    headers = ["Authorization": "Bearer #{Application.get_env(:bloodstone, Bloodstone.Repo)[:github_key]}", "Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    body = Poison.decode!(body)
    case is_list(body) do
      true -> body
      false -> path_array = String.split(path, "/")
               {tail_path, head_path} = List.pop_at(path_array, length(path_array) - 1)
               get_content_list(version, Enum.join(head_path,"/"))
    end
  end
end



