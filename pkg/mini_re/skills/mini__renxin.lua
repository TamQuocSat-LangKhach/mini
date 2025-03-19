local mini__renxin = fk.CreateSkill {
  name = "mini__renxin"
}

Fk:loadTranslationTable{
  ['mini__renxin'] = '仁心',
  ['#mini__renxin-ask'] = '仁心：你可以弃置一张牌，将 %dest 受到的伤害转移给你',
  [':mini__renxin'] = '每轮限一次，当其他角色受到不小于其体力值的伤害时，你可以弃置一张牌将此伤害转移给你。',
}

mini__renxin:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(mini__renxin) and target.hp <= data.damage and target ~= player and not player:isNude() and player:usedSkillTimes(mini__renxin.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = mini__renxin.name,
      cancelable = true,
      prompt = "#mini__renxin-ask::" .. target.id,
    })
    if #card > 0 then
      event:setCostData(self, card)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    player:broadcastSkillInvoke("renxin")
    room:throwCard(event:getCostData(self), mini__renxin.name, player, player)
    if not player.dead then
      room:damage{
        from = data.from,
        to = player,
        damage = data.damage,
        damageType = data.type,
        skillName = mini__renxin.name,
        card = data.card,
      }
    end
    return true
  end,
})

return mini__renxin
