local duoquan = fk.CreateSkill {
  name = "mini_duoquan"
}

Fk:loadTranslationTable{
  ['mini_duoquan'] = '夺权',
  ['#mini_duoquan'] = '夺权：你可选择一名其他角色，观看其手牌并秘密选择一种类型',
  ['#mini_duoquan-ask'] = '夺权：观看%dest的手牌，选择一种类型',
  ['#mini_duoquan_delay'] = '夺权',
  ['#mini_duoquan-use'] = '夺权：你可以使用其中的一张牌',
  [':mini_duoquan'] = '结束阶段，你可观看一名其他角色的手牌，秘密选择一种类型，当其使用下一张牌时，若此牌的类型与你选择的类型相同，则你令取消之，然后当此牌结算完毕后，你可使用此牌对应的一张实体牌。',
  ['$mini_duoquan1'] = '曹氏三代基业，一朝尽入我手！',
  ['$mini_duoquan2'] = '为政者不仁，自可夺之！',
}

duoquan:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(duoquan.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#mini_duoquan",
      skill_name = duoquan.name,
      cancelable = true,
      no_indicate = true
    })
    if #tos > 0 then
      event:setCostData(skill, tos[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local targetPlayer = room:getPlayerById(event:getCostData(skill))
    local choice = U.askforViewCardsAndChoice(player, targetPlayer:getCardIds("h"), {"basic", "trick", "equip"}, duoquan.name, "#mini_duoquan-ask::" .. targetPlayer.id)
    local record = targetPlayer:getTableMark("_mini_duoquan")
    record[tostring(player.id)] = choice
    room:setPlayerMark(targetPlayer, "_mini_duoquan", record)
  end,
})

duoquan:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player)
    return target:getMark("_mini_duoquan") ~= 0 and target:getMark("_mini_duoquan")[tostring(player.id)] == data.card:getTypeString()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = target.room
    room:doIndicate(player.id, {target.id})
    local record = target:getMark("_mini_duoquan")
    record[tostring(player.id)] = nil
    if table.empty(record) then record = 0 end
    room:setPlayerMark(target, "_mini_duoquan", record)
    if data.toCard ~= nil then
      data.toCard = nil
    else
      data.tos = {}
    end
    room.logic:getCurrentEvent():addCleaner(function(s)
      if player.dead then return end
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if not e then return end
      local use = e.data[1]
      local ids = table.filter(Card:getIdList(use.card), function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #ids == 0 then return end
      room:askToUseRealCard(player, {
        pattern = ids,
        skill_name = "mini_duoquan",
        prompt = "#mini_duoquan-use",
        extra_data = {
          bypass_times = true,
          extra_use = true,
          expand_pile = ids,
        }
      })
    end)
  end,

  can_refresh = function(self, event, target, player)
    return player == target and target:getMark("_mini_duoquan") ~= 0
  end,
  on_refresh = function(self, event, target, player)
    local record = target:getMark("_mini_duoquan")
    for k, v in pairs(record) do
      if v ~= data.card:getTypeString() then
        record[k] = nil
      end
    end
    if table.empty(record) then record = 0 end
    target.room:setPlayerMark(target, "_mini_duoquan", record)
  end,
})

return duoquan
