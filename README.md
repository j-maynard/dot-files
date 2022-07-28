# My Dot Files - version 2.0

This is a massivly trimmed down set of dot files.  Gone are the complex
install scripts for every version of Linux and MacOS I use.   Gone is my
old complex tmux setup, theme chooser and rest of it.  I have sacrificed
some speed for portability.  I've switched from Powerline10k to
oh-my-posh providing dot files for zsh, bash and Powershell.

On Linux the setup script installs in the users home directory lsd, bat,
yq, antibody (for zsh), fzf and makes a passing attempt to install the
1password CLI client.  On Macs the script does the same ting but uses
homebrew to install the same things.

# Requirements

The setup script will fail if it fails to find the following:

* git
* wget (Linux)

On macs the script will install brew if its missing.