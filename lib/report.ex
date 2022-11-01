defmodule Report do
  alias Report.{Parser, Utils}

  @files_path "lib/assets/*.csv"
  @report_keys [:all_hours, :hours_per_month, :hours_per_year]

  def full_report(files_path \\ @files_path) do
    values =
      files_path
      |> Utils.read_directory()
      |> build_from_many()

    map = group_data(values)
    keys = get_keys(map)

    @report_keys
    |> wrap_values([
      all_hours(values),
      wrap_values(keys, reports_by(map, 3)),
      wrap_values(keys, reports_by(map, 4))
    ])
  end

  defp all_hours(values) do
    values
    |> Enum.reduce(build_map(values), fn [name, hours | _rest], acc ->
      Map.put(acc, name, acc["#{name}"] + hours)
    end)
  end

  defp build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.to_list()
  end

  defp build_from_many(file_names) do
    file_names
    |> Enum.reduce([], fn file, acc -> sum_values(acc, [file]) end)
    |> Enum.reduce([], fn file, acc -> acc ++ file end)
  end

  defp build_map(values, position \\ 0) do
    values
    |> Enum.reduce(%{}, fn element, acc ->
      Map.put(acc, Enum.at(element, position), 0)
    end)
  end

  defp get_keys(map), do: Map.keys(map)

  defp group_data(values) do
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

  defp read_async(file_name) do
    [result] =
      file_name
      |> Task.async_stream(&build/1)
      |> Enum.map(fn {:ok, result} -> result end)

    result
  end

  def reports_by(map, key_position) do
    map
    |> get_keys()
    |> Enum.map(fn key ->
      build = build_map(map["#{key}"], key_position)

      map["#{key}"]
      |> Enum.reduce(build, fn e, acc ->
        Map.put(acc, Enum.at(e, key_position), Enum.at(e, 1) + acc["#{Enum.at(e, key_position)}"])
      end)
    end)
  end

  defp sum_values(acc, file), do: List.insert_at(acc, 0, read_async(file))

  defp wrap_values(keys, list) do
    keys
    |> Stream.zip(list)
    |> Enum.into(%{})
  end
end
