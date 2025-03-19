local qumou = fk.CreateSkill {
  name = "mini__qumou"
}

Fk:loadTranslationTable{
  ['mini__qumou'] = '屈谋',
  ['#mini__qumou-choice'] = '屈谋：本回合无法使用、打出或弃置一种牌，你使用下两张另一种牌无距离次数限制且可以多选择一个目标',
  ['@mini__qumou_basic'] = '屈谋 基本牌',
  ['@mini__qumou_trick'] = '屈谋 锦囊牌',
  ['#mini__qumou_trigger'] = '屈谋',
  ['#mini__qumou_trigger-choose'] = '屈谋：你可以为此%arg额外指定一个目标',
  [':mini__qumou'] = '出牌阶段开始时，你可以令你本回合无法使用、打出或弃置基本牌/锦囊牌。若如此做，你使用的下两张普通锦囊牌/基本牌无距离和次数限制，且可以多选择一个目标。',
}

qumou:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(qumou.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player)
    local choice = player.room:askToChoice(player, {
      choices = {"basic", "trick", "Cancel"},
      skill_name = qumou.name,
      prompt = "#mini__qumou-choice"
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local type = event:getCostData(self).choice
    room:addTableMarkIfNeed(player, "mini__qumou-turn", type)
    type = type == "basic" and "trick" or "basic"
    room:setPlayerMark(player, "@mini__qumou_"..type, 2)
  end,
})

qumou:addEffect(fk.PreCardUse, {
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if data.card.type == Card.TypeBasic and player:getMark("@mini__qumou_basic") > 0 then
        return true
      elseif data.card:isCommonTrick() and player:getMark("@mini__qumou_trick") > 0 then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    data.extraUse = true
    data.extra_data = data.extra_data or {}
    data.extra_data.mini__qumou = true
    player.room:removePlayerMark(player, "@mini__qumou_"..data.card:getTypeString(), 1)
  end,
})

qumou:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and #player.room:getUseExtraTargets(data) > 0 and
      data.extra_data and data.extra_data.mini__qumou
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getUseExtraTargets(data),
      min_num = 1,
      max_num = 1,
      prompt = "#mini__qumou_trigger-choose:::"..data.card:toLogString(),
      skill_name = "mini__qumou",
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("mini__qumou")
    local room = player.room
    table.insert(data.tos, event:getCostData(self).tos[1])
    room:sendLog{
      type = "#AddTargetsBySkill",
      from = player.id,
      to = event:getCostData(self).tos,
      arg = "mini__qumou",
      arg2 = data.card:toLogString()
    }
  end,
})

qumou:addEffect('targetmod', {
  bypass_distances = function(self, player, skill, card)
    if card then
      if card.type == Card.TypeBasic and player:getMark("@mini__qumou_basic") > 0 then
        return true
      end
      if card:isCommonTrick() and player:getMark("@mini__qumou_trick") > 0 then
        return true
      end
    end
  end,
  bypass_times = function (self, player, skill, scope, card)
    if card then
      if card.type == Card.TypeBasic and player:getMark("@mini__qumou_basic") > 0 then
        return true
      end
      if card:isCommonTrick() and player:getMark("@mini__qumou_trick") > 0 then
        return true
      end
    end
  end,
})

qumou:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
    return table.contains(player:getTableMark("mini__qumou-turn"), card:getTypeString())
  end,
  prohibit_response = function (self, player, card)
    return table.contains(player:getTableMark("mini__qumou-turn"), card:getTypeString())
  end,
  prohibit_discard = function (self, player, card)
    return table.contains(player:getTableMark("mini__qumou-turn"), card:getTypeString())
  end,
})

return qumou
