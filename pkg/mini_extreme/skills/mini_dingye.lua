local miniDingye = fk.CreateSkill {
  name = "mini_dingye"
}

Fk:loadTranslationTable{
  ["mini_dingye"] = "鼎业",
  [":mini_dingye"] = "结束阶段，你回复X点体力。（X为此回合受到过伤害的其他角色数）",

  ["$mini_dingye1"] = "凭三江之固，以观天下成败！",
  ["$mini_dingye2"] = "吾志岂安于此，当在天下万方！",
}

miniDingye:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player)
    if not (target == player and player:hasSkill(miniDingye.name) and player.phase == Player.Finish and player:isWounded()) then
      return false
    end

    return #player.room.logic:getActualDamageEvents(1, function(e)
      return e.data.to ~= player
    end) > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player)
    local room = player.room
    local targets = {}
    room.logic:getActualDamageEvents(1, function(e)
      table.insertIfNeed(targets, e.data.to)
      return false
    end)

    room:recover{
      from = player,
      who = player,
      num = #targets,
      reason = miniDingye.name,
    }
  end
})

return miniDingye
