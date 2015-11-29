# Wifixir

Tool for generating connection scripts for wifi, connecting to them using basic
linux tools.

## Usage

First, set up your config file with the following content:

    config :wifixir,
      data_dir: Path.expand("<DEFAULT DATA FILE DIRECTORY>"),
      script_dir: Path.expand("<DEFAULT SCRIPT FILE DIRECTORY>"),
      interface: "<DEFAULT WIFI INTERFACE>",
      template_dir: Path.expand("<PATH TO THE WIFIXIR TEMPLATES>")

Having done so, use the tool as follows:

wifixir -s/--ssid <SSID> -p/--passphrase <PASSPHRASE> <files basename>

The files basename should be descriptive, as it's what you will use to connect
when the script is generated.

### Example

    wifixir --ssid neighbourswifi --passphrase waytooeasytoguess wifi-neighbour

This will generate a script called 'wifi-neighbour.sh' and executing this script
will connect to the wifi in question, using a conf-file called 'wifi-neighbour.conf'
placed in the data dir.

It's a good idea to add the script dir to your path, so that you can execute
the scripts from anywhere on your system.

