local mini_sifu = fk.CreateSkill {
  name = "mini_sifu"
}

Fk:loadTranslationTable{
  ['mini_sifu'] = '思赋',
  ['#mini_sifu-active'] = '发动 思赋，从牌堆中随机获得一张指定点数的牌',
  ['mini_sifu_used'] = '已使用',
  ['mini_sifu_non_used'] = '未使用',
  [':mini_sifu'] = '出牌阶段各限一次，你可以选择一个本回合你使用/未使用过的牌的点数，然后从牌堆里随机获得一张该点数的牌。',
  ['$mini_sifu1'] = '云山万重兮归路遐，疾风千里兮扬尘沙。',
  ['$mini_sifu2'] = '无日无夜兮不思我乡土，禀气合生兮莫过我最苦。',
}

mini_sifu:addEffect('active', {
  name = "mini_sifu",
  prompt = "#mini_sifu-active",
  anim_type = "drawcard",
  interaction = function(player)
    local numbers = { {}, {} }
    local record = player:getTableMark("mini_sifu_record-turn")
    for i = 1, 13, 1 do
      if table.contains(record, i) then
        table.insert(numbers[1], i)
      else
        table.insert(numbers[2], i)
      end
    end
    local area_names = { "mini_sifu_used", "mini_sifu_non_used" }

    if player:getMark("mini_sifu_choice2-phase") > 0 then
      table.remove(numbers, 2)
      table.remove(area_names, 2)
    end

    if player:getMark("mini_sifu_choice1-phase") > 0 then
      table.remove(numbers, 1)
      table.remove(area_names, 1)
    end

    return {
      type = "custom",
      qml_path = "packages/mini/qml/SiFuInteraction",
      numbers = numbers,
      area_names = area_names,
    }
  end,
  target_num = 0,
  card_num = 0,
  times = function(self, player)
    if player.phase == Player.Play then
      local x = 0
      if player:getMark("mini_sifu_choice1-phase") == 0 then
        x = x + 1
      end
      if player:getMark("mini_sifu_choice2-phase") == 0 then
        x = x + 1
      end
      return x
    end
    return -1
  end,
  card_filter = Util.FalseFunc,
  can_use = function (skill, player)
    return player:hasSkill(mini_sifu.name, true) and (player:getMark("mini_sifu_choice1-phase") == 0 or player:getMark("mini_sifu_choice2-phase") == 0)
  end,
  feasible = function(self, player, selected_cards)
    return tonumber(skill.interaction.data)
  end,
  on_use = function (skill, room, effect)
    local player = room:getPlayerById(effect.from)
    if table.contains(player:getTableMark("mini_sifu_record-turn"), tonumber(skill.interaction.data)) then
      room:setPlayerMark(player, "mini_sifu_choice1-phase", 1)
    else
      room:setPlayerMark(player, "mini_sifu_choice2-phase", 1)
    end

    local cards = room:getCardsFromPileByRule(".|" .. skill.interaction.data)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, mini_sifu.name)
    end
  end,

  on_acquire = function (skill, player, is_start)
    local room = player.room
    if room.current ~= player then return end
    local turn = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
    if turn == nil then return end
    local nums = {}
    room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
      local use = e.data[1]
      if use.from == player.id then
        table.insertIfNeed(nums, use.card.number)
      end
    end, turn.id)
    if #nums > 0 then
      room:setPlayerMark(player, "mini_sifu_record-turn", nums)
    end
  end,
  on_lose = function (skill, player, is_death)
    local room = player.room
    room:setPlayerMark(player, "mini_sifu_choice1-phase", 0)
    room:setPlayerMark(player, "mini_sifu_choice2-phase", 0)
  end,
})

mini_sifu:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(mini_sifu.name, true) and
      player.room.current == player and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "mini_sifu_record-turn", data.card.number)
  end,
})

return mini_sifu
