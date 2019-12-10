defmodule BloodstoneWeb.PageController do
  use BloodstoneWeb, :controller

  def index(conn, _params) do
    route = Poison.decode!(~s( [
    {
      "type": "directory",
      "name": "world",
      "children": [
        {
          "type": "file",
          "name": "one.txt",
          "children":[]
        },
        {
          "type": "file",
          "name": "two.txt",
          "children":[]
        }
      ]
    },
    {
      "type": "file",
      "name": "README",
      "children": []
    }
  ]
))
IO.inspect route
    render(conn, "index.html", route: route)
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
    headers = ["Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    body
     |> Poison.decode!
     |> Map.fetch("download_url")
  end

  def get_markdown(url) do
    headers = ["Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    {:ok, body}
  end

  def get_version_list() do
    url = "https://api.github.com/repos/valehelle/srs/branches"
    headers = ["Accept": "Application/json; Charset=utf-8"]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url, headers)
    body
     |> Poison.decode!
  end
  
  def get_content_list(version, path) do
    url = "https://api.github.com/repos/valehelle/srs/contents/#{path}?ref=#{version}"
    headers = ["Accept": "Application/json; Charset=utf-8"]
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



