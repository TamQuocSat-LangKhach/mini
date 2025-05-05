local wanwei = fk.CreateSkill {
  name = "mini__wanwei",
}

Fk:loadTranslationTable{
  ["mini__wanwei"] = "挽危",
  [":mini__wanwei"] = "出牌阶段限一次，你可以弃置至多三张手牌，令一名其他角色摸等量的牌；若弃置的牌类别各不相同，其回复1点体力。",

  ["#mini__wanwei"] = "挽危：弃置至多三张手牌，令一名角色摸等量牌，若弃置牌类别不同，其回复1点体力",
}

wanwei:addEffect("active", {
  anim_type = "support",
  prompt = "#mini__wanwei",
  min_card_num = 1,
  max_card_num = 3,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(wanwei.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < 3 and table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, wanwei.name, player, player)
    if not target.dead then
      room:drawCards(target, #effect.cards, wanwei.name)
    end
    if target:isWounded() and not target.dead and
      not table.find(effect.cards, function (id)
        return table.find(effect.cards, function (id2)
          return id ~= id2 and Fk:getCardById(id).type == Fk:getCardById(id2).type
        end) ~= nil
      end) then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        selfName = wanwei.name,
      }
    end
  end
})

return wanwei