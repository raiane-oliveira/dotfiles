local ls = require("luasnip")
local snippet = ls.snippet
local text = ls.text_node
local insert = ls.insert_node

return {
  snippet("refc", {
    text({ "export function " }),
    insert(1, ""),
    text({ "() {", "\treturn (", "\t" }),
    insert(2, ""),
    text({ "\t", "  )", "}" }),
  }),
}
