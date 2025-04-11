local miniSangu = fk.CreateSkill {
  name = "mini_sangu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["mini_sangu"] = "三顾",
  [":mini_sangu"] = "锁定技，每当有三张牌指定你为目标后，你获得3点<a href='mini_moulue'>谋略值</a>，然后你观看牌堆顶的三张牌并将这些牌置于牌堆顶或牌堆底。",

  ["@mini_sangu"] = "三顾",

  ["$mini_sangu1"] = "大梦先觉，感三顾之诚，布天下三分。",
  ["$mini_sangu2"] = "卧龙初晓，铭鱼水之情，托死生之志。",
}

local miniUtil = require "packages/mini/mini_util"

miniSangu:addEffect(fk.TargetConfirmed, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniSangu.name) and
      player:getMark("@mini_sangu") > 0 and
      player:getMark("@mini_sangu") % 3 == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@mini_sangu", 0)
    if player:getMark("@mini_moulue") < 5 then
      miniUtil.handleMoulue(room, player, 3)
    end
    room:askToGuanxing(player, { cards = room:getNCards(3), skill_name = miniSangu.name })
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(miniSangu.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini_sangu")
  end
})

return miniSangu
