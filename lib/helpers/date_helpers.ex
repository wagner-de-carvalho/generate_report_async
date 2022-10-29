defmodule DateHelpers do
  def month_to_string(day) do
    month = String.to_integer(day) - 1

    [
      "janeiro",
      "fevereiro",
      "março",
      "abril",
      "maio",
      "junho",
      "julho",
      "agosto",
      "setembro",
      "outubro",
      "novembro",
      "dezembro"
    ]
    |> Enum.at(month)
  end
end
