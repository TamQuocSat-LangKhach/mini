local sixiao = fk.CreateSkill {
  name = "sixiao"
}

Fk:loadTranslationTable{
  ["sixiao"] = "死孝",
  [":sixiao"] = "游戏开始时，你选择一名其他角色。每名角色的回合限一次，当其需要使用除【无懈可击】以外的牌时，" ..
  "其可以观看你的手牌，并可以选择其中一张牌使用之，然后你摸一张牌。",

  ["#sixiao-resp"] = "死孝：你可观看 %src 的手牌，若有你需要使用的牌，你可使用之！",
  ["#sixiao-choose"] = "死孝：选择一名其他角色，其每回合可以使用一张你的手牌！",
  ["@sixiao"] = "死孝",
  ["#sixiao-card"] = "死孝：你可从 %src 的手牌中选择一张使用",
  ["#sixiao-target"] = "死孝：选择使用 %arg 的目标角色",

  ["$sixiao1"] = "风木之悲，痛彻肺腑。",
  ["$sixiao2"] = "外容毁悴，内心神伤。",
}

sixiao:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sixiao.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player, false)
    if #targets > 0 then
      local tos = room:askToChoosePlayers(
        player,
        {
          targets = targets,
          min_num = 1,
          max_num = 1,
          prompt = "#sixiao-choose",
          skill_name = sixiao.name,
          cancelable = false,
        }
      )
      if #tos > 0 then
        local to = tos[1]
        room:setPlayerMark(player, "@sixiao", to.general)
        room:setPlayerMark(player, "sixiao_to", to.id)
        room:handleAddLoseSkills(to, "sixiao_other&", nil, false, true)
      end
    end
  end,
})

sixiao:addEffect(fk.AskForCardUse, {
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(sixiao.name) and
      not player:isKongcheng() and
      player:getMark("sixiao_to") == target.id and
      target:getMark("sixiao_invoked-turn") == 0 and
      data.pattern
  end,
  on_cost = function(self, event, target, player, data)
    return
      player.room:askToSkillInvoke(
        target,
        {
          skill_name = sixiao.name,
          prompt = "#sixiao-resp:" .. player.id,
        }
      )
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = sixiao.name
    local room = player.room
    room:setPlayerMark(target, "sixiao_invoked-turn", 1)
    room:doIndicate(target, { player })
    -- copy jixiang
    local extra_data = data.extraData
    local isAvailableTarget = function(card, p)
      if extra_data then
        if
          type(extra_data.must_targets) == "table" and
          #extra_data.must_targets > 0 and
          not table.contains(extra_data.must_targets, p.id)
        then
          return false
        end
        if
          type(extra_data.exclusive_targets) == "table" and
          #extra_data.exclusive_targets > 0 and
          not table.contains(extra_data.exclusive_targets, p.id)
        then
          return false
        end
      end
      return not target:isProhibited(p, card) and card.skill:modTargetFilter(target, p, {}, card, extra_data)
    end
    local findCardTarget = function(card)
      local tos = {}
      for _, p in ipairs(room.alive_players) do
        if isAvailableTarget(card, p) then
          table.insert(tos, p)
        end
      end
      return tos
    end
    local cids = room:askToCards(
      target,
      {
        min_num = 1,
        max_num = 1,
        skill_name = skillName,
        pattern = data.pattern,
        prompt = "#sixiao-card:" .. player.id,
        expand_pile = player:getCardIds("h"),
      }
    )

    if #cids == 0 then return false end
    local card = Fk:getCardById(cids[1])
    data.result = {
      from = target,
      card = card,
    }
    if card.skill:getMinTargetNum(target) == 1 then
      local tos = findCardTarget(card)
      if #tos == 1 then
        data.result.tos = tos
      elseif #tos > 1 then
        data.result.tos = room:askToChoosePlayers(
          target,
          {
            targets = tos,
            min_num = 1,
            max_num = 1,
            prompt = "#sixiao-target:::" .. card:toLogString(),
            skill_name = skillName,
            cancelable = false,
            no_indicate = true,
          }
        )
      else
        return false
      end
    end

    if data.eventData then
      data.result.toCard = data.eventData.toCard
      data.result.responseToEvent = data.eventData.responseToEvent
    end
    player:drawCards(1, skillName) -- FIXEME: drawcard should be delayed
    return true
  end,
})

sixiao:addLoseEffect(function(self, player)
  if player:getMark("sixiao_to") ~= 0 then
    local room = player.room
    local to = room:getPlayerById(player:getMark("sixiao_to"))
    if to and table.every(room:getOtherPlayers(player, false), function(p) return p:getMark("sixiao_to") ~= to.id end) then
      room:handleAddLoseSkills(to, "-sixiao_other&", nil, false, true)
    end
    room:setPlayerMark(player, "@sixiao", 0)
    room:setPlayerMark(player, "sixiao_to", 0)
  end
end)

return sixiao
