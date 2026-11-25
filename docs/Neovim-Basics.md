# Neovim Basics

**The one rule to learn first:** press a prefix (usually `<Space>`) and "which-key" shows everything that prefix starts. You never have to memorize a flat list of keys.

Full generated keymap reference: [keys.md](keys.md) (regenerate with `scripts/keys.sh`
after config changes).

## Part 0 — what this preset changes

- **`jk` / `kj` exit insert mode** (Esc still works). In terminal buffers: `Esc` `Esc` or `jk`.
- **Arrow keys are disabled** — they print "Use h to move!!" until `hjkl` is automatic.
- **`-` opens the mini.files explorer** at the current directory; `q` closes it, and
  `<C-v>` / `<C-x>` open the file in a vertical / horizontal split instead.
  - The explorer is an *editable buffer*
- Everything else is stock: `i` / `a` / `A`, `u`, `:w`, `:q`, `:wq`, `/` `n` `N`.

**That is the whole first loop:** `-` → navigate → open → edit → `:wq`.

## Part 1 — moving and files

| Key | Moves |
| --- | --- |
| `w` / `b` / `e` | next word / previous word / to word end |
| `0` / `$` | line start / line end |
| `gg` / `G` | file top / file bottom |
| `H` `M` `L` | top / middle / bottom of the screen |
| `f{char}` | to the next `{char}` on the line (`F` backwards, `t{char}` one before) |
| `{` / `}` | previous / next paragraph |
| `gs` | **flash jump** — type `gs`, letters appear on targets, press the letter and you teleport. Replaces most mouse use |

Buffers:

- `<Space><Space>` — fuzzy-pick among open files (the muscle-memory winner)
- `:b name` jump by name · `:ls` list them · `:enew` new empty file
- `:q` closes a buffer; it stays around until nvim quits, so reopening is instant

Splits:

- `:vs` vertical split · `:sp` horizontal (or `<C-v>` / `<C-x>` in the explorer)
- `<C-h/j/k/l>` focus a split · `:q` closes it

## Part 2 — editing (the system you'll live in)

- **Search:** `/pattern`, `n` next, `N` previous, `Esc` clears the highlight.
  `*` searches the word under the cursor.
- **Visual:** `v` charwise, `V` linewise — then `y` copy, `d` delete, `c` change.
  Same logic as everywhere else.
- **Delete / cut:** `x` the character under the cursor · `d` + motion: `dd` line,
  `d$` to end of line, `d(` to the previous `(`, `di"` inside the quotes.
- **Copy / paste:** `y` + motion (`yy` = line) · `p` paste after the cursor · `P` before.
- **Change** = delete + insert in one keystroke: `cw` word, `cc` line, `C` to end of line.
- **Reindent:** `=` on a line, or `v`-select lines then `=`.
- **Text objects** — a unit of text to pair with any operator: `i"` inside quotes,
  `a"` around them, `ip` paragraph, `ib` braces, `i(` parens. `ci"`, `da(`, `yip`.
  - `daa"` delete around the **next** quote (`ii` = inside next — mini.ai)
  - `sd"` delete surrounding quotes, `sa(` add parens, `sr"` replace them,
    `sf"` find the next one (mini.surround)

## Part 3 — high leverage (learn these when curious)

Not needed to feel comfortable, but used constantly once they click:

- **Code intelligence** (LSP, attaches automatically for known file types):
  - `grd` definition (back with `<C-t>`) · `grr` references · `grn` rename · `gra` code actions
  - `gO` symbols in this file · `gW` symbols in the whole project
  - errors: `]d` / `[d` next / previous (a float pops up automatically) · `<Space>q` full list
- **Find anything:** `<Space>sf` files · `<Space>sg` grep the whole project ·
  `<Space>s.` recent files · `<Space>/` fuzzy-find in the current file
- **Git:** the gutter shows `+ ~ _` on changed lines · `]c` / `[c` jump between your
  changes · `<Space>hs` stage this hunk · `<Space>hr` unstage · `<Space>gg` opens
  lazygit, a full git UI
- **Format:** `<Space>f` formats the file (automatic on save for lua / rust / c / cpp / python)
- **Ask the AI about some code:** `v`-select it, `ga` adds it to the AI chat (`<Space>aa`)

When parts 0–2 feel natural, go deeper in [Neovim-Workflows.md](Neovim-Workflows.md)
(plugin by plugin, with the advanced parts). The window manager side lives in
[Hyprland-Basics.md](Hyprland-Basics.md).
