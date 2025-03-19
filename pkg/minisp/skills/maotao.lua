local maotao = fk.CreateSkill {
  name = "maotao"
}

Fk:loadTranslationTable{
  ['maotao'] = '酕醄',
  ['@liuling_drunk'] = '醉',
  ['#maotao-ask'] = '酕醄：你可弃1枚“醉”标记，随机改变%dest使用的%arg的目标',
  [':maotao'] = '当其他角色使用牌时，若目标数为1且没有处于濒死状态的角色，你可弃1枚“醉”，若此牌有其他合法目标，令此牌改为随机指定一个合法目标（不受距离限制），否则你从牌堆中获得一张锦囊牌。',
  ['$maotao1'] = '痛饮酕醄，醉生梦死！',
  ['$maotao2'] = '杜康既为酒圣，吾定为醉侯！'
}

maotao:addEffect(fk.AfterCardTargetDeclared, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(maotao.name) and player:getMark("@liuling_drunk") > 0 and target ~= player
      and #U.getActualUseTargets(player.room, data, event) == 1
      and table.every(player.room.alive_players, function(p) return not p.dying end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = maotao.name,
      prompt = "#maotao-ask::"..data.from..":".. data.card:toLogString()
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, "@liuling_drunk")
    local targetsID = {}
    for _, p in ipairs(room.alive_players) do
      if not table.contains(TargetGroup:getRealTargets(data.tos), p.id) and U.canTransferTarget(p, data, false) then
        table.insert(targetsID, p.id)
      end
    end
    if #targetsID > 0 then
      local toId = table.random(targetsID)
      room:doIndicate(player.id, {toId})
      local tos = {toId}
      data.tos = table.map(data.tos, function (t) -- 日月戟
        t[1] = toId
        return t
      end)
    else
      local cids = room:getCardsFromPileByRule(".|.|.|.|.|trick")
      if #cids > 0 then
        room:obtainCard(player, cids[1], false, fk.ReasonPrey)
      end
    end
  end,
})

return maotao
