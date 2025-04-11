local miniMiaobi = fk.CreateSkill {
  name = "mini_miaobi",
}

Fk:loadTranslationTable{
  ["mini_miaobi"] = "妙笔",
  [":mini_miaobi"] = "当你于出牌阶段内使用的、非转化且非虚拟的锦囊牌结算结束后，你可将此牌置于其中一个目标角色的武将牌上（每牌名每回合限一次）。" ..
  "拥有“妙笔”牌的角色的准备阶段，其选择一项：1. 交给你一张锦囊牌，将“妙笔”牌置入弃牌堆；2. 你对其依次使用“妙笔”牌。",

  ["mini_miaobi_penmanship"] = "妙笔",
  ["#mini_miaobi_only-ask"] = "妙笔：你可将%arg置于%dest的武将牌上",
  ["#mini_miaobi-ask"] = "妙笔：你可将%arg置于一个目标角色的武将牌上",
  ["#mini_miaobi_delay"] = "妙笔：将一张锦囊牌交给 %src，否则其对你依次使用“妙笔”牌",
  ["#mini_miaobi-choose"] = "妙笔：选择对%dest使用的%arg的副目标",

  ["$mini_miaobi1"] = "行舟泛知海，点墨启新灵。",
  ["$mini_miaobi2"] = "纵横览前贤，风月皆成鉴。",
}

local U = require "packages/utility/utility"

miniMiaobi:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniMiaobi.name) and
      player.phase == Player.Play and
      data.card.type == Card.TypeTrick and
      U.isPureCard(data.card) and
      not table.contains(player:getTableMark("_mini_miaobi_used-turn"), data.card.trueName) and
      player.room:getCardArea(data.card) == Card.Processing and
      table.find(data.tos, function(p) return p:isAlive() end)
  end,
  on_cost = function(self, event, target, player, data)
    ---@type string
    local skillName = miniMiaobi.name
    local targets = table.filter(data.tos, function(p) return p:isAlive() end)
    local room = player.room
    if #targets == 1 then
      if
        room:askToSkillInvoke(
          player,
          {
            skill_name = skillName,
            prompt = "#mini_miaobi_only-ask::" .. targets[1].id .. ":" .. data.card:toLogString()
          }
        )
      then
        event:setCostData(self, targets[1])
        return true
      end
    else
      local tos = room:askToChoosePlayers(
        player,
        {
          targets = targets,
          min_num = 1,
          max_num = 1,
          prompt = "#mini_miaobi-ask:::" .. data.card:toLogString(),
          skill_name = skillName,
        }
      )
      if #tos > 0 then
        event:setCostData(self, tos[1])
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addTableMark(player, "_mini_miaobi_used-turn", data.card.trueName)
    local to = event:getCostData(self)
    to:addToPile("mini_miaobi_penmanship", data.card, true, miniMiaobi.name)
    if table.contains(to:getPile("mini_miaobi_penmanship"), data.card.id) then
      local record = to:getTableMark("_mini_miaobi")
      record[tostring(player.id)] = record[tostring(player.id)] or {}
      table.insert(record[tostring(player.id)], data.card.id)
      room:setPlayerMark(to, "_mini_miaobi", record)
    end
  end,
})

miniMiaobi:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player)
    return #player:getPile("mini_miaobi_penmanship") > 0 and player.phase == Player.Start
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    ---@type string
    local skillName = miniMiaobi.name
    local room = player.room
    local record = table.simpleClone(player:getMark("_mini_miaobi"))
    for k, v in pairs(record) do
      local from = room:getPlayerById(tonumber(k))
      local cards = table.filter(v, function (cid)
        return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
      end)
      if from:isAlive() and #cards > 0 then
        local c = {}
        if player ~= from then
          c = room:askToCards(
            player,
            {
              min_num = 1,
              max_num = 1,
              pattern = ".|.|.|.|.|trick",
              prompt = "#mini_miaobi_delay:" .. from.id,
              skill_name = skillName,
            }
          )
        end
        if #c > 0 then
          room:moveCardTo(c[1], Card.PlayerHand, from, fk.ReasonGive, skillName, nil, true, from)
          cards = table.filter(cards, function (cid)
            return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
          end)
          room:moveCards{
            ids = cards,
            from = player,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonPutIntoDiscardPile,
            skillName = skillName,
            proposer = player,
          }
        else
          for _, cid in ipairs(cards) do
            local card = Fk:getCardById(cid)
            if from:isAlive() and from:canUseTo(card, player, { bypass_distances = true, bypass_times = true }) then
              local tos = { player }
              if card.skill:getMinTargetNum(from) == 2 then
                local targets = table.filter(room.alive_players, function (p)
                  return card.skill:targetFilter(from, p, { player }, {}, card)
                end)
                if #targets > 0 then
                  local to_slash = room:askToChoosePlayers(
                    from,
                    {
                      targets = targets,
                      min_num = 1,
                      max_num = 1,
                      prompt = "#mini_miaobi-choose::" .. player.id .. ":" .. card:toLogString(),
                      skill_name = skillName,
                      cancelable = false,
                    }
                  )
                  if #to_slash > 0 then
                    table.insert(tos, to_slash[1])
                  end
                end
              end

              if #tos >= card.skill:getMinTargetNum(from) then
                room:useCard({
                  from = from,
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
          from = player,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = skillName,
        }
      end
    end
    room:setPlayerMark(player, "_mini_miaobi", 0)
  end,
})

return miniMiaobi
