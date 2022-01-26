# chromium-ssh

This script creates an SSH SOCKS tunnel and starts the Chromium browser with the right parameters to use it. Up to two servers can be used for creating the tunnel (e.g. connection must go through a gateway server). Google Chrome can be used instead of Chromium.


## Prerequisites

To run the script properly, you need to install:
* `chromium-browser` or `google-chrome`,
* `notify-send` to print message on the GUI interface,
* `ssh-askpass` and `ssh-askpass-gnome` to enter passphrase or password on GUI.


## Files

The files available are:
* `chromium-ssh.sh`: the script which creates an SSH tunnel and starts the browser
* `icon/chromium-ssh.png`: a dedicated icon derived from the chromium browser icon


## Installation

To download the latest version of the files:
```
git clone https://github.com/fdchevalier/chromium-ssh
```

For convenience, the script should be accessible system-wide by either including the folder in your `$PATH` or by moving the script in a folder present in your path (e.g. `$HOME/local/bin/`).

To install the icon (optional):
```bash
[[ -d $HOME/.icons ]] || mkdir "$HOME/.icons"
cp icon/chromium-ssh.png "$HOME/.icons/"
```

## Usage

Run `./chromium-ssh -h` to list available options.

Few examples:
* Common usage: `chromium-ssh.sh -u user -s server`
* If a gateway server need to be contacted first: `chromium-ssh.sh -u user -s gateway_server server2`
* To use Google Chrome instead: `chromium-ssh.sh -u user -s server -b google-chrome`
