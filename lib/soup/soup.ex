defmodule Soup.Soup do
  alias Soup.Scraper

  @config_file "~/.soup"

  def enter_select_location_flow() do
    IO.puts("One moment while I fetch the link of locations...")

    Scraper.get_locations()
    |> ask_user_to_select_location()
  end

  def fetch_soup_list() do
    get_saved_location()
    |> use_saved_location()
  end

  # PRIVATE
  ###########################################################

  defp ask_user_to_select_location({:ok, locations}) do
    {:ok, location } = _ask_user_to_select_location(locations)
    display_soup_list(location)
  end
  defp ask_user_to_select_location(:error), do: IO.puts("An unexpected error occurred. Please try again.")

  defp _ask_user_to_select_location(locations) do
    locations
    |> Enum.with_index(1)
    |> Enum.each(fn({location, index}) -> IO.puts " #{index} - #{location.name}" end)

    IO.gets("Select a location number: ")
    |> Integer.parse()
    |> handle_location_selection(locations)
  end

  defp handle_location_selection(:error, locations) do
    IO.puts("Invalid selection. Try again.")
    _ask_user_to_select_location(locations)
  end

  defp handle_location_selection({location_nb, _}, locations) do
    Enum.at(locations, location_nb - 1)
    |> _handle_location_selection(locations)
  end

  defp _handle_location_selection(nil, locations) do
    IO.puts("Invalid location number. Try again.")
    _ask_user_to_select_location(locations)
  end

  defp _handle_location_selection(location, _locations) do
    IO.puts("You've selected the #{location.name} location.")
    File.write!(Path.expand(@config_file), to_string(:erlang.term_to_binary(location)))
    {:ok, location}
  end

  defp use_saved_location({:ok, location}), do: display_soup_list(location)

  defp use_saved_location(_) do
    IO.puts("It looks like yo haven't selected a default location. Select one now:")
    enter_select_location_flow()
  end

  defp display_soup_list(location) do
    IO.puts("One moment while I fetch today's soup list for #{location.name}.")
    case Scraper.get_soups(location.id) do
      {:ok, soups} ->
        Enum.each(soups, &(IO.puts " - " <> &1))
      _ ->
        IO.puts("Unexpected error. Try again, or select a location using `soup --locations`")
    end
  end

  defp get_saved_location() do
    case Path.expand(@config_file) |> File.read() do
      {:ok, location} ->
        try do
          location = :erlang.binary_to_term(location)

          case String.trim(location.id) do
            # File contains empty location ID
            "" -> {:empty_location_id}
            _ -> {:ok, location}
          end
        rescue
          e in ArgumentError -> e
        end

      {:error, _} -> :error
    end
  end
end
