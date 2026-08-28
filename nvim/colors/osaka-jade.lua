-- lyx-theme - Neovim (Osaka Jade)
-- Omarchy paints Neovim by pulling in LazyVim plus two plugins from GitHub.
-- The palette is 25 colors, so it is spelled out here instead - same reason
-- the Ghostty theme is spelled out: one file, no plugin manager, no network
-- on the first start.
-- Source: basecamp/omarchy themes/osaka-jade/colors.toml

local c = {
    bg         = "#111c18",
    bg_dark    = "#0c1512",
    bg_light   = "#23372b",
    fg         = "#c1c497",
    fg_dark    = "#81b8a8",
    fg_light   = "#d6d5bc",
    fg_bright  = "#f7e8b2",
    accent     = "#509475",
    selection  = "#32473b",
    muted      = "#53685b",
    red        = "#ff5345",
    orange     = "#a2734b",
    green      = "#549e6a",
    cyan       = "#2dd5b7",
    magenta    = "#d2689c",
    br_red     = "#db9f9c",
    br_yellow  = "#e5c736",
    br_green   = "#63b07a",
    br_cyan    = "#8cd3cb",
    br_blue    = "#acd4cf",
    br_magenta = "#75bbb3",
}

vim.cmd.highlight("clear")
vim.g.colors_name = "osaka-jade"
vim.o.background = "dark"

local hl = {
    -- Editor ----------------------------------------------------------------
    -- Normal has no background on purpose: that is what keeps Ghostty's
    -- transparency and blur visible behind the buffer.
    Normal       = { fg = c.fg },
    NormalFloat  = { fg = c.fg, bg = c.bg_dark },
    FloatBorder  = { fg = c.accent, bg = c.bg_dark },
    Cursor       = { fg = c.bg, bg = c.fg_bright },
    CursorLine   = { bg = c.bg_light },
    CursorLineNr = { fg = c.br_yellow, bold = true },
    LineNr       = { fg = c.muted },
    SignColumn   = { fg = c.muted },
    ColorColumn  = { bg = c.bg_light },
    Visual       = { bg = c.selection },
    Search       = { fg = c.bg, bg = c.br_yellow },
    IncSearch    = { fg = c.bg, bg = c.orange },
    CurSearch    = { fg = c.bg, bg = c.orange },
    MatchParen   = { fg = c.cyan, bold = true },
    Folded       = { fg = c.muted, bg = c.bg_dark },
    NonText      = { fg = c.muted },
    Whitespace   = { fg = c.selection },
    WinSeparator = { fg = c.selection },
    Directory    = { fg = c.accent },
    Title        = { fg = c.br_yellow, bold = true },
    StatusLine   = { fg = c.fg, bg = c.bg_light },
    StatusLineNC = { fg = c.muted, bg = c.bg_dark },
    TabLine      = { fg = c.muted, bg = c.bg_dark },
    TabLineSel   = { fg = c.bg, bg = c.accent },
    TabLineFill  = { bg = c.bg_dark },
    Pmenu        = { fg = c.fg, bg = c.bg_dark },
    PmenuSel     = { fg = c.bg, bg = c.accent },
    PmenuSbar    = { bg = c.bg_dark },
    PmenuThumb   = { bg = c.accent },
    WildMenu     = { fg = c.bg, bg = c.accent },
    ErrorMsg     = { fg = c.red },
    WarningMsg   = { fg = c.br_yellow },
    ModeMsg      = { fg = c.br_green },
    MoreMsg      = { fg = c.accent },
    Question     = { fg = c.accent },

    -- Syntax ----------------------------------------------------------------
    Comment      = { fg = c.muted, italic = true },
    Constant     = { fg = c.br_yellow },
    String       = { fg = c.br_green },
    Character    = { fg = c.br_green },
    Number       = { fg = c.br_yellow },
    Boolean      = { fg = c.br_yellow },
    Float        = { fg = c.br_yellow },
    Identifier   = { fg = c.fg },
    Function     = { fg = c.cyan },
    Statement    = { fg = c.magenta },
    Conditional  = { fg = c.magenta },
    Repeat       = { fg = c.magenta },
    Label        = { fg = c.magenta },
    Operator     = { fg = c.br_magenta },
    Keyword      = { fg = c.magenta },
    Exception    = { fg = c.red },
    PreProc      = { fg = c.br_magenta },
    Include      = { fg = c.br_magenta },
    Define       = { fg = c.br_magenta },
    Macro        = { fg = c.br_magenta },
    Type         = { fg = c.br_blue },
    StorageClass = { fg = c.br_blue },
    Structure    = { fg = c.br_blue },
    Typedef      = { fg = c.br_blue },
    Special      = { fg = c.orange },
    SpecialChar  = { fg = c.orange },
    Delimiter    = { fg = c.fg_dark },
    Underlined   = { fg = c.accent, underline = true },
    Todo         = { fg = c.bg, bg = c.br_yellow, bold = true },
    Error        = { fg = c.red },

    -- Treesitter. Everything else falls back to the groups above. ----------
    ["@variable"]         = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.br_red },
    ["@property"]         = { fg = c.fg_dark },
    ["@field"]            = { fg = c.fg_dark },
    ["@parameter"]        = { fg = c.fg_light },
    ["@constructor"]      = { fg = c.br_blue },
    ["@tag"]              = { fg = c.magenta },
    ["@tag.attribute"]    = { fg = c.br_cyan },
    ["@punctuation"]      = { fg = c.fg_dark },
    ["@markup.heading"]   = { fg = c.br_yellow, bold = true },
    ["@markup.link"]      = { fg = c.accent, underline = true },
    ["@markup.raw"]       = { fg = c.br_green },

    -- Diagnostics and LSP ---------------------------------------------------
    DiagnosticError          = { fg = c.red },
    DiagnosticWarn           = { fg = c.br_yellow },
    DiagnosticInfo           = { fg = c.cyan },
    DiagnosticHint           = { fg = c.fg_dark },
    DiagnosticOk             = { fg = c.br_green },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn  = { sp = c.br_yellow, undercurl = true },
    DiagnosticUnderlineInfo  = { sp = c.cyan, undercurl = true },
    DiagnosticUnderlineHint  = { sp = c.fg_dark, undercurl = true },
    LspReferenceText         = { bg = c.selection },
    LspReferenceRead         = { bg = c.selection },
    LspReferenceWrite        = { bg = c.selection },

    -- Diff and git ----------------------------------------------------------
    DiffAdd     = { fg = c.br_green, bg = c.bg_dark },
    DiffChange  = { fg = c.br_blue, bg = c.bg_dark },
    DiffDelete  = { fg = c.red, bg = c.bg_dark },
    DiffText    = { fg = c.br_yellow, bg = c.selection },
    Added       = { fg = c.br_green },
    Changed     = { fg = c.br_blue },
    Removed     = { fg = c.red },
    diffAdded   = { fg = c.br_green },
    diffChanged = { fg = c.br_blue },
    diffRemoved = { fg = c.red },
}

for group, spec in pairs(hl) do
    vim.api.nvim_set_hl(0, group, spec)
end

-- The 16 terminal colors Neovim hands to :terminal buffers.
local term = {
    c.bg_dark, c.red, c.green, c.br_yellow, c.accent, c.magenta, c.cyan, c.fg,
    c.muted, c.br_red, c.br_green, c.br_yellow, c.br_blue, c.br_magenta, c.br_cyan, c.fg_light,
}
for i, color in ipairs(term) do
    vim.g["terminal_color_" .. (i - 1)] = color
end
