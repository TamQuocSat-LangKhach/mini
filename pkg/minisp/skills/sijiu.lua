local sijiu = fk.CreateSkill {
  name = "sijiu"
}

Fk:loadTranslationTable{
  ['sijiu'] = '思旧',
  ['#sijiu-choose'] = '思旧：观看一名其他角色的手牌',
  [':sijiu'] = '每轮结束时，若你本轮获得过其他角色的牌，你可以摸一张牌并观看一名其他角色的手牌。',
  ['$sijiu1'] = '悼嵇生之永辞兮，顾日影而弹琴。',
  ['$sijiu2'] = '托运遇于领会兮，寄余命于寸阴。',
}

sijiu:addEffect(fk.RoundEnd, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player)
    if player:hasSkill(sijiu.name) then
      return #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from and move.from ~= move.to and move.to == player.id and move.toArea == Card.PlayerHand then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                return true
              end
            end
          end
        end
        return false
      end, Player.HistoryRound) > 0
    end
  end,
  on_use = function (self, event, target, player)
    local room = player.room
    player:drawCards(1, sijiu.name)
    if player.dead then return end
    local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isKongcheng() end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#sijiu-choose",
      skill_name = sijiu.name,
      cancelable = false
    })
    if #tos > 0 then
      local to = room:getPlayerById(tos[1].id)
      U.viewCards(player, to.player_cards[Player.Hand], sijiu.name, "$ViewCardsFrom:"..to.id)
    end
  end,
})

return sijiu
