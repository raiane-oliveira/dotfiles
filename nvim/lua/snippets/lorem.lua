local ls = require("luasnip")
local snippet = ls.snippet
local text = ls.text_node

return {
  snippet("lorem", {
    text({
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent at vestibulum nisi, et luctus sapien. Praesent nec turpis tortor. Sed eget dapibus felis, in pharetra ex. Nunc sed neque vitae nibh porta ornare vel vel justo. Fusce egestas, nibh id rhoncus egestas, dolor odio dapibus diam, ac ultrices nulla nulla eu nulla. Aenean euismod efficitur sem, nec cursus lorem accumsan in. Sed aliquam turpis et tellus imperdiet, at maximus nulla blandit. Nam finibus lorem risus, ut mollis lacus maximus id. ",
    }),
  }),
  snippet("lorem2", {
    text({
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent at vestibulum nisi, et luctus sapien. Praesent nec turpis tortor. Sed eget dapibus felis, in pharetra ex. Nunc sed neque vitae nibh porta ornare vel vel justo. Fusce egestas, nibh id rhoncus egestas, dolor odio dapibus diam, ac ultrices nulla nulla eu nulla. Aenean euismod efficitur sem, nec cursus lorem accumsan in. Sed aliquam turpis et tellus imperdiet, at maximus nulla blandit. Nam finibus lorem risus, ut mollis lacus maximus id. ",
      "\t",
      "Nulla tincidunt in augue non molestie. Pellentesque quis lacus ac urna sollicitudin tincidunt. Nunc condimentum nec ante vel condimentum. Duis dui tellus, mattis quis ex et, mollis lacinia diam. Etiam ac neque quis nisi condimentum efficitur eget a quam. Cras ultricies pretium pellentesque. Etiam imperdiet egestas diam non porttitor. Ut dui nisi, luctus et urna quis, pulvinar volutpat sapien. Nulla non augue consectetur, ornare ligula porta, finibus nisi. Mauris euismod justo est, sit amet facilisis tortor congue tincidunt. ",
    }),
  }),
}
