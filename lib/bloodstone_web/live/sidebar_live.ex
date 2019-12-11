defmodule BloodstoneWeb.SidebarLive do
  use Phoenix.LiveView
  alias BloodstoneWeb.PageController
  alias BloodstoneWeb.PageView
  def render(assigns) do 
    PageView.render("sidebar.html", assigns)
  end
  def mount(session, socket) do
    
    {:ok, assign(socket, current_path: "/", parent_path: "/")}
  end
  def handle_params(%{"path" => path_array, "ref" => ref}, _uri, socket) do
    path = Enum.join(path_array,"/")
    new_path = List.delete_at(path_array, -1)
                   |> Enum.join("/")

    is_hard_link = is_hard_link(socket)
    is_directory = is_directory(path)
    is_old_a_directory = is_directory(socket.assigns.current_path)
    is_new_path = is_new_path(socket.assigns.parent_path, new_path)
    
    version_list = get_version_list(socket, is_hard_link)
    content_list = get_content_list(socket, is_hard_link, is_old_a_directory, is_directory, is_new_path, ref, path)

    html = get_markdown(socket, ref, path, is_hard_link, is_directory)

    {:noreply, assign(socket,version_list: version_list, content_list: content_list, ref: ref, markdown: html, current_path: path, parent_path: new_path)}
  end

  def is_hard_link(socket) do
    case Map.fetch(socket.assigns, :version_list) do
      {:ok, _} -> false
      _ -> true
    end
  end

  def is_directory(path) do
    !String.contains?(path, ".md")
  end

  def is_new_path(current_path, new_path) do
    !String.equivalent?(current_path, new_path)
  end


  def get_version_list(socket, is_hard_link) do
    case is_hard_link do 
      true -> PageController.get_version_list()
      false -> socket.assigns.version_list
    end
  end

  def get_content_list(socket, is_hard_link, is_old_a_directory, is_directory, is_new_path, ref, path) do
    case is_hard_link do 
      true -> PageController.get_content_list(ref, path)
      false ->
        case is_directory do
          true -> PageController.get_content_list(ref, path)
          false -> 
            case !is_old_a_directory and !is_directory do
              true -> 
                case is_new_path do
                  true -> PageController.get_content_list(ref, path)
                  false -> socket.assigns.content_list
                end
              false -> PageController.get_content_list(ref, path) 
            end
        end

    end
  end
  
  def get_markdown(socket, ref, path, is_hard_link, is_directory) do
    case is_directory do
      false ->     
        markdown = generate_html(ref, path)
      true -> 
        case is_hard_link do
          true -> 
            {:ok, markdown, []} = Earmark.as_html("# Search Page")
            markdown
          false -> socket.assigns.markdown
        end
    end
  end

  def generate_html(ref, path) do
      {:ok, download_url} = PageController.get_download_url(ref, path)
      {:ok, markdown} = PageController.get_markdown(download_url)
      {:ok, html, []} = Earmark.as_html(markdown)
      html
  end

end