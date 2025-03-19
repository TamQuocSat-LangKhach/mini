local siyuan = fk.CreateSkill {
  name = "mini_siyuan"
}

Fk:loadTranslationTable{
  ['mini_siyuan'] = '思怨',
  ['#mini_siyuan-invoke'] = '你可以发动〖思怨〗，选择一名其他角色，令 %src 视为对其造成过1点伤害',
  [':mini_siyuan'] = '当你受到伤害后，你可以选择一名其他角色，令伤害来源视为对其造成过1点伤害。',
  ['$mini_siyuan1'] = '陛下既不怜我，何不赦我归去。',
  ['$mini_siyuan2'] = '后宫三千佳丽，无我一人又何妨',
}

siyuan:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(siyuan.name) and data.from
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#mini_siyuan-invoke:" .. data.from.id,
      skill_name = siyuan.name,
    })
    if #to > 0 then
      event:setCostData(skill, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(skill))
    room:damage{
      from = data.from,
      to = to,
      damage = 1,
      skillName = siyuan.name,
      isVirtualDMG = true,
    }
  end
})

return siyuan
