local danlao = fk.CreateSkill {
  name = "mini__danlao"
}

Fk:loadTranslationTable{
  ['mini__danlao'] = '啖酪',
  ['#mini__danlao-active'] = '啖酪：你可以摸%arg张牌',
  ['#mini__danlao-give'] = '啖酪：将这些牌分配给任意名角色，然后未以此法获得牌的角色可以视为对你使用【杀】',
  ['mini__danlao-slash'] = '视为对%dest使用【杀】',
  [':mini__danlao'] = '出牌阶段限一次，你可以摸X张牌，然后将这些牌分配给任意名角色，然后未以此法获得牌的角色可以视为对你使用【杀】。（X为存活角色数）',
}

danlao:addEffect('active', {
  prompt = function(self, player) return "#mini__danlao-active:::" .. #Fk:currentRoom().alive_players end,
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  can_use = function (skill, player)
    return player:usedSkillTimes(danlao.name, Player.HistoryPhase) == 0
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("danlao")
    local cards = player:drawCards(#room.alive_players, danlao.name)
    if player.dead then return end
    local handcards = player:getCardIds("h")
    cards = table.filter(cards, function(id) return table.contains(handcards, id) end)
    local ret = room:askToYiji(player, {
      targets = nil,
      skill_name = danlao.name,
      prompt = "#mini__danlao-give",
      cards = cards
    })
    local card = Fk:cloneCard("slash")
    card.skillName = danlao.name
    for _, p in ipairs(room:getAlivePlayers()) do
      if not (player.dead or p.dead or #ret[p.id] > 0) and p:canUseTo(card, player, { bypass_times = true, bypass_distances = true }) then
        if room:askToChoice(p, {
          choices = {"mini__danlao-slash::" .. player.id, "Cancel"},
          skill_name = danlao.name,
        }):startsWith("mi") then
          room:useVirtualCard("slash", nil, p, player, danlao.name, true)
        end
      end
    end
  end,
})

return danlao
