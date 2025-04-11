local miniHezong = fk.CreateSkill {
  name = "mini_hezong"
}

Fk:loadTranslationTable{
  ["mini_hezong"] = "合纵",
  [":mini_hezong"] = "每轮开始时，你可以选择两名角色，本轮内：当其中一名角色使用【杀】指定除这些角色以外的角色为唯一目标结算后，" ..
  "另一名角色须对相同目标使用一张【杀】，否则交给其一张牌；当其中一名角色成为除这些角色以外的角色使用【杀】的唯一目标时，" ..
  "另一名角色须交给目标角色一张【闪】，否则成为此【杀】的额外目标。",

  ["#mini_hezong-ask"] = "是否发动 合纵，选择两名角色",
  ["@mini_hezong-round"] = "合纵",
  ["#mini_hezong-use"] = "合纵：你需对 %dest 使用一张【杀】，否则交给 %src 一张牌",
  ["#mini_hezong-give_slash"] = "合纵：交给 %dest 一张牌",
  ["#mini_hezong-give"] = "合纵：你需交给 %dest 一张【闪】，否则成为此【杀】的额外目标。",

  ["$mini_hezong1"] = "合众弱以攻一强，此为破曹之策也。",
  ["$mini_hezong2"] = "孙刘分则为弱，合则无往不利。",
}

miniHezong:addEffect(fk.RoundStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player)
    return player:hasSkill(miniHezong.name)
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local targets = player.room:askToChoosePlayers(
      player,
      {
        targets = room:getAlivePlayers(false),
        min_num = 2,
        max_num = 2,
        prompt = "#mini_hezong-ask",
        skill_name = miniHezong.name,
      }
    )
    if #targets > 0 then
      event:setCostData(self, targets)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local targets = event:getCostData(self)
    for i, p in ipairs(targets) do
      room:addTableMarkIfNeed(p, "@mini_hezong-round", targets[3 - i].general)
      room:addTableMarkIfNeed(p, "_mini_hezong-round", targets[3 - i].id)
    end
  end,
})

miniHezong:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      data.card.trueName == "slash" and
      table.contains(player:getTableMark("_mini_hezong-round"), target.id) and
      #data.tos > 0 and
      data:isOnlyTarget(data.tos[1]) and
      data.tos[1] ~= player and
      not table.contains(player:getTableMark("_mini_hezong-round"), data.tos[1].id) and
      data.tos[1]:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniHezong.name
    local room = player.room
    local toId = data.tos[1].id
    local use = room:askToUseCard(
      player,
      {
        pattern = "slash",
        prompt = "#mini_hezong-use:" .. target.id .. ":" .. toId,
        skill_name = skillName,
        extra_data = { exclusive_targets = { toId }, bypass_times = true, bypass_distances = true },
      }
    )
    if use then
      use.extraUse = true
      room:useCard(use)
    elseif not player:isNude() then
      local card = room:askToCards(
        player,
        {
          min_num = 1,
          max_num = 1,
          skill_name = skillName,
          prompt = "#mini_hezong-give_slash::" .. target.id,
          cancelable = false,
        }
      )
      room:moveCardTo(card[1], Card.PlayerHand, target, fk.ReasonGive, skillName, nil, true, player)
    end
  end,
})

miniHezong:addEffect(fk.TargetConfirming, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      data.card.trueName == "slash" and
      table.contains(player:getTableMark("_mini_hezong-round"), target.id) and
      data:isOnlyTarget(target) and
      data.from ~= player and
      not table.contains(player:getTableMark("_mini_hezong-round"), data.from.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniHezong.name
    local room = player.room
    local card = room:askToCards(
      player,
      {
        min_num = 1,
        max_num = 1,
        pattern = "jink",
        skill_name = skillName,
        prompt = "#mini_hezong-give::" .. target.id,
      }
    )
    if #card > 0 then
      room:moveCardTo(card[1], Card.PlayerHand, target, fk.ReasonGive, skillName, nil, true, player)
    else
      if not data.from:isProhibited(player, data.card) then
        room:doIndicate(data.from, { player })
        data:addTarget(player)
      end
    end
  end,
})

return miniHezong
