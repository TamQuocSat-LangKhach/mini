local zhuixi = fk.CreateSkill {
  name = "mini_zhuixi",
}

Fk:loadTranslationTable{
  ['mini_zhuixi'] = '追袭',
  ['#mini_zhuixi-ask'] = '追袭：你可选择一名角色，视为对其使用【杀】',
  [':mini_zhuixi'] = '①结束阶段，若其他角色均处于你的攻击范围内，你可选择一名角色，视为对其使用【杀】。②你至装备区里没有坐骑牌的角色的距离视为1。',
  ['$mini_zhuixi1'] = '万军在前，汝何敢拒我？',
  ['$mini_zhuixi2'] = '此战为胜者生，汝敢战否？',
}

zhuixi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(zhuixi.name) and target.phase == Player.Finish and table.every(player.room.alive_players, function(p) return player:inMyAttackRange(p) or player == p end) and not player:prohibitUse(Fk:cloneCard("slash"))
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#mini_zhuixi-ask",
      skill_name = zhuixi.name,
      cancelable = true,
    })
    if #tos > 0 then
      event:setCostData(skill, tos)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local slash = Fk:cloneCard("slash")
    slash.skillName = zhuixi.name
    player.room:useCard{
      from = target.id,
      tos = table.map(event:getCostData(skill), function(pid) return { pid } end),
      card = slash,
      extraUse = true,
    }
  end,
})

zhuixi:addEffect('distance', {
  fixed_func = function(self, player, from, to)
    if from:hasSkill(zhuixi.name) and #to:getEquipments(Card.SubtypeOffensiveRide) == 0 and #to:getEquipments(Card.SubtypeDefensiveRide) == 0 then
      return 1
    end
  end,
})

return zhuixi
