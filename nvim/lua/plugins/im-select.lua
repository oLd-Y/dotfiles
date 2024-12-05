return {
  {
    "keaising/im-select.nvim",
    lazy = false,
    config = function()
      require("im_select").setup({
        default_im_select = 1033,

        default_command = "im-select.exe",
      })
    end,
  },
}
