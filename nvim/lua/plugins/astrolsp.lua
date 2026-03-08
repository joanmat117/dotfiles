return {
  "AstroNvim/astrolsp",
  opts = {
    config = {
      vtsls = {
        settings = {
          typescript = { updateImportsOnFileMove = { enabled = "always" } },
          javascript = { updateImportsOnFileMove = { enabled = "always" } },
        },
      },
    },
  },
}
