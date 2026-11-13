local bonsai = {
    [[                                     &                            ]],
    [[                                 &&&&&&&                          ]],
    [[                               & &&&&&&&&                         ]],
    [[                              & &&&&&&&&&                         ]],
    [[                             && &&/&&&&~|\ &                      ]],
    [[                     &&      &   &  &&&&||/&&&&                   ]],
    [[                     && &&       &&//~ &/|\&&                     ]],
    [[                    & &&&&|     \| \|   |/ &                      ]],
    [[                       &  &_&&\|\ \_|/|/~                         ]],
    [[                       &  &&   \__|/|/~     &&&                   ]],
    [[                            &    /|/|\     &&&&                   ]],
    [[            & &               \| ||/~/     /&&&&                  ]],
    [[          &  && &&            _//|/  /_/___/&&&&&&                ]],
    [[            &&&&&_&|         &/|/~            &&&                 ]],
    [[             & &&&&\| &  &   \/~/~           &                    ]],
    [[                   &&&_&& &&&/~~||                                ]],
    [[                     & \__    \ /~\|                              ]],
    [[                        /|\_\__   \/~                             ]],
    [[                        \__      ///~                             ]],
    [[                   :___________./~~~\.___________:                ]],
    [[                    \                           /                 ]],
    [[                     \_________________________/                  ]],
    [[                     (_)                     (_)                  ]],
    [[                               ネオビム                            ]],
    [[                                                                  ]],
}

local shortcuts = {
  { key = "d", desc = "Dotfiles (nixos)", action = function()
      vim.cmd.cd(vim.fn.expand("~/nixos-config"))
      vim.cmd("Telescope find_files")
    end },
  { key = "f", desc = "Search CWD", action = function()
      vim.cmd("Telescope find_files")
    end },
  { key = "q", desc = "Quit", action = function() vim.cmd("quit") end },
}

local function recent_files(limit)
  local out = {}
  for _, f in ipairs(vim.v.oldfiles) do
    if vim.fn.filereadable(f) == 1 then
      table.insert(out, f)
      if #out >= limit then break end
    end
  end
  return out
end

local function open_dashboard()
  local buf = vim.api.nvim_get_current_buf()
  local lines, actions = {}, {}

  vim.list_extend(lines, bonsai)
  table.insert(lines, "")

  for _, s in ipairs(shortcuts) do
    table.insert(lines, string.format("[%s]  %s", s.key, s.desc))
    actions[s.key] = s.action
  end

  local recent = recent_files(5)
  if #recent > 0 then
    table.insert(lines, "")
    table.insert(lines, "Recent")
    for i, f in ipairs(recent) do
      table.insert(lines, string.format("[%d]  %s", i, vim.fn.fnamemodify(f, ":~")))
      actions[tostring(i)] = function() vim.cmd.edit(vim.fn.fnameescape(f)) end
    end
  end

  -- Center the whole block (same left pad on every line keeps the art aligned)
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  local left = string.rep(" ", math.max(0, math.floor((vim.o.columns - width) / 2)))
  local top = math.max(0, math.floor((vim.o.lines - #lines) / 2))

  local out = {}
  for _ = 1, top do table.insert(out, "") end
  for _, l in ipairs(lines) do table.insert(out, left .. l) end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  -- Hide UI chrome while the dashboard is showing, restore when leaving it
  local win = vim.api.nvim_get_current_win()
  local saved = {
    number = vim.wo[win].number,
    relativenumber = vim.wo[win].relativenumber,
    signcolumn = vim.wo[win].signcolumn,
  }
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        for k, v in pairs(saved) do vim.wo[win][k] = v end
      end
    end,
  })

  for key, fn in pairs(actions) do
    vim.keymap.set("n", key, fn, { buffer = buf, nowait = true })
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Only when started with no args and an empty, unnamed buffer (not stdin)
    if vim.fn.argc() == 0
      and vim.api.nvim_buf_get_name(0) == ""
      and vim.fn.line2byte("$") == -1 then
      open_dashboard()
    end
  end,
})
