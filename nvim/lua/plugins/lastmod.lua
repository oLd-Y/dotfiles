-- ~/.config/nvim/lua/plugins/lastmod.lua
if true then
  return {}
end

return {
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "lastmod",
    dir = "",
    lazy = false,
    config = function()
      local M = {}
      -- Function to get timezone offset in ISO format
      local function get_timezone_offset()
        local now = os.time()
        local utc = os.time(os.date("!*t", now))
        local diff = os.difftime(now, utc)
        local h, m = math.modf(diff / 3600)
        m = math.abs(m * 60)

        -- Format timezone offset as +HH:MM or -HH:MM
        return string.format("%+03d:%02d", h, m)
      end

      -- Function to update lastmod in frontmatter
      local function update_lastmod()
        -- Get current buffer content
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

        -- Check if file has frontmatter (starts with ---)
        if lines[1] ~= "---" then
          return
        end

        -- Find the end of frontmatter
        local frontmatter_end = 0
        for i, line in ipairs(lines) do
          if i > 1 and line == "---" then
            frontmatter_end = i
            break
          end
        end

        if frontmatter_end == 0 then
          return
        end

        -- Get current timestamp in ISO 8601 format with timezone
        local timestamp = os.date("%Y-%m-%dT%H:%M:%S") .. get_timezone_offset()

        -- Look for existing lastmod line
        local lastmod_line = -1
        for i = 2, frontmatter_end - 1 do
          if lines[i]:match("^lastmod:") then
            lastmod_line = i
            break
          end
        end

        -- Update or insert lastmod
        if lastmod_line > 0 then
          -- Update existing lastmod
          vim.api.nvim_buf_set_lines(0, lastmod_line - 1, lastmod_line, false, { "lastmod: " .. timestamp })
        else
          -- Insert new lastmod before frontmatter end
          vim.api.nvim_buf_set_lines(0, frontmatter_end - 1, frontmatter_end - 1, false, { "lastmod: " .. timestamp })
        end
      end

      -- Create the autocommand group
      local group = vim.api.nvim_create_augroup("LastmodUpdate", { clear = true })

      -- Set up the autocommand for multiple file types
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = {
          "*.md", -- Markdown
          -- "*.mdx", -- MDX files
          -- "*.org", -- Org mode files
          -- "*.norg", -- Neorg files
          -- "*.wiki", -- Wiki files
          -- "*.tex", -- LaTeX files
          -- "*.rst", -- reStructuredText
          -- "*.adoc", -- AsciiDoc
        },
        group = group,
        callback = update_lastmod,
      })

      -- Add a command to manually update lastmod
      vim.api.nvim_create_user_command("UpdateLastmod", update_lastmod, {})
    end,
  },
}
