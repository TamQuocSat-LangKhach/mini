local miniBeijia = fk.CreateSkill {
  name = "mini_beijia",
  tags = { Skill.Rhyme },
}

Fk:loadTranslationTable{
  ["mini_beijia"] = "悲笳",
  [":mini_beijia"] = "<a href='rhyme_skill'>韵律技</a>，每回合限一次，平：你可以将一张点数大于X的牌当任意普通锦囊牌使用；" ..
  "仄：你可以将一张点数小于X的牌当任意基本牌使用。<br>转韵：出牌阶段，使用一张点数等于X的牌（X为你使用的上一张牌的点数）。",

  ["@mini_beijia"] = "悲笳",
  ["#mini_beijia-level"] = "悲笳（平）：你可将一张点数大于%arg的牌当任意普通锦囊牌使用",
  ["#mini_beijia-oblique"] = "悲笳（仄）：你可将一张点数小于%arg的牌当任意基本牌使用",

  ["$mini_beijia1"] = "干戈日寻兮道路危，民卒流亡兮共哀悲。",
  ["$mini_beijia2"] = "烟尘蔽野兮胡虏盛，志意乖兮节义亏。",
}

local U = require "packages/utility/utility"
local miniUtil = require "packages/mini/mini_util"

miniBeijia:addEffect("viewas", {
  anim_type = "control",
  card_num = 1,
  pattern = ".",
  prompt = function(self, player)
    local number = player:getMark("@mini_beijia")
    if player:getSwitchSkillState(miniBeijia.name, false) == fk.SwitchYang then
      return "#mini_beijia-level:::" .. number
    else
      return "#mini_beijia-oblique:::" .. number
    end
  end,
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames(player:getSwitchSkillState(miniBeijia.name, false) == fk.SwitchYang and "t" or "b")
    local names = player:getViewAsCardNames(miniBeijia.name, all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names, default_choice = "AskForCardsChosen" }
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(miniBeijia.name) == 0 and player:getMark("@mini_beijia") ~= 0
  end,
  enabled_at_response = function (skill, player, response)
    if player:usedSkillTimes(miniBeijia.name) == 0 and player:getMark("@mini_beijia") ~= 0 and not response then
      if player:getSwitchSkillState(miniBeijia.name, false) == fk.SwitchYang then
        return Exppattern:Parse(Fk.currentResponsePattern):matchExp(".|.|.|.|.|trick|.")
      else
        return Exppattern:Parse(Fk.currentResponsePattern):matchExp(".|.|.|.|.|basic|.")
      end
    end
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and Fk.all_card_types[self.interaction.data] ~= nil then
      local number = player:getMark("@mini_beijia")
      if player:getSwitchSkillState(miniBeijia.name, false) == fk.SwitchYang then
        return Fk:getCardById(to_select).number > number
      else
        return Fk:getCardById(to_select).number < number
      end
    end
  end,
  view_as = function (self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = miniBeijia.name
    c:addSubcard(cards[1])
    return c
  end,
})

miniBeijia:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(miniBeijia.name, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local last_num = player:getMark("@mini_beijia")
    if player.phase == Player.Play and last_num == data.card.number then
      miniUtil.changeRhyme(room, player, miniBeijia.name, Player.HistoryTurn)
    end
    room:setPlayerMark(player, "@mini_beijia", math.max(data.card.number, 0))
  end,
})

miniBeijia:addAcquireEffect(function(self, player)
  local room = player.room
  room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
    local use = e.data
    if use.from == player then
      room:setPlayerMark(player, "@mini_beijia", math.max(use.card.number, 0))
      return true
    end
  end, 1)
end)

miniBeijia:addLoseEffect(function(self, player)
  player.room:setPlayerMark(player, "@mini_beijia", 0)
end)

return miniBeijia
