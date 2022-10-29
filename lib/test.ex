defmodule Test do
  alias Report
  alias Report.Parser
  # result
  # |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

  # {:ok, result}
  def test do
    # files = ["part_1.csv", "part_2.csv", "part_3.csv"]
    # |> Report.build_from_many()

    Report.full_report()
    
    
  end
end
