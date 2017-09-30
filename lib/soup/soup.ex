defmodule Soup.Soup do
  alias Soup.Scraper

  @config_file "~/.soup"

  def enter_select_location_flow() do
    IO.puts("One moment while I fetch the link of locations...")
    case Scraper.get_locations() do
      {:ok, locations} ->
        {:ok, location } = ask_user_to_select_location(locations)
        display_soup_list(location)
      :error ->
        IO.puts("An unexpected error occurred. Please try again.")
    end
  end

  def ask_user_to_select_location(locations) do
    locations
    |> Enum.with_index(1)
    |> Enum.each(fn({location, index}) -> IO.puts " #{index} - #{location.name}" end)

    case IO.gets("Select a location number: ") |> Integer.parse() do
      :error ->
        IO.puts("Invalid selection. Try again.")
        ask_user_to_select_location(locations)

      {location_nb, _} ->
        case Enum.at(locations, location_nb - 1) do
          nil ->
            IO.puts("Invalid location number. Try again.")
            ask_user_to_select_location(locations)

          location ->
            IO.puts("You've selected the #{location.name} location.")
            File.write!(Path.expand(@config_file), to_string(:erlang.term_to_binary(location)))
            {:ok, location}
        end
    end
  end

  def display_soup_list(location) do
    IO.puts("One moment while I fetch today's soup list for #{location.name}.")
    case Scraper.get_soups(location.id) do
      {:ok, soups} ->
        Enum.each(soups, &(IO.puts " - " <> &1))
      _ ->
        IO.puts("Unexpected error. Try again, or select a location using `soup --locations`")
    end
  end

  def get_saved_location() do
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

  def fetch_soup_list() do
    case get_saved_location() do
      {:ok, location} ->
        display_soup_list(location)
      _ ->
        IO.puts("It looks like yo haven't selected a default location. Select one now:")
        enter_select_location_flow()
    end
  end
end
