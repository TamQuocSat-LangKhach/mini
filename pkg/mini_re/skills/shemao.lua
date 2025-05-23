
local shemao = fk.CreateSkill {
  name = "mini__shemao",
}

Fk:loadTranslationTable{
  ["mini__shemao"] = "蛇矛",
  [":mini__shemao"] = "出牌阶段限一次，你可以将两张手牌当一张无距离限制的【杀】使用。",

  ["#mini__shemao"] = "蛇矛：将两张手牌当无距离限制的【杀】使用",
}

shemao:addEffect("viewas", {
  mute = true,
  pattern = "slash",
  prompt = "#mini__shemao",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = shemao.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function (self, player, use)
    player.room:broadcastPlaySound("./packages/standard_cards/audio/card/spear")
    player.room:setEmotion(player, "./packages/standard_cards/image/anim/spear")
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(shemao.name, Player.HistoryPhase) == 0
  end,
})

shemao:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, shemao.name)
  end,
})

return shemao
