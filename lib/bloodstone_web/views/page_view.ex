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
end
