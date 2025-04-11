-- SPDX-License-Identifier: GPL-3.0-or-later

local prefix = "packages.mini.pkg."

local minisp = require (prefix .. "minisp")
local mini_extreme = require (prefix .. "mini_extreme")
-- local mini_re = require (prefix .. "mini_re")

Fk:loadTranslationTable {
  ["mini"] = "小程序",

  ["rhyme_skill"] = "<b>韵律技：</b><br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
  "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_moulue"] = "<b>谋略值：</b><br>谋略值上限为5，有谋略值的角色拥有技能<a href=':mini_miaoji'>〖妙计〗</a>。",
  ["zhuluPindian"] = "<b>逐鹿：</b><br>即“共同拼点”，所有目标角色一起拼点，至多有一个胜者，点数最大者有多人时视为无胜者。",
  ["MiniForceSkill"] = "<b>奋武技：</b><br>每轮使用次数为（本轮你造成和受到的伤害值）+1，且至多为5。",
}

return {
  minisp,
  mini_extreme,
  -- mini_re,
}
