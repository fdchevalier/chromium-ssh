# chromium-ssh

This script creates an SSH tunnel and start the Chromium browser with the right parameters to use it.

## Prerequisites

To run the script properly, you need to install:
* `chromium-browser` to have an SSH server to connect to,
* `notify-send` to print message on the GUI interface,
* `ssh-askpass` and `ssh-askpass-gnome` to enter passphrase or password on GUI.

## Files

The files available are:
* `chromium-ssh.sh`: the script which creates an SSH tunnel and start chromiu
* `icon/chromium-ssh.png`: a dedicated icon derived from the chromium browser icon


## Installation

To download the latest version of the files:
```
git clone https://github.com/fdchevalier/
```

For convenience, the script should be accessible system-wide by either including the folder in your `$PATH` or by moving the script in a folder present in your path (e.g. `$HOME/local/bin/`).

To install the icon (optional):
```bash
[[ -d $HOME/.icons ]] || mkdir "$HOME/.icons"
cp icon/chromium-ssh.png "$HOME/.icons/"
```

## Usage

A summary of available options can be obtained using `./chromium-ssh -h`.

