defmodule Wifixir do
  alias IO.ANSI
  import Elixir.EEx, only: [eval_file: 2]

  def main(args) do
    args |> parse_args |> process
  end

  defp parse_args(args) do
    OptionParser.parse(args, strict:
                       [ssid: :string, passphrase: :string, help: :boolean],
                       aliases: [s: :ssid, p: :passphrase, h: :help])
  end

  defp env(keyword) do
    Application.get_env :wifixir, keyword
  end

  defp make_file_paths(argv, script_dir, data_dir) do
    output_name = Enum.join argv, " "
    script_file = Path.join script_dir, output_name <> ".sh"
    data_file = Path.join data_dir, output_name <> ".conf"
    {script_file, data_file}
  end

  defp create_dirs(script_dir, data_dir) do
    File.mkdir_p script_dir
    File.mkdir_p data_dir
  end

  def process([]) do
    IO.puts("#{ANSI.red}No args given.#{ANSI.reset}")
  end

  def process({options, argv, []}) do
    script_dir = Path.expand("~/.config/wifixir/script") || env :script_dir
    data_dir = Path.expand("~/.config/wifixir/data") || env :data_dir
    create_dirs script_dir, data_dir

    ssid = options[:ssid]
    passphrase = options[:passphrase]
    interface = options[:interface] || env :interface

    {script_file, data_file} = make_file_paths argv, script_dir, data_dir
    script_write script_file, interface, data_file
    data_write data_file, run_wpa_passphrase(ssid, passphrase)

    :ok = File.chmod script_file, 0o700
    :ok = File.chmod data_file, 0o700

    IO.puts "Wrote script to #{script_file} and data to #{data_file}."
  end

  def process({_options, _argv, errors}) do
    IO.puts "#{ANSI.red}The following switches are unknown:#{ANSI.reset}"
    Enum.each errors, fn {arg, _} -> IO.puts arg end
  end

  def run_wpa_passphrase(ssid, passphrase) do
    port = Port.open(
      {:spawn, "wpa_passphrase #{ssid} #{passphrase}"},
      [:stderr_to_stdout])

    receive do
      {^port, {:data, wpa_output}} -> wpa_output
    end
  end

  def script_write(path, interface, data_file) do
    template_file = Path.join(env(:template_dir), "script.eex")
    template_output = eval_file(template_file, [interface: interface,
                                                data_filename: data_file])
    :ok = File.write path, template_output
  end

  def data_write(path, wpa_passphrase_output) do
    template_file = Path.join(env(:template_dir), "data.eex")
    template_output = eval_file(template_file,
                                [wpa_passphrase_output: wpa_passphrase_output])
    :ok = File.write path, template_output
  end
end
