defmodule Report.Parser do
  # nome, quantidade de horas, dia, mês e ano.
  def parse_file(filename) do
    "lib/assets/#{filename}"
    |> File.stream!()
    |> Stream.map(fn line -> parse_line(line) end)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(~r/([,\n])/)
    |> List.update_at(1, &String.to_integer/1)
  end
end
