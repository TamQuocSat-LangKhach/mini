local miaoxi = fk.CreateSkill {
  name = "miaoxi"
}

Fk:loadTranslationTable{
  ['miaoxi'] = '妙析',
  ['#miaoxi'] = '妙析：请选择一张手牌并指定一名其他角色，与其共同展示一张手牌',
  [':miaoxi'] = '出牌阶段限一次，你可以选择一名其他角色，与其同时展示一张手牌，若这些牌：颜色相同，你获得其的展示牌；类别相同，其失去1点体力；点数相同，〖妙析〗视为未发动且此项本回合失效。',
  ['$miaoxi1'] = '物各自造而无所待焉，此天地之正也。',
  ['$miaoxi2'] = '天性所受，各有本分，不可逃，亦不可加。',
}

miaoxi:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#miaoxi",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player.player_cards[Player.Hand], to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and player.id ~= to_select and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
      and #selected_cards == 1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(miaoxi.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local toCards = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = miaoxi.name,
      cancelable = false
    })
    player:showCards(effect.cards)
    to:showCards(toCards)
    local myCard, toCard = Fk:getCardById(effect.cards[1]), Fk:getCardById(toCards[1])
    if myCard.color == toCard.color then
      room:obtainCard(player, toCard, true, fk.ReasonPrey, player.id, miaoxi.name)
    end
    if myCard.type == toCard.type and not to.dead then
      room:loseHp(to, 1, miaoxi.name)
    end
    if myCard.number == toCard.number and player:getMark("miaoxi-turn") == 0 then
      room:setPlayerMark(player, "miaoxi-turn", 1)
      player:setSkillUseHistory(miaoxi.name, 0, Player.HistoryPhase)
    end
  end,
})

return miaoxi
