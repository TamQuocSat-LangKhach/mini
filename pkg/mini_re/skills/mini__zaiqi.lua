local mini__zaiqi = fk.CreateSkill {
  name = "mini__zaiqi"
}

Fk:loadTranslationTable{
  ['mini__zaiqi'] = '再起',
  ['#mini__zaiqi-ask'] = '再起：选择一种颜色，获得该颜色的所有牌',
  ['@mini__zaiqi'] = '再起',
  [':mini__zaiqi'] = '每局限七次，摸牌阶段，你可以改为亮出牌堆顶的X+1张牌，然后获得其中一种颜色的所有牌（X为本技能已发动的次数）。',
}

mini__zaiqi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(mini__zaiqi.name) and player.phase == Player.Draw and player:usedSkillTimes(mini__zaiqi.name, Player.HistoryGame) < 7
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cids = room:getNCards(player:usedSkillTimes(mini__zaiqi.name, Player.HistoryGame))
    room:moveCards{
      ids = cids,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = mini__zaiqi.name,
    }
    room:delay(2000)
    local cards, choices = {}, {}
    for _, id in ipairs(cids) do
      local card = Fk:getCardById(id)
      local cardType = card:getColorString()
      if not cards[cardType] then
        table.insert(choices, cardType)
      end
      cards[cardType] = cards[cardType] or {}
      table.insert(cards[cardType], id)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = mini__zaiqi.name,
      prompt = "#mini__zaiqi-ask",
    })
    room:obtainCard(player.id, cards[choice], true, fk.ReasonJustMove)
    room:addPlayerMark(player, "@mini__zaiqi")
    cids = table.filter(cids, function(id) return room:getCardArea(id) == Card.Processing end)
    room:moveCardTo(cids, Card.DiscardPile, nil, fk.ReasonJustMove)
    return true
  end,
})

return mini__zaiqi
