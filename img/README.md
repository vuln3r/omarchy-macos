# Screenshots

Four shots, all in Osaka Jade, all of this repo - nothing from real work in
frame. The README expects exactly these names:

| File | What is in it |
|---|---|
| `desktop.png` | The whole screen: SketchyBar on top, two tiled windows, the jade border around the focused one |
| `terminal.png` | A Ghostty window: the fastfetch greeting, the Starship prompt with a git branch, `ls` and `lt` through eza |
| `lazygit.png` | `lazygit` in this repo |
| `btop.png` | `btop` |

Take them with the built-in tool - `-o` drops the drop shadow, so the window
does not float on a grey halo:

```sh
screencapture -o -w img/terminal.png   # click the window
screencapture -x img/desktop.png       # the whole screen
```

Retina shots come out at 2x, which is what GitHub wants. Check every shot for
paths, branch names and window titles from real projects before committing -
this repo is public.
