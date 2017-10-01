defmodule Soup.CLI do

  @options [
    strict: [help: :boolean, locations: :boolean],
    alias: [h: :help],
  ]

  def main(argv) do
    argv
    |> parse_args()
    |> process()
  end

  def parse_args(argv) do
    argv
    |>  OptionParser.parse(@options)
    |> _parse_args()
  end

  def process(:help) do
    IO.puts """

    soup --locations # Select a default locationi whose soups you want to list
    soup             # List the soups for a default location (you'll be prompted to select a default location if you haven't already)

    """
    System.halt(0)
  end

  def process(:list_locations) do
    Soup.enter_select_location_flow()
  end

  def process(:list_soups) do
    Soup.fetch_soup_list()
  end

  def process(:invalid_arg) do
    IO.puts "Invalid argument(s) passed. See usage below:"
    process(:help)
  end

  #############################################################

  defp _parse_args({[help: true], _, _}), do: :help
  defp _parse_args({[],[],[{"-h", nil}]}), do: :help
  defp _parse_args({[locations: true], _, _}), do: :list_locations
  defp _parse_args({[], [], []}), do: :list_soups
  defp _parse_args(_), do: :invalid_arg
end
