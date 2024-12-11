return {
  "mfussenegger/nvim-dap",
  opts = {
    configurations = {
      python = {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
          return "/usr/bin/python3"
        end,
      },
    },
  },
}
