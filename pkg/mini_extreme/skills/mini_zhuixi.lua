local miniZhuixi = fk.CreateSkill {
  name = "mini_zhuixi",
}

Fk:loadTranslationTable{
  ["mini_zhuixi"] = "追袭",
  [":mini_zhuixi"] = "①结束阶段，若其他角色均处于你的攻击范围内，你可选择一名角色，视为对其使用【杀】。②你至装备区里没有坐骑牌的角色的距离视为1。",

  ["#mini_zhuixi-ask"] = "追袭：你可选择一名角色，视为对其使用【杀】",

  ["$mini_zhuixi1"] = "万军在前，汝何敢拒我？",
  ["$mini_zhuixi2"] = "此战为胜者生，汝敢战否？",
}

miniZhuixi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniZhuixi.name) and
      target.phase == Player.Finish and
      table.every(
        player.room:getOtherPlayers(player, false),
        function(p) return player:inMyAttackRange(p) end
      ) and
      not player:prohibitUse(Fk:cloneCard("slash"))
  end,
  on_cost = function(self, event, target, player, data)
    local use = player.room:askToUseVirtualCard(
      player,
      {
        name = "slash",
        skill_name = miniZhuixi.name,
        prompt = "#mini_zhuixi-ask",
        extra_data = { bypass_distances = true },
        skip = true,
      }
    )
    if use then
      event:setCostData(self, use)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(event:getCostData(self))
  end,
})

miniZhuixi:addEffect("distance", {
  fixed_func = function(self, from, to)
    if
      from:hasSkill(miniZhuixi.name) and
      #to:getEquipments(Card.SubtypeOffensiveRide) == 0 and
      #to:getEquipments(Card.SubtypeDefensiveRide) == 0
    then
      return 1
    end
  end,
})

return miniZhuixi
