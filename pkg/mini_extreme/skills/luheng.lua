local luheng = fk.CreateSkill {
  name = "mini__luheng"
}

Fk:loadTranslationTable{
  ['mini__luheng'] = '戮衡',
  ['#mini__luheng-choose'] = '戮衡：选择参与过“逐鹿”中手牌数最多的其他角色，视为对其使用一张【杀】',
  [':mini__luheng'] = '结束阶段，若你本回合发动过“纵阋”，你可选择一名本回合参与过“逐鹿”中手牌数最多的其他角色，视为对其使用一张【杀】。',
  ['$mini__luheng1'] = '放肆！汝可知欺君之罪？',
  ['$mini__luheng2'] = '卿欲试朕之龙威乎？'
}

luheng:addEffect(fk.EventPhaseStart, {
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(luheng.name) and player.phase == Player.Finish
      and player:usedSkillTimes(zongxi.name, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player)
    local room = player.room
    local targets = {}
    room.logic:getEventsOfScope(U.JointPindianEvent, 1, function(e)
      local pd = e.data[1]
      table.insertIfNeed(targets, pd.from)
      table.insertTableIfNeed(targets, pd.tos)
    end, Player.HistoryTurn)
    targets = table.filter(targets, function(p) return not p.dead and p ~= player end)
    if #targets == 0 then return false end
    local maxNum = 0
    for _, p in ipairs(targets) do
      maxNum = math.max(maxNum, p:getHandcardNum())
    end
    targets = table.filter(targets, function(p) return p:getHandcardNum() == maxNum end)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      prompt = "#mini__luheng-choose",
      skill_name = luheng.name,
      cancelable = true,
      targets = targets
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player)
    local cost_data = event:getCostData(self)
    player.room:useVirtualCard("slash", nil, player, player.room:getPlayerById(cost_data.tos[1]), luheng.name, true)
  end,
})

return luheng
