defmodule Report do
  alias Report.Parser
  @files ["part_1.csv", "part_2.csv", "part_3.csv"]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.to_list()
  end

  def build_from_many(file_names) do
    file_names
    |> Enum.reduce([], fn file, acc -> sum_values(acc, [file]) end)
    |> Enum.reduce([], fn file, acc -> acc ++ file end)
  end

  def sum_values(acc, file), do: List.insert_at(acc, 0, read_async(file))

  def read_async(file_name) do
    [result] =
      file_name
      |> Task.async_stream(&build/1)
      |> Enum.map(fn {:ok, result} -> result end)

    result
  end

  def full_report(files_list \\ @files) do
    values = build_from_many(files_list)
    all = all_hours(values)
    map = group_data(values)
    # header_keys
    keys = get_keys(map)
    by_month = reports_by(map, 3)
    by_year = reports_by(map, 4)

    %{
      all_hours: all,
      hours_per_month: header_keys(keys, by_month),
      hours_per_year: header_keys(keys, by_year)
    }
  end

  def all_hours(values) do
    values
    |> Enum.reduce(build_map(values), fn [name, hours | _rest], acc ->
      Map.put(acc, name, acc["#{name}"] + hours)
    end)
  end

  def build_map(values, position \\ 0) do
    values
    |> Enum.reduce(%{}, fn element, acc ->
      Map.put(acc, Enum.at(element, position), 0)
    end)
  end

  def group_data(values) do
    values
    |> Stream.map(fn e -> month_to_name(e, Enum.at(e, 3)) end)
    |> Enum.group_by(&List.first(&1, ""))
  end

  defp month_to_name(list, month) do
    list
    |> List.update_at(3, fn _ ->
      String.replace(month, month, DateHelpers.month_to_string(month))
    end)
  end

  defp get_keys(map), do: Map.keys(map)

  def reports_by(map, key_position) do
    map
    |> get_keys()
    |> Enum.map(fn key ->
      person = map["#{key}"]
      build = build_map(person, key_position)

      Enum.reduce(person, build, fn e, acc ->
        Map.put(acc, Enum.at(e, key_position), Enum.at(e, 1) + acc["#{Enum.at(e, key_position)}"])
      end)
    end)
  end

  defp header_keys(keys, list) do
    keys
    |> Enum.zip(list)
    |> Enum.into(%{})
  end
end
