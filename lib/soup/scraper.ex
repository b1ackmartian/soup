defmodule Soup.Scraper do

  def get_locations() do
    "https://www.haleandhearty.com/locations/"
    |> HTTPoison.get()
    |> handle_locations_response()
  end

  def get_soups(location_id) do
    "https://www.haleandhearty.com/menu/?location=#{location_id}"
    |> HTTPoison.get()
    |> handle_soups_response()
  end

  # PRIVATE
  ################################################################

  defp extract_location_name_and_id({_tag, attrs, children}) do
    {_, _, [name]} =
      Floki.raw_html(children)
      |> Floki.find(".location-card__name")
      |> hd()

    attrs = Enum.into(attrs, %{})
    %{id: attrs["id"], name: name}
  end

  defp handle_locations_response({:ok, response}), do: _handle_locations_response(response)
  defp handle_locations_response(_), do: :error

  defp _handle_locations_response(response = %{status_code: 200}) do
    locations =
      response.body
      |> Floki.find(".location-card")
      |> Enum.map(&extract_location_name_and_id/1)
      |> Enum.sort(&(&1.name < &2.name))

    {:ok, locations}
  end
  defp _handle_locations_response(_), do: :error

  defp handle_soups_response({:ok, response}), do: _handle_soups_response(response)
  defp handle_soups_response(_), do: :error

  defp _handle_soups_response(response = %{status_code: 200}) do
    soups =
      response.body
      # Floki uses the CSS descendant selector for the below find() call
      |> Floki.find("div.category.soups p.menu-item__name")
      |> Enum.map(fn({_, _, [soup]}) -> soup end)

    {:ok, soups}
  end
  defp _handle_soups_response(_), do: :error
end
