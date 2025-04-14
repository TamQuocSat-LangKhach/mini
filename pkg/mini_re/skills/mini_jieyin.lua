local miniJieyin = fk.CreateSkill {
  name = "mini__jieyin"
}

Fk:loadTranslationTable{
  ["mini__jieyin"] = "结姻",
  [":mini__jieyin"] = "出牌阶段限一次，你可以弃置一张牌并选择一名男性角色，你与其各摸一张牌。",
}

miniJieyin:addEffect("active", {
  anim_type = "support",
  can_use = function(self, player)
    return player:usedSkillTimes(miniJieyin.name, Player.HistoryPhase) == 0
  end,
  card_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected < 1 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return to_select.gender == General.Male and #selected < 1 and to_select ~= player
  end,
  target_num = 1,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniJieyin.name
    local from = effect.from
    local to = effect.tos[1]
    room:throwCard(effect.cards, skillName, from, from)
    if from:isAlive() then
      from:drawCards(1, skillName)
    end
    if to:isAlive() then
      to:drawCards(1, skillName)
    end
  end,
})

return miniJieyin
