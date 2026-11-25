# Neovim Workflows — plugin by plugin

How each part of this config is actually used, with the advanced bits where they're
worth it. "Basic" and "advanced" are skewed for beginners: barely-used plugins get
only a basic section.

Full generated keymap reference: [keys.md](keys.md).

## The daily loop

1. `nvim file` — or `-` to open the explorer and pick it.
2. Edit normally (Basics parts 0–2).
3. `:w` — for lua / rust / c / cpp / python the formatter runs automatically on save.
4. Gutter signs (`+ ~ _`) mark your git changes: `]c` jumps between them,
   `<Space>hs` stages the hunk under the cursor.
5. `<Space>gg` opens lazygit → commit / push.
6. Stuck? `v`-select the confusing code and `ga` to ask the AI about it (below).

## Telescope — the finders (basic + advanced)

**Basic** — `<Space>s` is the search prefix; pause after it and the menu lists the rest:

| Key | Finds |
| --- | --- |
| `<Space>sf` | files in the project |
| `<Space>sg` | grep the whole project for typed text |
| `<Space>sw` | the word under the cursor (also from visual mode) |
| `<Space>s.` | recently opened files |
| `<Space>sc` | vim commands, fuzzy |
| `<Space><Space>` | already-open buffers |

In any picker: type to filter, Enter opens, `Esc` closes, and `?` lists that picker's
own keymaps (window movement, delete, preview toggles…).

**Advanced:** `<Space>s/` grep only open files · `<Space>/` fuzzy-find inside the current
buffer · `<Space>sh` search help text · `<Space>sk` search keymaps (the fastest way to
learn a binding) · `<Space>sd` jump to diagnostics · `<Space>sr` resume the last picker ·
`<Space>sn` find files inside this nvim config. In code files the LSP pickers join the
family: `grd` definition, `grr` references, `gri` implementations, `grt` type definition,
`gO` file symbols, `gW` project symbols — all jump back with `<C-t>`.

## LSP + completion (basic + advanced)

Language servers install themselves via mason on first run and attach to known file
types automatically (lua, rust, python via ruff/ty, c/cpp via clangd, bash, yaml).
Completion is blink.cmp — no setup, no keys to learn:

**Basic**

- just type — a menu appears. `Enter` accepts, `Tab` / `<S-Tab>` jump between snippet
  fields, `Esc` dismisses. A community snippet pack is included (type `fun`, Tab,
  get a function skeleton).
- `grd` go to definition (back with `<C-t>`) · `grn` rename symbol · `gra` code
  actions (the fix-it / organize-imports / refactor menu)
- errors: squiggle under the line; `]d` / `[d` step through them (a float pops up
  automatically), `<Space>q` opens the full list

**Advanced**

- `grr` references · `gri` implementations · `grt` type definition · `grD` declaration
- `gO` document symbols · `gW` workspace symbols
- `K` hover docs (nvim built-in) · `<C-S>` signature help while typing
  (insert/visual) · `gx` open the URI under the cursor (nvim built-in)
- `<Space>th` toggle inlay hints · `:Mason` browse/install servers and tools
- the statusline shows a little spinner (fidget) while an LSP works

## Gitsigns + lazygit (basic + advanced)

**Basic**

- gutter signs on changed lines: `+` added, `~` changed, `_` deleted
- `]c` / `[c` jump to next / previous hunk
- `<Space>hs` stage the hunk under the cursor (or `v`-select lines first) ·
  `<Space>hr` unstage
- `<Space>gg` opens **lazygit**, a full git TUI — commit, push, rebase, browse branches;
  `?` inside it shows its own keys

**Advanced**

- `<Space>hS` / `<Space>hR` stage / reset the whole buffer
- `<Space>hp` preview the hunk · `<Space>hi` preview inline
- `<Space>hb` blame the line · `<Space>tb` toggle trailing blame on every line
- `<Space>tw` toggle intra-line word diff
- `ih` is a text object = the whole hunk (`dih` deletes it, `vih` selects it)
- `<Space>hd` / `<Space>hD` diff the file against the index / last commit
- `<Space>hq` / `<Space>hQ` quickfix list of all hunks (this file / whole repo)

## The mini.nvim suite (basic + advanced)

**Basic**

- **mini.files** — the explorer, already covered in Basics: `-` opens it, and the
  list is an editable buffer (rename = edit the line, delete = `dd`, copy = `y` + `p`).
- **mini.surround** — operate on the quotes/brackets/parens *around* code:
  `sd"` delete surrounding quotes, `sa(` add parens, `sr"` replace them,
  `sf"` / `sF"` find the next / previous one, `sh"` highlight it.
- **g[` / `g]`** jump to the matching bracket's edge (mini.ai).

**Advanced**

- **mini.ai** next/last text objects: `daa(` delete around the *next* paren,
  `dii"` inside the next quote — `aa`/`ii` = next, `al`/`il` = last.
- **treesitter selection** (in code files): `gS` flash-select a syntax node (keeps
  pressing it zooms in); `an`/`in` select the parent/child node, `[n`/`]n` walk nodes.
- **mini.statusline** — the bottom line: git branch, diagnostics, file info. No keys.

## CodeCompanion — the AI (basic + advanced)

Non-standard in the sense that it needs a backend: a local OpenAI-compatible server
(default: llama.cpp). It's the only plugin with real setup.

**Setup (once per machine)**

1. Set `NVIM_AI_URL`, `NVIM_AI_API_KEY`, `NVIM_AI_MODEL_NAME` in your shell config —
   the template lives in `nvim/.env.example`.
2. Start your inference server.
3. Done — the chat talks to it.

**Basic**

- `<Space>aa` toggle the AI chat panel; type a question, Enter
- `v`-select code, `ga` → the selection is added to the chat as context
- keep questions scoped: small selection + "explain / fix / test this" beats pasting a file

**Advanced**

- `<Space>ac` opens the actions menu (explain, fix, generate tests, …)
- typing `cc` in command mode abbreviates to `CodeCompanion` (e.g. `ccInline`)
- the chat persists across buffers; the server stays up until you stop it
  (on the desktop, idle timers in `hypr/hypridle.conf` handle the machine, not the server)

## Markdown (basic only)

Two plugins, zero setup, one key between them:

- **In-buffer — render-markdown:** a `.md` file *displays* rendered while you edit —
  styled headings, tables, quotes, callouts (GitHub & Obsidian style), checkboxes,
  code blocks with language icons, even LaTeX formulas — and the line you're on
  flips to raw the moment you start typing, back to rendered when you leave insert
  mode. Just open the file.
- **Browser — markdown-preview.nvim:** `<Space>mp` toggles a GitHub-styled dark-theme
  preview in your browser (markdown files only) — the "really well" view for
  reviewing a whole doc or sharing it. The tab stays open when you switch buffers.

## The small ones (basic only)

| Plugin | What you actually use |
| --- | --- |
| **which-key** | press a prefix, pause, read the popup. That is the whole plugin. |
| **flash** | `gs` jump to anywhere in two keystrokes (letters appear on targets) · `gS` select syntax nodes the same way |
| **conform** | `<Space>f` format now; automatic on save for lua / rust / c / cpp / python |
| **cendre** | the theme. No keys. |
| **fidget** | the little statusline spinner = LSP/mason busy |
| **guess-indent / autopairs / treesitter / friendly-snippets** | no keys at all — tabs match the file, brackets close themselves, syntax highlights, and snippet completions arrive as you type |
