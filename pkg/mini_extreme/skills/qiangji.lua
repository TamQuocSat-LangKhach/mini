local qiangji = fk.CreateSkill {
  name = "mini__qiangji"
}

Fk:loadTranslationTable{
  ['mini__qiangji'] = '强忌',
  ['#mini__qiangji-choice'] = '强忌：猜测 %dest 手牌中最多的花色，若猜对，对其造成1点伤害',
  [':mini__qiangji'] = '每回合限一次，当一名其他角色于其回合外一次性获得至少两张手牌后，你可以猜测其手牌中牌最多的一种花色，若你猜对，对其造成1点伤害。',
}

qiangji:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qiangji.name) and player:usedSkillTimes(qiangji.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if #move.moveInfo > 1 and (move.to and move.to ~= player.id and
          player.room.current.id ~= move.to and move.toArea == Card.PlayerHand) then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if #move.moveInfo > 1 and (move.to and move.to ~= player.id and
        player.room.current.id ~= move.to and move.toArea == Card.PlayerHand) then
        table.insertIfNeed(targets, move.to)
      end
    end
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      if not player:hasSkill(qiangji.name) or player:usedSkillTimes(qiangji.name, Player.HistoryTurn) > 0 then return end
      local p = room:getPlayerById(id)
      if not p.dead then
        skill:doCost(event, p, player, nil)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      choices = {"log_spade", "log_club", "log_heart", "log_diamond", "Cancel"},
      skill_name = qiangji.name,
      prompt = "#mini__qiangji-choice::" .. target.id
    })
    if choice ~= "Cancel" then
      event:setCostData(skill, {tos = {target.id}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = event:getCostData(skill).choice,
      toast = true,
    }
    local nums = {
      ["log_spade"] = 0,
      ["log_club"] = 0,
      ["log_heart"] = 0,
      ["log_diamond"] = 0,
    }
    for _, id in ipairs(target:getCardIds("h")) do
      nums[Fk:getCardById(id):getSuitString(true)] = nums[Fk:getCardById(id):getSuitString(true)] + 1
    end
    local n = nums[event:getCostData(skill).choice]
    for _, num in pairs(nums) do
      if num > n then
        return
      end
    end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = qiangji.name,
    }
  end,
})

return qiangji
