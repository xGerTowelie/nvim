-- Setup LSP configuration (to install use :Mason)
-- https://github.com/neovim/nvim-lspconfig
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	config = function(event)
		require("lspconfig").lua_ls.setup {}
		require("lspconfig").ts_ls.setup {}
		require("lspconfig").html.setup {}
		require("lspconfig").helm_ls.setup {}

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup('group-lsp-attach', { clear = true }),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)

				if not client then
					print("No LSP client found")
					return
				end

				local map = function(keys, func, desc)
					vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
				end

				map('<leader>ld', require('telescope.builtin').lsp_definitions, '[L]SP [D]efinition')
				map('<leader>lr', require('telescope.builtin').lsp_references, '[L]SP [R]eferences')
				map('<leader>li', require('telescope.builtin').lsp_implementations, '[L]SP [I]mplementation')
				map('<leader>lt', require('telescope.builtin').lsp_type_definitions, '[L]SP [T]ype')
				map('<leader>ls', require('telescope.builtin').lsp_document_symbols, '[L]SP [S]ymbols')
				map('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols,
					'[L]SP [Workspace] [S]ymbols')
				map('<leader>lr', vim.lsp.buf.rename, '[R]ename')
				map('<leader>la', vim.lsp.buf.code_action, '[L]SP [A]ction')
				map('K', vim.lsp.buf.hover, 'Hover Documentation')
				map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = args.buf,
						callback = function()
							vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
						end,
					})
				end

				if client.server_capabilities.documentHighlightProvider then
					local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
					vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd('LspDetach', {
						group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = event2.buf })
						end,
					})
				end

				if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
					map('<leader>lh', function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end, '[L]SP [H]ints')
				end
			end,
		})
	end,
}
