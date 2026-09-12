-- ===========================================================================
--  Telescope (fayl qidiruv)
-- ===========================================================================

local telescope = require("telescope")
local actions = require("telescope.actions")

-- node_modules / .venv / target ichini umuman skanerlamaydi (ripgrep darajasida)
local ignore = {
  "node_modules", ".git", ".next", ".nuxt", "dist", "build", "out",
  "bin", "obj", "vendor", "target", "__pycache__", ".venv", "venv",
  ".mypy_cache", ".pytest_cache", ".gradle", ".idea", ".vscode",
  "coverage", ".turbo", ".cache",
}

local rg_globs = {}
for _, dir in ipairs(ignore) do
  table.insert(rg_globs, "--glob")
  table.insert(rg_globs, "!**/" .. dir .. "/*")
end

local vimgrep_arguments = {
  "rg",
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--smart-case",
  "--hidden",
}
vim.list_extend(vimgrep_arguments, rg_globs)

telescope.setup({
  defaults = {
    vimgrep_arguments = vimgrep_arguments,
    file_ignore_patterns = {
      "node_modules/", "%.git/", "%.next/", "dist/", "build/",
      "__pycache__/", "%.venv/", "venv/", "target/", "vendor/",
      "%.lock$", "%.png$", "%.jpg$", "%.jpeg$", "%.gif$", "%.ico$",
      "%.pdf$", "%.zip$", "%.jar$", "%.class$", "%.exe$", "%.dll$",
    },
    path_display = { "truncate" },
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<Esc>"] = actions.close,
      },
    },
    -- Katta fayl preview'da ochilmasin
    preview = {
      filesize_limit = 1, -- MB
      timeout = 250,
    },
  },
  pickers = {
    find_files = {
      hidden = true,
      find_command = vim.fn.executable("fd") == 1
          and vim.list_extend(
            { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden" },
            (function()
              local ex = {}
              for _, dir in ipairs(ignore) do
                table.insert(ex, "--exclude")
                table.insert(ex, dir)
              end
              return ex
            end)()
          )
          or nil,
    },
    buffers = {
      sort_mru = true,
      ignore_current_buffer = true,
    },
  },
})

local builtin = require("telescope.builtin")
local map = vim.keymap.set

map("n", "<leader>ff", builtin.find_files, { desc = "Fayl qidirish" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Matn bo'yicha qidirish" })
map("n", "<leader>fb", builtin.buffers, { desc = "Ochiq buffer'lar" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Yordam (help)" })
map("n", "<leader>fo", builtin.oldfiles, { desc = "Oxirgi ochilgan fayllar" })
map("n", "<leader>fw", builtin.grep_string, { desc = "Kursor ostidagi so'zni qidirish" })
map("n", "<leader>fd", builtin.diagnostics, { desc = "Barcha xatolar" })
map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Fayldagi funksiya/klasslar" })
