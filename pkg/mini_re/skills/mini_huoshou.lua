local miniHuoshou = fk.CreateSkill {
  name = "mini__huoshou"
}

Fk:loadTranslationTable{
  ["mini__huoshou"] = "祸首",
  [":mini__huoshou"] = "【南蛮入侵】对你无效。其他角色受到【南蛮入侵】的伤害时，你可以弃置一张手牌，令此伤害+1。",

  ["#mini__huoshou-ask"] = "祸首：你可以弃置一张牌，令 %dest 受到的伤害+1",
}

miniHuoshou:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return
      data.card and
      data.card.trueName == "savage_assault" and
      data.to == player and
      player:hasSkill(miniHuoshou.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.nullified = true
  end,
})

miniHuoshou:addEffect(fk.DamageInflicted, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      data.card and
      data.card.trueName == "savage_assault" and
      target ~= player and
      player:hasSkill(miniHuoshou.name) and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToDiscard(
      player,
      {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = miniHuoshou.name,
        prompt = "#mini__huoshou-ask::" .. target.id,
        skip = true,
      }
    )
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { target })
    room:throwCard(event:getCostData(self), miniHuoshou.name, player, player)
    data:changeDamage(1)
  end,
})

return miniHuoshou
