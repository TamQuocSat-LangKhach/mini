local miniShenfu = fk.CreateSkill {
  name = "mini_shenfu"
}

Fk:loadTranslationTable{
  ["mini_shenfu"] = "神赋",
  [":mini_shenfu"] = "①当一名角色受到1点伤害后，你获得1枚“洛神”标记，上限为6。②结束阶段，你弃所有“洛神”标记，" ..
  "亮出牌堆顶等量张牌，然后选择一项：1.可以依次使用其中的黑色牌；2.获得其中的红色牌。",

  ["@mini_shenfu_luoshen"] = "洛神",
  ["mini_shenfu_black"] = "依次使用其中的黑色牌",
  ["mini_shenfu_red"] = "获得其中的红色牌",
  ["#mini_shenfu-use"] = "神赋：你可以使用 %arg",

  ["$mini_shenfu1"] = "往事尽于此赋，来者惟于清零。",
  ["$mini_shenfu2"] = "我身飘零于尘，此心空寄洛水。",
}

miniShenfu:addEffect(fk.Damaged, {
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(miniShenfu.name) and player:getMark("@mini_shenfu_luoshen") < 6
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@mini_shenfu_luoshen")
  end
})

miniShenfu:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(miniShenfu.name) and target == player
      and target.phase == Player.Finish and target:getMark("@mini_shenfu_luoshen") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniShenfu.name
    local room = player.room
    local num = player:getMark("@mini_shenfu_luoshen")
    room:setPlayerMark(player, "@mini_shenfu_luoshen", 0)

    local cards = room:getNCards(num)
    room:moveCards{
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = skillName,
      proposer = player,
    }

    local choice = room:askToChoice(
      player,
      {
        choices = { "mini_shenfu_black", "mini_shenfu_red" },
        skill_name = skillName,
      }
    )
    if choice == "mini_shenfu_black" then
      for _, id in ipairs(cards) do
        local card = Fk:getCardById(id)
        if
          card.color == Card.Black and
          room:getCardArea(id) == Card.Processing and
          player:canUse(card, { bypass_times = true })
        then
          room:askToUseRealCard(
            player,
            {
              pattern = { id },
              skill_name = skillName,
              prompt = "#mini_shenfu-use:::" .. card:toLogString(),
              extra_data = {
                bypass_times = true,
                expand_pile = { id },
                extra_use = true,
              },
            }
          )
        end
      end
    else
      local red = table.filter(cards, function (id)
        return Fk:getCardById(id).color == Card.Red
      end)
      if #red > 0 then
        room:obtainCard(player, red, true, fk.ReasonJustMove, player, skillName)
      end
    end

    room:cleanProcessingArea(cards, skillName)
  end
})

return miniShenfu
