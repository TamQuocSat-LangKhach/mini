local miniExYajiao = fk.CreateSkill {
  name = "mini_ex__yajiao"
}

Fk:loadTranslationTable{
  ["mini_ex__yajiao"] = "涯角",
  [":mini_ex__yajiao"] = "当你于回合外使用或打出手牌时，你可摸一张牌。",
}

local miniExYajiaoSpec = {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniExYajiao.name) and
      player.phase == Player.NotActive and
      data:isUsingHandcard(player)
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("yajiao")
    player:drawCards(1, miniExYajiao.name)
  end,
}

miniExYajiao:addEffect(fk.CardUsing, miniExYajiaoSpec)

miniExYajiao:addEffect(fk.CardResponding, miniExYajiaoSpec)

return miniExYajiao
