defmodule Wifixir do
  alias IO.ANSI

  def main(args) do
    args |> parse_args |> process
  end

  defp parse_args(args) do
    OptionParser.parse(
    args,
    strict:
    [ssid: :string, password: :string],
    aliases: [s: :ssid, pw: :password])
  end

  defp print_unknown_arg({arg, _}) do
    IO.puts(arg)
  end

  def process([]) do
    IO.puts("No args given.")
  end

  def process({options, argv, []}) do
    IO.puts "SSID: #{options[:ssid]}"
    IO.puts "Password: #{options[:password]}"
  end

  def process({options, argv, errors}) do
    IO.puts "#{ANSI.red}The following switches are unknown:#{ANSI.reset}"
    Enum.each errors, &print_unknown_arg/1
  end
end
