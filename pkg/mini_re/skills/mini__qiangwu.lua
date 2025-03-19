local mini__qiangwu = fk.CreateSkill {
  name = "mini__qiangwu"
}

Fk:loadTranslationTable{
  ['mini__qiangwu'] = '枪舞',
  ['#mini__qiangwu'] = '枪舞：你可弃置一张牌：点数大于此牌的【杀】不计入次数、无距离限制',
  ['@mini__qiangwu-turn'] = '枪舞',
  [':mini__qiangwu'] = '出牌阶段限一次，你可以弃置一张牌。若如此做，直到回合结束，你使用点数大于此牌的【杀】不计入次数且无距离限制。',
}

-- ActiveSkill
mini__qiangwu:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  prompt = "#mini__qiangwu",
  can_use = function(self, player)
    return player:usedSkillTimes(mini__qiangwu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("qiangwu")
    local num = Fk:getCardById(effect.cards[1]).number
    room:throwCard(effect.cards, mini__qiangwu.name, player, player)
    if not player.dead then
      room:setPlayerMark(player, "@mini__qiangwu-turn", num)
    end
  end,
})

-- TargetModSkill
mini__qiangwu:addEffect('targetmod', {
  bypass_distances = function (self, player, skill, card, to)
    return player:getMark("@mini__qiangwu-turn") ~= 0 and card and card.trueName == "slash"
      and card.number > player:getMark("@mini__qiangwu-turn")
  end,
})

-- TriggerSkill
mini__qiangwu:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@mini__qiangwu-turn") ~= 0 and data.card.trueName == "slash"
      and data.card.number > player:getMark("@mini__qiangwu-turn")
  end,
  on_refresh = function(self, event, target, player, data)
    data.extraUse = true
  end,
})

return mini__qiangwu
