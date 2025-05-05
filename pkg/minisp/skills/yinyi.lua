local yinyi = fk.CreateSkill{
  name = "yinyij",
}

Fk:loadTranslationTable{
  ["yinyij"] = "音忆",
  [":yinyij"] = "当你失去牌后，你获得一枚“音”标记（至多五枚）。一名角色的结束阶段，你可以移去五枚“音”标记并选择一项："..
  "1.弃置一张牌，视为对其使用一张【杀】；2.摸一张牌。",

  ["@yinyij"] = "音",
  ["#yinyij-invoke"] = "音忆：你可以移去五枚“音”标记并执行一项",
  ["yinyij_slash"] = "弃置一张牌，视为对%dest使用【杀】",
  ["#yinyij-discard"] = "音忆：弃置一张牌，视为对 %dest 使用一张【杀】",

  ["$yinyij1"] = "",
  ["$yinyij2"] = "",
}

yinyi:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(yinyi.name) and player:getMark("@yinyij") < 5 then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "@yinyij", 1)
  end,
})

yinyi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yinyi.name) and target.phase == Player.Finish and
      player:getMark("@yinyij") >= 5
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = {"yinyij_slash::"..target.id, "draw1", "Cancel"}
    local choices = table.simpleClone(all_choices)
    if target == player or target.dead or player:isNude() then
      table.remove(choices, 1)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yinyi.name,
      prompt = "#yinyij-invoke",
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      if choice ~= "draw1" then
        local card = room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = yinyi.name,
          prompt = "#yinyij-discard::"..target.id,
          cancelable = true,
          skip = true,
        })
        if #card > 0 then
          event:setCostData(self, {tos = {target}, cards = card, choice = choice})
          return true
        else
          return
        end
      end
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@yinyij", 5)
    local choice = event:getCostData(self).choice
    if choice == "draw1" then
      player:drawCards(1, yinyi.name)
    else
      room:throwCard(event:getCostData(self).cards, yinyi.name, player, player)
      if not target.dead then
        room:useVirtualCard("slash", nil, player, target, yinyi.name, true)
      end
    end
  end,
})

yinyi:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@yinyij", 0)
end)

return yinyi
