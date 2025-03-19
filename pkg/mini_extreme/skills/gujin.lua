local gujin = fk.CreateSkill {
  name = "mini__gujin"
}

Fk:loadTranslationTable{
  ['mini__gujin'] = '鼓进',
  ['@mini_moulue'] = '谋略值',
  ['#mini__gujin_trigger'] = '鼓进',
  [':mini__gujin'] = '锁定技，每名角色的回合结束时，若本回合你未成为过其他角色使用牌的目标，你获得1点<a href=>谋略值</a>。当你抵消其他角色对你使用的【杀】后，你获得2点<a href=>谋略值</a>。',
}

gujin:addEffect(fk.TurnEnd, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    if not player:hasSkill(gujin.name) or player:getMark("@mini_moulue") >= 5 then return end
    return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data[1]
      return use.from ~= player.id and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
    end, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player)
    handleMoulue(player.room, player, 1)
  end,
})

gujin:addEffect(fk.CardEffectCancelledOut, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(gujin.name) and data.card.trueName == "slash" and
      data.to == player.id and player:getMark("@mini_moulue") < 5
  end,
  on_use = function(self, event, target, player, data)
    handleMoulue(player.room, player, 2)
  end,
})

return gujin
