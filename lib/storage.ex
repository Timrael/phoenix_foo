defmodule PhoenixFoo.Storage do
  use GenServer
  import Logger

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  defp get_grouped_hotels(file_name) do
    File.stream!(file_name) |> CSV.decode
    |> Enum.reduce HashDict.new, fn [city_name, hotel_id, type, price], grouped_hotels ->
      if Dict.has_key?(grouped_hotels, city_name) do
        new_value = Dict.get(grouped_hotels, city_name)
        |> Enum.concat([%{
          city_name: city_name,
          hotel_id: hotel_id,
          type: type,
          price: String.to_integer(price)
          }])
      else
        new_value = []
      end

      Dict.put(grouped_hotels, city_name, new_value)
    end
  end

  def init(_) do
    grouped_hotels = get_grouped_hotels("hoteldb.csv")
    init_state = HashDict.new |> Dict.put("asc", HashDict.new) |> Dict.put("desc", HashDict.new)

    state = grouped_hotels
    |> Enum.reduce init_state, fn {city_name, hotels}, state ->
      asc_sorted_hotels = hotels |> Enum.sort(&(&1[:price] < &2[:price]))
      new_asc_state = Dict.get(state, "asc") |> Dict.put(city_name, asc_sorted_hotels)
      new_desc_state = Dict.get(state, "desc") |> Dict.put(city_name, Enum.reverse(asc_sorted_hotels))
      state = Dict.put(state, "asc", new_asc_state)
      Dict.put(state, "desc", new_desc_state)
    end
    {:ok, state}
  end

  def show(city_name, order) do
    GenServer.call(__MODULE__, {:show, city_name, order})
  end

  def handle_call({:show, city_name, order}, _from, state) do
    {:reply, (Dict.get(state, order) |> Dict.get(city_name, [])), state}
  end
end
