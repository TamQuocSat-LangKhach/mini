local miniYanfeng = fk.CreateSkill {
  name = "mini__yanfeng",
  tags = { Skill.Force },
}

Fk:loadTranslationTable{
  ["mini__yanfeng"] = "炎锋",
  [":mini__yanfeng"] = "<a href='MiniForceSkill'>奋武技</a>，出牌阶段，你可以将一张牌当无距离限制的火【杀】使用。" ..
  "若此【杀】未造成伤害且仅指定唯一目标，你令目标选择一项：1.对你造成1点伤害；2.令你摸一张牌，本回合你对其使用的下一张【杀】无效。",

  ["#mini__yanfeng"] = "炎锋：你可以将一张牌当无距离限制的火【杀】使用",
  ["mini__yanfeng1"] = "对%src造成1点伤害",
  ["mini__yanfeng2"] = "%src摸一张牌，其本回合对你使用的下一张【杀】无效",
}

miniYanfeng:addEffect("viewas", {
  anim_type = "offensive",
  prompt = "#mini__yanfeng",
  times = function(self, player)
    return 1 + player:getMark("mini__yanfeng_force_times-round") - player:usedSkillTimes(miniYanfeng.name, Player.HistoryRound)
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire__slash")
    card.skillName = miniYanfeng.name
    card:addSubcard(cards[1])
    return card
  end,
  after_use = function (self, player, use)
    ---@type string
    local skillName = miniYanfeng.name
    local room = player.room
    if
      not player:isAlive() or
      use.damageDealt or
      #use.tos < 1 or
      table.find(use.tos, function(p) return p ~= use.tos[1] end)
    then
      return
    end
    local to = use.tos[1]
    if not to:isAlive() then
      return
    end

    local choice = room:askToChoice(
      to,
      {
        choices = { "mini__yanfeng1:" .. player.id, "mini__yanfeng2:" .. player.id },
        skill_name = skillName,
      }
    )
    if string.sub(choice, 14, 14) == "1" then
      room:damage{
        from = to,
        to = player,
        damage = 1,
        skillName = skillName,
      }
    else
      room:addTableMarkIfNeed(player, "mini__yanfeng-turn", to.id)
      player:drawCards(1, skillName)
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(miniYanfeng.name, Player.HistoryRound) < (1 + player:getMark("mini__yanfeng_force_times-round"))
  end,
})

miniYanfeng:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, "mini__yanfeng")
  end,
})

miniYanfeng:addEffect(fk.PreCardEffect, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      data.from == player and
      data.card.trueName == "slash" and
      table.contains(player:getTableMark("mini__yanfeng-turn"), data.to.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:removeTableMark(player, "mini__yanfeng-turn", data.to.id)
    data.nullified = true
  end,
})

local miniYanfengRecordSpec = {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("#mini__yanfeng_force_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__yanfeng_force_times-round", data.damage)
  end,
}

miniYanfeng:addEffect(fk.Damage, miniYanfengRecordSpec)

miniYanfeng:addEffect(fk.Damaged, miniYanfengRecordSpec)

return miniYanfeng
