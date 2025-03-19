local shenfu = fk.CreateSkill {
  name = "mini_shenfu"
}

Fk:loadTranslationTable{
  ['mini_shenfu'] = '神赋',
  ['@mini_shenfu_luoshen'] = '洛神',
  ['mini_shenfu_black'] = '依次使用其中的黑色牌',
  ['mini_shenfu_red'] = '获得其中的红色牌',
  ['#mini_shenfu-use'] = '神赋：你可以使用 %arg',
  [':mini_shenfu'] = '①当一名角色受到1点伤害后，你获得1枚“洛神”标记，上限为6。结束阶段，你弃置所有“洛神”标记，亮出牌堆顶等量张牌，然后选择一项：1.可以依次使用其中的黑色牌；2.获得其中的红色牌。',
  ['$mini_shenfu1'] = '往事尽于此赋，来者惟于清零。',
  ['$mini_shenfu2'] = '我身飘零于尘，此心空寄洛水。',
}

shenfu:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(skill.name) and player:getMark("@mini_shenfu_luoshen") < 6
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    room:addPlayerMark(player, "@mini_shenfu_luoshen", math.min(target.damage, 6 - player:getMark("@mini_shenfu_luoshen")))
  end
})

shenfu:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target)
    return target.phase == Player.Finish and target:getMark("@mini_shenfu_luoshen") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    local num = player:getMark("@mini_shenfu_luoshen")
    room:setPlayerMark(player, "@mini_shenfu_luoshen", 0)

    local cards = room:getNCards(num)
    room:moveCards{
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = shenfu.name,
      proposer = player.id,
    }

    local choice = room:askToChoice(player, {
      choices = {"mini_shenfu_black", "mini_shenfu_red"},
      skill_name = shenfu.name
    })
    if choice == "mini_shenfu_black" then
      for _, id in ipairs(cards) do
        local card = Fk:getCardById(id)
        if card.color == Card.Black and room:getCardArea(id) == Card.Processing and U.canUseCard(room, player, card) then
          local use = room:askToUseRealCard(player, {
            pattern = {id},
            skill_name = shenfu.name,
            prompt = "#mini_shenfu-use:::"..card:toLogString(),
            extra_data = {
              bypass_times = true,
              expand_pile = {id},
              extra_use = true,
            },
            cancelable = true
          })
          if use then
            room:useCard(use)
          end
        end
      end
    else
      local red = table.filter(cards, function (id)
        return Fk:getCardById(id).color == Card.Red
      end)
      if #red > 0 then
        room:obtainCard(player, red, true, fk.ReasonJustMove, player.id, shenfu.name)
      end
    end

    room:cleanProcessingArea(cards, shenfu.name)
  end
})

return shenfu
