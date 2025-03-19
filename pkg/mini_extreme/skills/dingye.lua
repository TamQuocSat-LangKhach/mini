local dingye = fk.CreateSkill {
  name = "mini_dingye"
}

Fk:loadTranslationTable{
  ['mini_dingye'] = '鼎业',
  [':mini_dingye'] = '结束阶段，你回复X点体力。（X为此回合受到过伤害的其他角色数）',
  ['$mini_dingye1'] = '凭三江之固，以观天下成败！',
  ['$mini_dingye2'] = '吾志岂安于此，当在天下万方！',
}

dingye:addEffect(fk.EventPhaseStart, {
  can_trigger = function (self, event, target, player)
    if not (target == player and player:hasSkill(dingye.name) and player.phase == Player.Finish and player:isWounded()) then return end
    local targets = {}
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      table.insertIfNeed(targets, damage.to.id)
      return false
    end)
    table.removeOne(targets, player.id)
    if #targets > 0 then
      event:setCostData(self, #targets)
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player)
    local num = event:getCostData(self)
    player.room:recover{
      from = player,
      who = player,
      num = num,
      reason = dingye.name
    }
  end
})

return dingye
