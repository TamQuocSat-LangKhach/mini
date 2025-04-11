local miniXiangwei = fk.CreateSkill {
  name = "mini__xiangwei"
}

Fk:loadTranslationTable{
  ["mini__xiangwei"] = "象威",
  [":mini__xiangwei"] = "准备阶段，你可以视为使用一张【南蛮入侵】，然后选择一项：1.本回合对未因此牌受到伤害的其他角色使用牌无次数限制；" ..
  "2.本回合你造成的下一次伤害+1。",

  ["mini__xiangwei_bypass_times"] = "对未受到伤害的角色使用牌无次数限制",
  ["mini__xiangwei_damage"] = "造成的下一次伤害+1",
  ["#mini__xiangwei-turn"] = "象威：选择一项本回合生效",
  ["@@mini__xiangwei_bypass_times-turn"] = "象威 无次数限制",
  ["@@mini__xiangwei_damage-turn"] = "象威 增伤",
}

miniXiangwei:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(miniXiangwei.name) and player.phase == Player.Start then
      local card = Fk:cloneCard("savage_assault")
      card.skillName = miniXiangwei.name
      return player:canUse(card)
    end
  end,
  on_use = function (skill, event, target, player)
    ---@type string
    local skillName = miniXiangwei.name
    local room = player.room
    local card = Fk:cloneCard("savage_assault")
    card.skillName = skillName
    local use = {
      from = player,
      card = card,
    }
    room:useCard(use)
    if not player:isAlive() then
      return false
    end

    local choices = { "mini__xiangwei_damage" }
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not (use.damageDealt and use.damageDealt[p]) then
        table.insert(targets, p.id)
      end
    end
    if #targets > 0 then
      table.insert(choices, 1, "mini__xiangwei_bypass_times")
    end

    local choice = room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = skillName,
        prompt = "#mini__xiangwei-turn",
      }
    )
    if choice == "mini__xiangwei_bypass_times" then
      room:setPlayerMark(player, "@@mini__xiangwei_bypass_times-turn", targets)
    else
      room:setPlayerMark(player, "@@mini__xiangwei_damage-turn", 1)
    end
  end,
})

miniXiangwei:addEffect("targetmod", {
  bypass_times = function (skill, player, skill2, scope, card, to)
    return card and table.contains(player:getTableMark("@@mini__xiangwei_bypass_times-turn"), to.id)
  end,
})

miniXiangwei:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@mini__xiangwei_damage-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player, data)
    player.room:setPlayerMark(player, "@@mini__xiangwei_damage-turn", 0)
    data:changeDamage(1)
  end,
})

return miniXiangwei
