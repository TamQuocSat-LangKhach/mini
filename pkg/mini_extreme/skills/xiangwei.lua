local xiangwei = fk.CreateSkill {
  name = "mini__xiangwei"
}

Fk:loadTranslationTable{
  ['mini__xiangwei'] = '象威',
  ['mini__xiangwei_bypass_times'] = '对未受到伤害的角色使用牌无次数限制',
  ['mini__xiangwei_slash'] = '下%arg张【杀】伤害+1',
  ['#mini__xiangwei-turn'] = '象威：选择一项本回合生效',
  ['@@mini__xiangwei_bypass_times-turn'] = '象威 无次数限制',
  ['@mini__xiangwei_slash-turn'] = '象威 杀增伤',
  [':mini__xiangwei'] = '准备阶段，你可以视为使用一张【南蛮入侵】，然后选择一项：1.本回合对未因此牌受到伤害的其他角色使用牌无次数限制；2.本回合你使用的下X张【杀】伤害+1（X为受到此牌伤害的角色数）。',
}

xiangwei:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(xiangwei.name) and player.phase == Player.Start then
      local card = Fk:cloneCard("savage_assault")
      card.skillName = xiangwei.name
      return player:canUse(card)
    end
  end,
  on_use = function (skill, event, target, player)
    local room = player.room
    local card = Fk:cloneCard("savage_assault")
    card.skillName = xiangwei.name
    local use = {
      from = player.id,
      card = card,
    }
    room:useCard(use)
    if player.dead then return end
    local choices = {}
    local targets, n = {}, 0
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not (use.damageDealt and use.damageDealt[p.id]) then
        table.insert(targets, p.id)
      end
    end
    for _, p in ipairs(room.players) do
      if use.damageDealt and use.damageDealt[p.id] then
        n = n + 1
      end
    end
    if #targets > 0 then
      table.insert(choices, "mini__xiangwei_bypass_times")
    end
    if n > 0 then
      table.insert(choices, "mini__xiangwei_slash:::"..n)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = xiangwei.name,
      prompt = "#mini__xiangwei-turn"
    })
    if choice == "mini__xiangwei_bypass_times" then
      room:setPlayerMark(player, "@@mini__xiangwei_bypass_times-turn", targets)
    else
      room:setPlayerMark(player, "@mini__xiangwei_slash-turn", n)
    end
  end,
})

xiangwei:addEffect('targetmod', {
  bypass_times = function (skill, player, skill2, scope, card, to)
    return card and table.contains(player:getTableMark("@@mini__xiangwei_bypass_times-turn"), to.id)
  end,
})

xiangwei:addEffect(fk.PreCardUse, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@mini__xiangwei_slash-turn") > 0 and
      data.card.trueName == "slash"
  end,
  on_use = function (skill, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__xiangwei_slash-turn", 1)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

return xiangwei
