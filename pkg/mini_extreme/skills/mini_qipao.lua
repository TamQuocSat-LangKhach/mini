local miniQipao = fk.CreateSkill {
  name = "mini_qipao"
}

Fk:loadTranslationTable{
  ["mini_qipao"] = "弃袍",
  [":mini_qipao"] = "当你使用【杀】指定目标后，你可令其选择一项：1. 弃置装备区内的所有牌（至少一张）；2. 此回合非锁定技失效且不能响应此【杀】。",

  ["#mini_qipao-ask"] = "你可对 %dest 发动“弃袍”",
  ["mini_qipao_invalid"] = "此回合非锁定技失效且不能响应此【杀】",
  ["mini_qipao_discard"] = "弃置装备区内的所有牌",

  ["$mini_qipao1"] = "哼，凭汝瘦马断矛，安可伤我？",
  ["$mini_qipao2"] = "汝与其行口舌之快，不若寻趁手之兵！"
}

miniQipao:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniQipao.name) and
      data.card.trueName == "slash" and
      data.to:isAlive()
  end,
  on_cost = function(self, event, target, player, data)
    return
      player.room:askToSkillInvoke(
        player,
        {
          skill_name = miniQipao.name,
          prompt = "#mini_qipao-ask::" .. data.to.id,
        }
      )
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local choices = { "mini_qipao_invalid" }
    if #to:getCardIds("e") > 0 then table.insert(choices, 1, "mini_qipao_discard") end
    local choice = room:askToChoice(
      to,
      {
        choices = choices,
        skill_name = miniQipao.name,
      }
    )
    if choice == "mini_qipao_discard" then
      to:throwAllCards("e")
    else
      data.disresponsive = true
      room:setPlayerMark(to, MarkEnum.UncompulsoryInvalidity .. "-turn", 1)
    end
  end,
})

return miniQipao
