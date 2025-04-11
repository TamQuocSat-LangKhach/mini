local miniexYingrui = fk.CreateSkill {
  name = "miniex__yingrui"
}

Fk:loadTranslationTable{
  ["miniex__yingrui"] = "英锐",
  [":miniex__yingrui"] = "摸牌阶段结束时，或当你杀死一名角色后，你获得4点<a href='mini_moulue'>谋略值</a>。",

  ["$miniex__yingrui1"] = "有吾筹谋，岂有败战之理？",
  ["$miniex__yingrui2"] = "坚铠精械，正为今日之战！"
}

local miniUtil = require "packages/mini/mini_util"

miniexYingrui:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player)
    return
      player == target and
      player.phase == Player.Draw and
      player:hasSkill(miniexYingrui.name) and
      player:getMark("@mini_moulue") < 5
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    miniUtil.handleMoulue(player.room, player, 4)
  end,
})

miniexYingrui:addEffect(fk.Deathed, {
  can_trigger = function(self, event, target, player, data)
    return
      data.damage and
      data.damage.from == player and
      player:hasSkill(miniexYingrui.name) and
      player:getMark("@mini_moulue") < 5
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    miniUtil.handleMoulue(player.room, player, 4)
  end,
})

return miniexYingrui
