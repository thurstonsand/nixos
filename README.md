# Tips to Myself

If I need to investigate how a particular config entry rendered, I can use `eval`:

e.g.

```
❯ nix eval .#nixosConfigurations.knownapps.config.programs.zsh.shellAliases
warning: Git tree '/home/thurstonsand/nixos' is dirty
{ l = "ls -alh"; ll = "ls -l"; ls = "ls --color=tty"; }
```