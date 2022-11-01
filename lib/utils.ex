defmodule Report.Utils do
  def read_directory(path) do
    Path.wildcard(path)
    |> Enum.map(&Path.basename/1)
  end
end
