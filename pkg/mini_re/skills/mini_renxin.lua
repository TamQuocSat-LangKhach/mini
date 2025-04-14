local miniRenxin = fk.CreateSkill {
  name = "mini__renxin"
}

Fk:loadTranslationTable{
  ["mini__renxin"] = "仁心",
  [":mini__renxin"] = "每轮限一次，当其他角色受到不小于其体力值的伤害时，你可以弃置一张牌将此伤害转移给你。",

  ["#mini__renxin-ask"] = "仁心：你可以弃置一张牌，将 %dest 受到的伤害转移给你",
}

miniRenxin:addEffect(fk.DamageInflicted, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(miniRenxin.name) and
      target.hp <= data.damage and
      target ~= player and
      not player:isNude() and
      player:usedSkillTimes(miniRenxin.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToDiscard(
      player,
      {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = miniRenxin.name,
        skip = true,
        prompt = "#mini__renxin-ask::" .. target.id,
      }
    )
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniRenxin.name
    local room = player.room
    room:doIndicate(player, { target })
    player:broadcastSkillInvoke("renxin")
    room:throwCard(event:getCostData(self), skillName, player, player)

    local damage = data.damage
    data:preventDamage()

    if player:isAlive() then
      room:damage{
        from = data.from,
        to = player,
        damage = damage,
        damageType = data.damageType,
        skillName = skillName,
        card = data.card,
      }
    end
  end,
})

return miniRenxin
