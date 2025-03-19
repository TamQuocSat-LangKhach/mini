local mini__huoshou = fk.CreateSkill {
  name = "mini__huoshou"
}

Fk:loadTranslationTable{
  ['mini__huoshou'] = '祸首',
  ['#mini__huoshou-ask'] = '祸首：你可以弃置一张牌，令 %dest 受到的伤害+1',
  [':mini__huoshou'] = '【南蛮入侵】对你无效。其他角色受到【南蛮入侵】的伤害时，你可以弃置一张手牌，令此伤害+1。',
}

mini__huoshou:addEffect(fk.PreCardEffect, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mini__huoshou.name) and data.card and data.card.trueName == "savage_assault" then
      return data.to == player.id
    end
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, mini__huoshou.name, "defensive")
    return true
  end,
})

mini__huoshou:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mini__huoshou.name) and data.card and data.card.trueName == "savage_assault" then
      return target ~= player and not player:isKongcheng()
    end
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = mini__huoshou.name,
      cancelable = true,
      prompt = "#mini__huoshou-ask::" .. target.id,
    })
    if #card > 0 then
      event:setCostData(skill, card)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, mini__huoshou.name, "offensive")
    room:doIndicate(player.id, {target.id})
    room:throwCard(event:getCostData(skill), mini__huoshou.name, player, player)
    data.damage = data.damage + 1
  end,
})

return mini__huoshou
