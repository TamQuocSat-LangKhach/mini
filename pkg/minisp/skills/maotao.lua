local maotao = fk.CreateSkill {
  name = "maotao"
}

Fk:loadTranslationTable{
  ["maotao"] = "酕醄",
  [":maotao"] = "当其他角色使用基本牌或普通锦囊牌指定唯一目标时，若没有处于濒死状态的角色，你可以移去1枚“醉”，" ..
  "令此牌改为随机指定一个合法目标（无距离限制），若未改变目标则你从牌堆中获得一张锦囊牌（每回合限一张）。",

  ["#maotao-ask"] = "酕醄：你可弃1枚“醉”标记，随机改变%dest使用的%arg的目标",

  ["$maotao1"] = "痛饮酕醄，醉生梦死！",
  ["$maotao2"] = "杜康既为酒圣，吾定为醉侯！"
}

maotao:addEffect(fk.TargetSpecifying, {
  can_trigger = function(self, event, target, player, data)
    return
      target ~= player and
      player:hasSkill(maotao.name) and
      player:getMark("@liuling_drunk") > 0 and
      data:isOnlyTarget(data.to) and
      table.every(player.room.alive_players, function(p) return not p.dying end)
  end,
  on_cost = function(self, event, target, player, data)
    return
      player.room:askToSkillInvoke(
        player,
        {
          skill_name = maotao.name,
          prompt = "#maotao-ask::" .. data.from.id .. ":" .. data.card:toLogString(),
        }
      )
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@liuling_drunk")
    local targets = data:getExtraTargets({ bypass_distances = true })
    if #targets > 0 then
      table.insert(targets, data.to)
      local to = table.random(targets)
      if to ~= data.to then
        room:doIndicate(player, { to })
        data:cancelTarget(data.to)
        data:addTarget(to)
        return true
      end
    end

    if player:getMark("maotao_obtain-turn") > 0 then
      return false
    end

    local cids = room:getCardsFromPileByRule(".|.|.|.|.|trick")
    if #cids > 0 then
      room:addPlayerMark(player, "maotao_obtain-turn")
      room:obtainCard(player, cids[1], false, fk.ReasonPrey, player, maotao.name)
    end
  end,
})

return maotao
