local miniZuoqing = fk.CreateSkill {
  name = "mini__zuoqing"
}

Fk:loadTranslationTable{
  ["mini__zuoqing"] = "佐卿",
  [":mini__zuoqing"] = "出牌阶段每名角色限一次，你可以失去1点体力或弃置装备区内所有装备牌（至少一张），" ..
  "令一名角色选择其接下来1.使用；2.打出前X张【杀】时摸一张牌（X为你已损失体力值且至少为1）。",

  ["#mini__zuoqing"] = "佐卿：失去1点体力或弃置装备，令一名角色接下来使用或打出杀时摸一张牌",
  ["mini__zuoqing_discard"] = "弃置所有装备",
  ["mini__zuoqing_use"] = "使用【杀】时摸一张牌",
  ["mini__zuoqing_response"] = "打出【杀】时摸一张牌",
  ["#mini__zuoqing_trigger"] = "佐卿",
  ["@mini__zuoqing_use"] = "使用杀摸牌",
  ["#mini__zuoqing_trigger2"] = "佐卿",
  ["@mini__zuoqing_response"] = "打出杀摸牌",
}

miniZuoqing:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#mini__zuoqing",
  interaction = function(self, player)
    local choices = { "loseHp" }
    if #player:getCardIds("e") > 0 then
      table.insert(choices, "mini__zuoqing_discard")
    end
    return UI.ComboBox { choices = choices, all_choices = { "loseHp", "mini__zuoqing_discard" } }
  end,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and not table.contains(player:getTableMark("mini__zuoqing-phase"), to_select.id)
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniZuoqing.name
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMark(player, "mini__zuoqing-phase", target.id)
    if self.interaction.data == "loseHp" then
      room:loseHp(player, 1, skillName)
    else
      room:throwCard(player:getCardIds("e"), skillName, player, player)
    end
    if not target:isAlive() then return end
    local choice = room:askToChoice(
      target,
      {
        choices = { "mini__zuoqing_use", "mini__zuoqing_response" },
        skill_name = skillName,
      }
    )
    local n = math.max(1, player:getLostHp())
    room:setPlayerMark(target, "@" .. choice, math.max(n, target:getMark("@" .. choice)))
  end,
})

miniZuoqing:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@mini__zuoqing_use") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__zuoqing_use")
    player:drawCards(1, miniZuoqing.name)
  end,
})

miniZuoqing:addEffect(fk.CardResponding, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@mini__zuoqing_response") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__zuoqing_response")
    player:drawCards(1, miniZuoqing.name)
  end,
})

return miniZuoqing
