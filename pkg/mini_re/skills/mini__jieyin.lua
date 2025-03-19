local mini__jieyin = fk.CreateSkill {
  name = "mini__jieyin"
}

Fk:loadTranslationTable{
  ['mini__jieyin'] = '结姻',
  [':mini__jieyin'] = '出牌阶段限一次，你可以弃置一张牌并选择一名男性角色，你与其各摸一张牌。',
}

mini__jieyin:addEffect('active', {
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(mini__jieyin.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected < 1
  end,
  target_filter = function(self, player, to_select, selected)
    return Fk:currentRoom():getPlayerById(to_select).gender == General.Male and #selected < 1 and to_select ~= player.id
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, mini__jieyin.name, from, from)
    if not from.dead then
      from:drawCards(1, mini__jieyin.name)
    end
    if not to.dead then
      to:drawCards(1, mini__jieyin.name)
    end
  end,
  on_cost = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    return room:askToDiscard(from, {
      min_num = 1,
      max_num = 1,
      skill_name = self.name,
    })
  end,
})

return mini__jieyin
