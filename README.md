# lumerical-nixos

## Motivation
I needed to use Lumercial software for my master thesis.
There is no Lumerical package for NixOS at the moment being.
As spining Windows VM was not satisfying solution so I decided to explore possibility
of running it inside docker that I could later wrap in Nix expression for convient usge...  
  
...and here it is!

## How it works?
This repo contains dockerfile that builds ubuntu-based container.
During the build it runs bash scripts to install Lumerical and OpenConnect client.
Those scripts also contains functions for connecting to VPN and starting Lumerical launcher.

