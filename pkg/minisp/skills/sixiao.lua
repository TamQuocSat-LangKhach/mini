local sixiao = fk.CreateSkill {
  name = "sixiao"
}

Fk:loadTranslationTable{
  ['sixiao'] = '死孝',
  ['#sixiao-resp'] = '死孝：你可观看 %src 的手牌，若有你需要使用的牌，你可使用之！',
  ['#sixiao-choose'] = '死孝：选择一名其他角色，其每回合可以使用一张你的手牌！',
  ['@sixiao'] = '死孝',
  ['sixiao_other&'] = '死孝',
  ['#sixiao-card'] = '死孝：你可从 %src 的手牌中选择一张使用',
  ['#sixiao-target'] = '死孝：选择使用 %arg 的目标角色',
  [':sixiao'] = '游戏开始时，你选择一名其他角色。每名角色的回合限一次，当其需要使用除【无懈可击】以外的牌时，其可以观看你的手牌，并可以选择其中一张牌使用之，然后你摸一张牌。',
  ['$sixiao1'] = '风木之悲，痛彻肺腑。',
  ['$sixiao2'] = '外容毁悴，内心神伤。',
}

sixiao:addEffect({fk.GameStart, fk.AskForCardUse}, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(sixiao.name) then return false end
    if event == fk.GameStart then return true end
    return not player:isKongcheng() and player:getMark("sixiao_to") == target.id and target:getMark("sixiao_invoked-turn") == 0
      and data.pattern
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.GameStart then return true end
    return player.room:askToSkillInvoke(target, {skill_name = sixiao.name, prompt = "#sixiao-resp:"..player.id})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
      if #targets > 0 then
        local tos = room:askToChoosePlayers(player, {
          targets = targets,
          min_num = 1,
          max_num = 1,
          prompt = "#sixiao-choose",
          skill_name = sixiao.name,
          cancelable = false,
        })
        if #tos > 0 then
          local to = room:getPlayerById(tos[1])
          room:setPlayerMark(player, "@sixiao", to.general)
          room:setPlayerMark(player, "sixiao_to", to.id)
          room:handleAddLoseSkills(to, "sixiao_other&", nil, false, true)
        end
      end
    else
      room:setPlayerMark(target, "sixiao_invoked-turn", 1)
      room:doIndicate(target.id, {player.id})
      -- copy jixiang
      local extra_data = data.extraData
      local isAvailableTarget = function(card, p)
        if extra_data then
          if type(extra_data.must_targets) == "table" and #extra_data.must_targets > 0 and
            not table.contains(extra_data.must_targets, p.id) then
            return false
          end
          if type(extra_data.exclusive_targets) == "table" and #extra_data.exclusive_targets > 0 and
            not table.contains(extra_data.exclusive_targets, p.id) then
            return false
          end
        end
        return not target:isProhibited(p, card) and card.skill:modTargetFilter(p.id, {}, target, card, true)
      end
      local findCardTarget = function(card)
        local tos = {}
        for _, p in ipairs(room.alive_players) do
          if isAvailableTarget(card, p) then
            table.insert(tos, p.id)
          end
        end
        return tos
      end
      local cids = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        pattern = data.pattern,
        prompt = "#sixiao-card:"..player.id,
        expand_pile = player:getCardIds("h"),
      })
      --local cids = U.askforChooseCardsAndChoice(target, cards, {"OK"}, self.name, "#sixiao-card:"..player.id, {"Cancel"}, 1, 1, allcards)
      if #cids == 0 then return false end
      local card = Fk:getCardById(cids[1])
      data.result = {
        from = target.id,
        card = card,
      }
      if card.skill:getMinTargetNum() == 1 then
        local tos = findCardTarget(card)
        if #tos == 1 then
          data.result.tos = {{tos[1]}}
        elseif #tos > 1 then
          data.result.tos = {room:askToChoosePlayers(target, {
            targets = tos,
            min_num = 1,
            max_num = 1,
            prompt = "#sixiao-target:::"..card:toLogString(),
            skill_name = sixiao.name,
            cancelable = false,
          })}
        else
          return false
        end
      end
      if data.eventData then
        data.result.toCard = data.eventData.toCard
        data.result.responseToEvent = data.eventData.responseToEvent
      end
      player:drawCards(1, sixiao.name) -- FIXEME: drawcard should be delayed
      return true
    end
  end,
})

sixiao:addEffect({fk.BuryVictim, fk.EventLoseSkill}, {
  global = false,
  can_refresh = function(self, event, target, player, data)
    if player:getMark("sixiao_to") ~= 0 and target == player then
      return (event == fk.BuryVictim) or (data == sixiao.name)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("sixiao_to"))
    if to and table.every(room:getOtherPlayers(player, false), function(p) return p:getMark("sixiao_to") ~= to.id end) then
      room:handleAddLoseSkills(to, "-sixiao_other&", nil, false, true)
    end
    room:setPlayerMark(player, "@sixiao", 0)
    room:setPlayerMark(player, "sixiao_to", 0)
  end,
})

return sixiao
