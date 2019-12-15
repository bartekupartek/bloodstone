defmodule BloodstoneWeb.PageView do
  use BloodstoneWeb, :view
  def title(nodes, level) do
    for node <- nodes do
      children? = node["children"] != []
      content_tag(:li, class: "clsssass") do
        [Integer.to_string(level), title(node["children"], level + 1)]
      end
    end
  end
  def get_path(path) do
    String.split(path, "/")
    |> List.last()
  end
  def get_color(path, current_path) do
    case path == get_path(current_path) do
      true -> "white"
      false -> "#c1c3c9"
    end
  end
end
