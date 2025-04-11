local miniMiaoji = fk.CreateSkill {
  name = "mini_miaoji"
}

Fk:loadTranslationTable{
  ["mini_miaoji"] = "妙计",
  [":mini_miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；3.【无懈可击】或【无中生有】。",

  ["#mini_miaoji"] = "妙计：消耗%arg2点谋略值，视为使用【%arg】",

  ["$mini_miaoji1"] = "计能规于未肇，虑能防于未然。",
  ["$mini_miaoji2"] = "心静则神策生，虑远则计谋成。",
}

local U = require "packages/utility/utility"
local miniUtil = require "packages/mini/mini_util"

miniMiaoji:addEffect("viewas", {
  pattern = "dismantlement,nullification,ex_nihilo",
  prompt = function (self)
    if not self.interaction.data then
      return ""
    end

    local all_names = { ["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3 }
    return "#mini_miaoji:::" .. self.interaction.data .. ":" .. all_names[self.interaction.data]
  end,
  interaction = function(self, player)
    local names = {}
    if player:getMark("@mini_moulue") > 2 then
      names = { "dismantlement", "nullification", "ex_nihilo" }
    elseif player:getMark("@mini_moulue") > 0 then
      names = { "dismantlement" }
    end
    names = U.getViewAsCardNames(player, miniMiaoji.name, names)
    return U.CardNameBox { choices = names, all_choices = { "dismantlement", "nullification", "ex_nihilo" } }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = miniMiaoji.name
    return card
  end,
  before_use = function(self, player, use)
    local names = { ["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3 }
    miniUtil.handleMoulue(player.room, player, -names[use.card.trueName])
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(miniMiaoji.name) == 0
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(miniMiaoji.name) > 0 then return false end
    local names = {}
    if player:getMark("@mini_moulue") > 2 then
      names = { "dismantlement", "nullification", "ex_nihilo" }
    elseif player:getMark("@mini_moulue") > 0 then
      names = { "dismantlement" }
    end
    return #U.getViewAsCardNames(player, miniMiaoji.name, names) > 0
  end,
})

return miniMiaoji
