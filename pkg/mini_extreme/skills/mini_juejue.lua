local miniJuejue = fk.CreateSkill {
  name = "mini__juejue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini__juejue"] = "绝决",
  [":mini__juejue"] = "锁定技，一名角色回合结束时，若你本回合失去过所有手牌，你令一名角色失去1点体力。",

  ["#mini__juejue-choose"] = "绝决：令一名角色失去1点体力",
}

miniJuejue:addEffect(fk.TurnEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(miniJuejue.name) and player:getMark("mini__juejue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = miniJuejue.name
    local room = player.room
    local to = room:askToChoosePlayers(
      player,
      {
        targets = room:getAlivePlayers(false),
        min_num = 1,
        max_num = 1,
        prompt = "#mini__juejue-choose",
        skill_name = skillName,
        cancelable = false,
      }
    )
    room:loseHp(to[1], 1, skillName)
  end,
})

miniJuejue:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if not player:isKongcheng() or player:getMark("mini__juejue-turn") > 0 then return end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "mini__juejue-turn", 1)
  end,
})

return miniJuejue
