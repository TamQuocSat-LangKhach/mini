local hezong = fk.CreateSkill {
  name = "mini_hezong"
}

Fk:loadTranslationTable{
  ['mini_hezong'] = '合纵',
  ['#mini_hezong-ask'] = '是否发动 合纵，选择两名角色',
  ['@mini_hezong-round'] = '合纵',
  ['#mini_hezong_delay'] = '合纵',
  ['#mini_hezong-use'] = '合纵：你需对 %dest 使用一张【杀】，否则交给 %src 一张牌',
  ['#mini_hezong-give_slash'] = '合纵：交给 %dest 一张牌',
  ['#mini_hezong-give'] = '合纵：你需交给 %dest 一张【闪】，否则成为此【杀】的额外目标。',
  [':mini_hezong'] = '每轮开始时，你可以选择两名角色，本轮内：当其中一名角色使用【杀】指定除这些角色以外的角色为唯一目标结算后，另一名角色须对相同目标使用一张【杀】，否则交给其一张牌；当其中一名角色成为除这些角色以外的角色使用【杀】的唯一目标时，另一名角色须交给目标角色一张【闪】，否则成为此【杀】的额外目标。',
  ['$mini_hezong1'] = '合众弱以攻一强，此为破曹之策也。',
  ['$mini_hezong2'] = '孙刘分则为弱，合则无往不利。',
}

hezong:addEffect(fk.RoundStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(skill.name)
  end,
  on_cost = function(self, event, target, player)
    local targets = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room.alive_players, Util.IdMapper),
      min_num = 2,
      max_num = 2,
      prompt = "#mini_hezong-ask",
      skill_name = skill.name
    })
    if #targets > 0 then
      event:setCostData(skill, targets)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local targets = event:getCostData(skill)
    for i, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      room:addTableMarkIfNeed(p, "@mini_hezong-round", room:getPlayerById(targets[3-i]).general)
      room:addTableMarkIfNeed(p, "_mini_hezong-round", targets[3-i])
    end
  end,
})

hezong:addEffect({fk.CardUseFinished, fk.TargetConfirming}, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if data.card.trueName ~= "slash" or target.id ~= player:getMark("_mini_hezong-round") then return false end
    if event == fk.CardUseFinished then
      local tos = TargetGroup:getRealTargets(data.tos)
      if #tos == 0 or tos[1] == player.id or tos[1] == player:getMark("_mini_hezong-round") then return end
      for _, pid in ipairs(tos) do
        if pid ~= tos[1] then
          return false
        end
      end
      event:setCostData(skill, tos[1])
      return not player.room:getPlayerById(tos[1]).dead
    else
      event:setCostData(skill, nil)
      return U.isOnlyTarget(target, data, event) and data.from ~= player.id and data.from ~= player:getMark("_mini_hezong-round")
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    local responser = target == player and room:getPlayerById(player:getMark("_mini_hezong-round")) or player
    if event == fk.CardUseFinished then
      local to = event:getCostData(skill)
      local use = room:askToUseCard(responser, {
        pattern = "slash",
        prompt = "#mini_hezong-use:" .. target.id .. ":" .. to,
        cancelable = true,
        extra_data = {exclusive_targets = {to}, bypass_times = true, bypass_distances = true}
      })
      if use then
        use.extraUse = true
        room:useCard(use)
      elseif not responser:isNude() then
        local card = room:askToCards(responser, {
          min_num = 1,
          max_num = 1,
          skill_name = skill.name,
          prompt = "#mini_hezong-give_slash::" .. target.id
        })
        room:moveCardTo(card[1], Card.PlayerHand, target, fk.ReasonGive, skill.name, nil, true, player.id)
      end
    else
      local card = room:askToCards(responser, {
        min_num = 1,
        max_num = 1,
        pattern = "jink",
        skill_name = skill.name,
        prompt = "#mini_hezong-give::" .. target.id
      })
      if #card > 0 then
        room:moveCardTo(card[1], Card.PlayerHand, target, fk.ReasonGive, skill.name, nil, true, player.id)
      else
        AimGroup:addTargets(room, data, responser.id)
      end
    end
  end,
})

return hezong
