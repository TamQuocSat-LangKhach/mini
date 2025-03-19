local mini_beijia = fk.CreateSkill {
  name = "mini_beijia"
}

Fk:loadTranslationTable{
  ['mini_beijia'] = '悲笳',
  ['@mini_beijia'] = '悲笳',
  ['#mini_beijia-level'] = '悲笳（平）：你可将一张点数大于%arg的牌当任意普通锦囊牌使用',
  ['#mini_beijia-oblique'] = '悲笳（仄）：你可将一张点数小于%arg的牌当任意基本牌使用',
  [':mini_beijia'] = '<a href=>韵律技</a>，每回合限一次，平：你可以将一张点数大于X的牌当任意普通锦囊牌使用；仄：你可以将一张点数小于X的牌当任意基本牌使用。<br>转韵：出牌阶段，使用一张点数等于X的牌（X为你使用的上一张牌的点数）。',
  ['$mini_beijia1'] = '干戈日寻兮道路危，民卒流亡兮共哀悲。',
  ['$mini_beijia2'] = '烟尘蔽野兮胡虏盛，志意乖兮节义亏。',
}

mini_beijia:addEffect('viewas', {
  anim_type = "control",
  card_num = 1,
  pattern = ".",
  prompt = function(self, player)
    local number = player:getMark("@mini_beijia")
    if player:getSwitchSkillState(mini_beijia.name, false) == fk.SwitchYang then
      return "#mini_beijia-level:::" .. number
    else
      return "#mini_beijia-oblique:::" .. number
    end
  end,
  interaction = function(player)
    local all_names = U.getAllCardNames(player:getSwitchSkillState(mini_beijia.name, false) == fk.SwitchYang and "t" or "b")
    local names = U.getViewAsCardNames(player, mini_beijia.name, all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names, default_choice = "AskForCardsChosen" }
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(mini_beijia.name) == 0 and player:getMark("@mini_beijia") ~= 0
  end,
  enabled_at_response = function (skill, player, response)
    if player:usedSkillTimes(mini_beijia.name) == 0 and player:getMark("@mini_beijia") ~= 0 and not response then
      if player:getSwitchSkillState(mini_beijia.name, false) == fk.SwitchYang then
        return Exppattern:Parse(Fk.currentResponsePattern):matchExp(".|.|.|.|.|trick|.")
      else
        return Exppattern:Parse(Fk.currentResponsePattern):matchExp(".|.|.|.|.|basic|.")
      end
    end
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and Fk.all_card_types[skill.interaction.data] ~= nil then
      local number = player:getMark("@mini_beijia")
      if player:getSwitchSkillState(mini_beijia.name, false) == fk.SwitchYang then
        return Fk:getCardById(to_select).number > number
      else
        return Fk:getCardById(to_select).number < number
      end
    end
  end,
  view_as = function (skill, player, cards)
    if #cards ~= 1 or Fk.all_card_types[skill.interaction.data] == nil then return end
    local c = Fk:cloneCard(skill.interaction.data)
    c.skillName = mini_beijia.name
    c:addSubcard(cards[1])
    return c
  end,
  on_acquire = function (skill, player, is_start)
    local room = player.room
    room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
      local use = e.data[1]
      if use.from == player.id then
        room:setPlayerMark(player, "@mini_beijia", math.max(use.card.number, 0))
        return true
      end
    end, 1)
  end,
  on_lose = function (skill, player, is_death)
    player.room:setPlayerMark(player, "@mini_beijia", 0)
  end,
})

mini_beijia:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mini_beijia.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local last_num = player:getMark("@mini_beijia")
    if player.phase == Player.Play and last_num == data.card.number then
      changeRhyme(room, player, mini_beijia.name, Player.HistoryTurn)
    end
    room:setPlayerMark(player, "@mini_beijia", math.max(data.card.number, 0))
  end,
})

return mini_beijia
