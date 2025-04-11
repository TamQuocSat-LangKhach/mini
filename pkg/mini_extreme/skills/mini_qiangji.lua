local miniQiangji = fk.CreateSkill {
  name = "mini__qiangji"
}

Fk:loadTranslationTable{
  ["mini__qiangji"] = "强忌",
  [":mini__qiangji"] = "每回合限一次，当一名其他角色于其回合外一次性获得至少两张手牌后，你可以猜测其手牌中牌最多的一种花色，若你猜对，对其造成1点伤害。",

  ["#mini__qiangji-choice"] = "强忌：猜测 %dest 手牌中最多的花色，若猜对，对其造成1点伤害",
}

miniQiangji:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  trigger_times = function(self, event, target, player, data)
    local miniQiangjiTargets = event:getSkillData(self, "mini__qiangji_" .. player.id)
    if miniQiangjiTargets then
      local unDoneTargets = table.simpleClone(miniQiangjiTargets.unDone)
      for _, to in ipairs(unDoneTargets) do
        if not to:isAlive() or to:isNude() then
          table.remove(miniQiangjiTargets.unDone, 1)
        else
          break
        end
      end

      return #miniQiangjiTargets.unDone + #miniQiangjiTargets.done
    end

    local moveMap = {}
    for _, move in ipairs(data) do
      if
        move.to and
        move.to ~= player and
        player.room.current ~= move.to and
        move.toArea == Card.PlayerHand
      then
        moveMap[move.to] = (moveMap[move.to] or 0) + #move.moveInfo
      end
    end

    miniQiangjiTargets = { unDone = {}, done = {} }
    for to, cardsNum in pairs(moveMap) do
      if cardsNum > 1 then
        table.insert(miniQiangjiTargets.unDone, to)
      end
    end

    if #miniQiangjiTargets.unDone > 0 then
      player.room:sortByAction(miniQiangjiTargets.unDone)
      event:setSkillData(self, "mini__qiangji_" .. player.id, miniQiangjiTargets)
    end
    return #miniQiangjiTargets.unDone
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(miniQiangji.name) and player:usedSkillTimes(miniQiangji.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local miniQiangjiTargets = event:getSkillData(self, "mini__qiangji_" .. player.id)
    local to = table.remove(miniQiangjiTargets.unDone, 1)
    table.insert(miniQiangjiTargets.done, to)
    event:setSkillData(self, "mini__qiangji_" .. player.id, miniQiangjiTargets)

    local choice = player.room:askToChoice(
      player,
      {
        choices = { "log_spade", "log_club", "log_heart", "log_diamond", "Cancel" },
        skill_name = miniQiangji.name,
        prompt = "#mini__qiangji-choice::" .. to.id,
      }
    )
    if choice ~= "Cancel" then
      event:setCostData(self, { tos = { to.id }, choice = choice })
      return true
    end
  end,
  on_trigger = function(self, event, target, player, data)
    event:setSkillData(self, "cancel_cost", false)
    self:doCost(event, target, player, data)
    event:setSkillData(self, "cancel_cost", false)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    local choice = event:getCostData(self).choice
    local to = room:getPlayerById(tos[1])
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = event:getCostData(self).choice,
      toast = true,
    }
    local nums = {
      ["log_spade"] = 0,
      ["log_club"] = 0,
      ["log_heart"] = 0,
      ["log_diamond"] = 0,
    }
    for _, id in ipairs(to:getCardIds("h")) do
      nums[Fk:getCardById(id):getSuitString(true)] = nums[Fk:getCardById(id):getSuitString(true)] + 1
    end
    local n = nums[choice]
    for _, num in pairs(nums) do
      if num > n then
        return
      end
    end
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = miniQiangji.name,
    }
  end,
})

return miniQiangji
