local miniex__qugu = fk.CreateSkill {
  name = "miniex__qugu"
}

Fk:loadTranslationTable{
  ['miniex__qugu'] = '曲顾',
  [':miniex__qugu'] = '每回合你首次成为其他角色使用牌的目标后，你可以从牌堆中获得一张与此牌类别不同的牌。',
  ['$miniex__qugu1'] = '妙手易有，佳音难得。',
  ['$miniex__qugu2'] = '曲有误处，难免回顾。',
}

miniex__qugu:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(miniex__qugu.name) and data.from and data.from ~= player.id
      and player:usedSkillTimes(miniex__qugu.name, Player.HistoryTurn) == 0 then
      local firstEvent = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        return table.contains(TargetGroup:getRealTargets(e.data[1].tos), player.id)
      end, Player.HistoryTurn)[1]
      local useParent = player.room.logic:getCurrentEvent()
      return useParent and firstEvent and useParent.id == firstEvent.id
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getCardsFromPileByRule(".|.|.|.|.|^"..data.card:getTypeString())
    if #ids > 0 then
      room:obtainCard(player, ids, true, fk.ReasonJustMove, player.id, miniex__qugu.name)
    end
  end,
})

return miniex__qugu
