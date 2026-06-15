return {
	"rose-pine/neovim",
	name = "rose-pine",
    config = function ()
        require("rose-pine").setup({
            dark_variant = "main", -- main, moon, or dawn

            styles = {
                bold = true,
                italic = true,
                transparency = true,
            },

            highlight_groups = {
                -- Comment = { fg = "foam" },
                -- StatusLine = { fg = "love", bg = "love", blend = 15 },
                -- VertSplit = { fg = "muted", bg = "muted" },
                -- Visual = { fg = "base", bg = "text", inherit = false },
                NormalFloat = { bg = "none" },
            },
        })
    end
}
