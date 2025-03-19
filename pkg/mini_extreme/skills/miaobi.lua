local miaobi = fk.CreateSkill {
  name = "mini_miaobi",
}

Fk:loadTranslationTable{
  ['mini_miaobi'] = '妙笔',
  ['mini_miaobi_penmanship'] = '妙笔',
  ['#mini_miaobi_only-ask'] = '妙笔：你可将%arg置于%dest的武将牌上',
  ['#mini_miaobi-ask'] = '妙笔：你可将%arg置于一个目标角色的武将牌上',
  ['#mini_miaobi_delay'] = '妙笔：将一张锦囊牌交给 %src，否则其对你依次使用“妙笔”牌',
  ['#mini_miaobi-choose'] = '妙笔：选择对%dest使用的%arg的副目标',
  [':mini_miaobi'] = '当你于出牌阶段内使用的、非转化且非虚拟的锦囊牌结算结束后，你可将此牌置于其中一个目标角色的武将牌上（每牌名每回合限一次）。拥有“妙笔”牌的角色的准备阶段，其选择一项：1. 交给你一张锦囊牌，将“妙笔”牌置入弃牌堆；2. 你对其依次使用“妙笔”牌。',
  ['$mini_miaobi1'] = '行舟泛知海，点墨启新灵。',
  ['$mini_miaobi2'] = '纵横览前贤，风月皆成鉴。',
}

miaobi:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player)
    if target ~= player then return false end
    if not (player:hasSkill(miaobi) and player.phase == Player.Play
      and data.card.type == Card.TypeTrick and U.isPureCard(data.card) and not table.contains(player:getTableMark("_mini_miaobi_used-turn"), data.card.trueName)) then return false end
    local room = player.room
    if room:getCardArea(data.card) ~= Card.Processing then return false end
    local targets = {}
    for _, pid in ipairs(TargetGroup:getRealTargets(data.tos)) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        table.insertIfNeed(targets, pid)
      end
    end
    if #targets > 0 then
      event:setCostData(skill, targets)
      return true
    end
  end,
  on_cost = function(self, event, target, player)
    local targets = event:getCostData(skill)
    local room = player.room
    if #targets == 1 then
      if room:askToSkillInvoke(player, {skill_name = miaobi.name, prompt = "#mini_miaobi_only-ask::" .. targets[1] .. ":" .. data.card:toLogString()}) then
        event:setCostData(skill, targets[1])
        return true
      end
    else
      local tos = player.room:askToChoosePlayers(player, {targets = targets, min_num = 1, max_num = 1, prompt = "#mini_miaobi-ask:::" .. data.card:toLogString(), skill_name = miaobi.name})
      if #tos > 0 then
        event:setCostData(skill, tos[1])
        return true
      end
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:addTableMark(player, "_mini_miaobi_used-turn", data.card.trueName)
    local to = room:getPlayerById(event:getCostData(skill))
    to:addToPile("mini_miaobi_penmanship", data.card, true, miaobi.name)
    if table.contains(to:getPile("mini_miaobi_penmanship"), data.card.id) then
      local record = to:getTableMark("_mini_miaobi")
      record[tostring(player.id)] = record[tostring(player.id)] or {}
      table.insert(record[tostring(player.id)], data.card.id)
      room:setPlayerMark(to, "_mini_miaobi", record)
    end
  end,
})

miaobi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return #player:getPile("mini_miaobi_penmanship") > 0 and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player) 
    return true
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local record = table.simpleClone(player:getMark("_mini_miaobi"))
    for k, v in pairs(record) do
      local from = room:getPlayerById(tonumber(k))
      local cards = table.filter(v, function (cid)
        return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
      end)
      if not from.dead and #cards > 0 then
        local c = {}
        if player ~= from then
          c = room:askToCards(player, {min_num = 1, max_num = 1, pattern = ".|.|.|.|.|trick", prompt = "#mini_miaobi_delay:" .. from.id, skill_name = miaobi.name})
        end
        if #c > 0 then
          room:moveCardTo(c[1], Card.PlayerHand, from, fk.ReasonGive, miaobi.name, nil, true, from.id)
          cards = table.filter(cards, function (cid)
            return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
          end)
          room:moveCards{
            ids = cards,
            info = table.map(cards, function(id) return {cardId = id, fromArea = Card.PlayerSpecial,
              fromSpecialName = "mini_miaobi_penmanship"} end),
            from = player.id,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonPutIntoDiscardPile,
            skillName = miaobi.name,
          }
        else
          for _, cid in ipairs(cards) do
            local card = Fk:getCardById(cid)
            if from:canUse(card) and not from:prohibitUse(card) and not from:isProhibited(player, card) and
              (card.skill:modTargetFilter(player.id, {}, from, card, false)) then
              local tos = { {player.id} }
              if card.skill:getMinTargetNum() == 2 then
                local targets = table.filter(room.alive_players, function (p)
                  return player ~= p and card.skill:targetFilter(p.id, {player.id}, {}, card, nil, from)
                end)
                if #targets > 0 then
                  local to_slash = room:askToChoosePlayers(from, {targets = table.map(targets, Util.IdMapper), min_num = 1, max_num = 1, prompt = "#mini_miaobi-choose::"..player.id..":"..card:toLogString(), skill_name = miaobi.name, cancelable = false})
                  if #to_slash > 0 then
                    table.insert(tos, to_slash)
                  end
                end
              end

              if #tos >= card.skill:getMinTargetNum() then
                room:useCard({
                  from = from.id,
                  tos = tos,
                  card = card,
                })
              end
            end
          end
          cards = table.filter(cards, function (cid)
            return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
          end)
        end
      end
      if #cards > 0 then
        room:moveCards{
          ids = cards,
          info = table.map(cards, function(id) return {cardId = id, fromArea = Card.PlayerSpecial,
            fromSpecialName = "mini_miaobi_penmanship"} end),
          from = player.id,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = miaobi.name,
        }
      end
    end
    room:setPlayerMark(player, "_mini_miaobi", 0)
  end,
})

return miaobi
