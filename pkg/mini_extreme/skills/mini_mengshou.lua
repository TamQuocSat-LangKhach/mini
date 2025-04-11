local miniMengshou = fk.CreateSkill {
  name = "mini_mengshou"
}

Fk:loadTranslationTable{
  ["mini_mengshou"] = "盟首",
  [":mini_mengshou"] = "每轮限一次，当你受到其他角色造成的伤害时，若其本轮造成的伤害值不大于你，你可防止此伤害。",

  ["#mini_mengshou-ask"] = "盟首：你可防止 %dest 造成的 %arg 点 %arg2 伤害",

  ["$mini_mengshou1"] = "董贼弑君篡权，为天下所不容！",
  ["$mini_mengshou2"] = "今歃血为盟，誓诛此逆贼！"
}

miniMengshou:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if
      not (
        target == player and
        player:hasSkill(miniMengshou.name) and
        data.from and
        data.from ~= player and
        player:usedSkillTimes(miniMengshou.name, Player.HistoryRound) == 0
      )
    then
      return false
    end

    local x, y = 0, 0
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data
      if damage.from == player then
        x = x + 1
      elseif damage.from == data.from then
        y = y + 1
      end
      return false
    end, Player.HistoryRound)
    return y <= x
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(
      player,
      {
        skill_name = miniMengshou.name,
        prompt = "#mini_mengshou-ask::" .. data.from.id .. ":" .. data.damage .. ":" .. Fk:getDamageNatureName(data.damageType),
      }
    )
  end,
  on_use = function (self, event, target, player, data)
    player.room:sendLog{
      type = "#BreastplateSkill",
      from = player.id,
      arg = miniMengshou.name,
      arg2 = data.damage,
      arg3 = Fk:getDamageNatureName(data.damageType),
    }
    data:preventDamage()
  end
})

return miniMengshou
