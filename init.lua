-- SPDX-License-Identifier: GPL-3.0-or-later

local prefix = "packages.mini.pkg."

local minisp = require (prefix .. "minisp")
-- local mini_extreme = require (prefix .. "mini_extreme")
-- local mini_re = require (prefix .. "mini_re")

Fk:loadTranslationTable {
  ["mini"] = "小程序",
}

return {
  minisp,
  -- mini_extreme,
  -- mini_re,
}
