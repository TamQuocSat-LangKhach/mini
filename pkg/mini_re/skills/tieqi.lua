local tieqi = fk.CreateSkill {
  name = "mini__tieqi",
}

Fk:loadTranslationTable{
  ["mini__tieqi"] = "铁骑",
  [":mini__tieqi"] = "当你使用【杀】指定目标后，你可以进行判定，若结果为：红色，其不可响应此【杀】；黑色，你获得此判定牌。",
}

tieqi:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tieqi.name) and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = tieqi.name,
      pattern = ".|.|^nosuit",
    }
    room:judge(judge)
    if judge.card.color == Card.Red then
      data.disresponsive = true
    elseif judge.card.color == Card.Black and not player.dead and
      room:getCardArea(judge.card) == Card.DiscardPile then
      room:moveCardTo(judge.card, Card.PlayerHand, player, fk.ReasonJustMove, tieqi.name, nil, true, player)
    end
  end,
})

return tieqi
