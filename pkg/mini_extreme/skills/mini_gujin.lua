local miniGujin = fk.CreateSkill {
  name = "mini__gujin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__gujin"] = "鼓进",
  [":mini__gujin"] = "锁定技，每名角色的回合结束时，若本回合你未成为过其他角色使用牌的目标，你获得1点<a href='mini_moulue'>谋略值</a>；" ..
  "当你抵消其他角色对你使用的【杀】后，你获得2点<a href='mini_moulue'>谋略值</a>。",
}

local miniUtil = require "packages/mini/mini_util"

miniGujin:addEffect(fk.TurnEnd, {
  anim_type = "special",
  can_trigger = function(self, event, target, player)
    return
      player:hasSkill(miniGujin.name) and
      player:getMark("@mini_moulue") < 5 and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        return use.from ~= player and table.contains(use.tos, player)
      end, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player)
    miniUtil.handleMoulue(player.room, player, 1)
  end,
})

miniGujin:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return
      target ~= player and
      player:hasSkill(miniGujin.name) and
      data.card.trueName == "slash" and
      data.to == player and
      player:getMark("@mini_moulue") < 5
  end,
  on_use = function(self, event, target, player, data)
    miniUtil.handleMoulue(player.room, player, 2)
  end,
})

return miniGujin
