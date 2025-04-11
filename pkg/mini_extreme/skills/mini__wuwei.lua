local miniWuwei = fk.CreateSkill {
  name = "mini__wuwei",
  tags = { Skill.Force },
}

Fk:loadTranslationTable{
  ["mini__wuwei"] = "武威",
  [":mini__wuwei"] = "<a href='MiniForceSkill'>奋武技</a>，出牌阶段，你可以弃置X+1张牌（X为此阶段本技能的发动次数），" ..
  "然后弃置一名角色等量张牌。若你弃置自己的牌点数之和不大于弃置其的牌点数之和，你对其造成1点雷电伤害。",

  ["#mini__wuwei"] = "武威：弃置 %arg 张牌并弃置一名角色等量张牌，然后可能对其造成伤害",

  ["$mini__wuwei1"] = "三军既出，自怯敌之胆。",
  ["$mini__wuwei2"] = "来将何人？可知关某之名！"
}

miniWuwei:addEffect("active", {
  anim_type = "offensive",
  target_num = 1,
  times = function(self, player)
    return 1 + player:getMark("mini_force_times-round") - player:usedSkillTimes(miniWuwei.name, Player.HistoryRound)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(miniWuwei.name, Player.HistoryRound) < (1 + player:getMark("mini_force_times-round"))
  end,
  card_filter = function (self, player, to_select, selected)
    local num = player:usedSkillTimes(miniWuwei.name, Player.HistoryPhase) + 1
    return #selected < num and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, player, to_select, selected, cards)
    local num = player:usedSkillTimes(miniWuwei.name, Player.HistoryPhase) + 1
    if #cards == num then
      return #selected == 0 and not to_select:isNude()
    end
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniWuwei.name
    local player = effect.from
    local myNum = 0
    for _, id in ipairs(effect.cards) do
      myNum = myNum + Fk:getCardById(id).number
    end
    room:throwCard(effect.cards, skillName, player, player)
    if player.dead then return end
    local cardNum = #effect.cards
    local to = effect.tos[1]
    local toNum, toCards = 0, to:getCardIds("he")
    if #toCards > cardNum then
      toCards = room:askToChooseCards(
        player,
        {
          min = cardNum,
          max = cardNum,
          target = to,
          flag = "he",
          skill_name = skillName,
        }
      )
    end
    for _, id in ipairs(toCards) do
      toNum = toNum + Fk:getCardById(id).number
    end
    room:throwCard(toCards, skillName, to, player)
    if not to.dead and myNum <= toNum then
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = skillName,
        damageType = fk.ThunderDamage,
      }
    end
  end,
  prompt = function (self, player)
    return "#mini__wuwei:::" .. (player:usedSkillTimes(miniWuwei.name, Player.HistoryPhase) + 1)
  end,
})

local miniWuweiRecordSpec = {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("mini_force_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini_force_times-round", data.damage)
  end,
}

miniWuwei:addEffect(fk.Damage, miniWuweiRecordSpec)

miniWuwei:addEffect(fk.Damaged, miniWuweiRecordSpec)

return miniWuwei
