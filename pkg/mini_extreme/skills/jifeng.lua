local jifeng = fk.CreateSkill {
  name = "mini_jifeng"
}

Fk:loadTranslationTable{
  ['mini_jifeng'] = '祭风',
  [':mini_jifeng'] = '出牌阶段限一次，你可弃置一张手牌，然后从牌堆中随机获得一张锦囊牌。',
}

jifeng:addEffect('active', {
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(jifeng.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  card_num = 1,
  card_filter = function(self, player, to_select)
    return not player:prohibitDiscard(Fk:getCardById(to_select)) and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, jifeng.name, from, from)
    if from:isAlive() then
      local card = room:getCardsFromPileByRule(".|.|.|.|.|trick")
      if #card > 0 then
        room:obtainCard(from, card[1], true, fk.ReasonPrey)
      end
    end
  end,
})

return jifeng
