defmodule Soup do

  alias Soup.Soup

  defdelegate enter_select_location_flow(), to: Soup
  defdelegate fetch_soup_list(), to: Soup
end
