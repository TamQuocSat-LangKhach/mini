local miaojian = fk.CreateSkill {
  name = "miaojian",
  dynamic_desc = function (self, player, lang)
    return "miaojian"..player:getMark(self.name)
  end,
}

Fk:loadTranslationTable{
  ["miaojian"] = "妙剑",
  [":miaojian"] = "出牌阶段限一次，你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用。<br>二阶：出牌阶段限一次，你可以将基本牌当刺【杀】、"..
  "非基本牌当【无中生有】使用。<br>三阶：出牌阶段限一次，你可以视为使用一张刺【杀】或【无中生有】。",

  [":miaojian0"] = "出牌阶段限一次，你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用。",
  [":miaojian1"] = "出牌阶段限一次，你可以将基本牌当刺【杀】、非基本牌当【无中生有】使用。",
  [":miaojian2"] = "三阶：出牌阶段限一次，你可以视为使用一张刺【杀】或【无中生有】。",

  ["#miaojian0"] = "妙剑：你可以将【杀】当刺【杀】、锦囊牌当【无中生有】使用",
  ["#miaojian1"] = "妙剑：你可以将基本牌当刺【杀】、非基本牌当【无中生有】使用",
  ["#miaojian2"] = "妙剑：你可以视为使用一张刺【杀】或【无中生有】",

  ["$miaojian1"] = "谨以三尺玄锋，代天行化，布令宣威。",
  ["$miaojian2"] = "布天罡，踏北斗，有秽皆除，无妖不斩。",
}

local U = require "packages/utility/utility"

miaojian:addEffect("viewas", {
  prompt = function(self, player)
    return "#miaojian"..player:getMark(miaojian.name)
  end,
  interaction = function(self, player)
    return U.CardNameBox {choices = {"stab__slash", "ex_nihilo"}}
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      if player:getMark(miaojian.name) == 0 then
        if self.interaction.data == "stab__slash" then
          return card.trueName == "slash"
        elseif self.interaction.data == "ex_nihilo" then
          return card.type == Card.TypeTrick
        end
      elseif player:getMark(miaojian.name) == 1 then
        if self.interaction.data == "stab__slash" then
          return card.type == Card.TypeBasic
        elseif self.interaction.data == "ex_nihilo" then
          return card.type ~= Card.TypeBasic
        end
      elseif player:getMark(miaojian.name) == 2 then
        return false
      end
    end
  end,
  view_as = function(self, player, cards)
    if not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    if player:getMark(miaojian.name) < 2 then
      if #cards ~= 1 then return end
      card:addSubcard(cards[1])
    end
    card.skillName = miaojian.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(miaojian.name, Player.HistoryPhase) == 0
  end,
})

return miaojian
