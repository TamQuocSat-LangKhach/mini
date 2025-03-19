local sixiao = fk.CreateSkill {
  name = "sixiao"
}

Fk:loadTranslationTable{
  ['sixiao_other&'] = '死孝',
  ['#sixiao-active'] = '你可观看对你发动“死孝”的角色的手牌，使用其中一张牌！',
  ['#sixiao-from'] = '你要发动谁的“死孝”?',
  ['sixiao'] = '死孝',
  [':sixiao_other&'] = '每回合限一次，当你需要使用除【无懈可击】以外的牌时，你可以观看拥有“死孝”的角色的手牌，并可以选择其中一张牌使用之，然后令其摸一张牌。',
}

sixiao:addEffect('active', {
  name = "sixiao_other&",
  mute = true,
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  prompt = "#sixiao-active",
  can_use = function(self, player)
    if player:getMark("sixiao_invoked-turn") == 0 then
      return table.find(Fk:currentRoom().alive_players, function (p)
        return p:getMark("sixiao_to") == player.id and not p:isKongcheng()
      end)
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:setPlayerMark(player, "sixiao_invoked-turn", 1)
    local tos = table.filter(room.alive_players, function (p)
      return p:getMark("sixiao_to") == player.id and not p:isKongcheng()
    end)
    if #tos == 0 then return end
    local to = tos[1]
    if #tos > 1 then
      to = room:getPlayerById(
        room:askToChoosePlayers(player, {
          targets = tos,
          min_num = 1,
          max_num = 1,
          prompt = "#sixiao-from",
          skill_name = sixiao.name,
          cancelable = false,
        })[1]
      )
    end
    to:broadcastSkillInvoke("sixiao")
    room:notifySkillInvoked(to, "sixiao")
    room:doIndicate(player.id, {to.id})
    local cards = to:getCardIds("h")
    local use = room:askToUseRealCard(player, {
      pattern = cards,
      skill_name = sixiao.name,
      expand_pile = cards,
      bypass_times = false,
      extra_data = {
        extraUse = false
      }
    })
    if use and not to.dead then
      to:drawCards(1, sixiao.name)
    end
  end,
})

return sixiao
