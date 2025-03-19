local mini__yihan = fk.CreateSkill {
  name = "mini__yihan"
}

Fk:loadTranslationTable{
  ['mini__yihan'] = '翊汉',
  ['#mini__yihan'] = '翊汉：展示一名其他角色的一张手牌，其需交给你，否则被你使用【杀】',
  ['#mini__yihan-ask'] = '翊汉：点“确定”：将%arg交给%dest；“取消”：被他使用【杀】',
  [':mini__yihan'] = '出牌阶段限一次，你可以展示一名其他角色的一张手牌，然后令其选择一项：1.将此牌交给你；2.令你视为对其使用一张无次数限制的【杀】。',
  ['$mini__yihan1'] = '大丈夫匡汉为任，岂耽于浮名。',
  ['$mini__yihan2'] = '助兄复汉，某义不容辞。',
}

mini__yihan:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,

  can_use = function(self, player)
    return player:usedSkillTimes(mini__yihan.name, Player.HistoryPhase) < 1
  end,

  card_filter = Util.FalseFunc,

  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,

  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local cid = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = mini__yihan.name
    })
    to:showCards({cid})
    local card = Fk:getCardById(cid)
    if room:askToSkillInvoke(to, {skill_name = mini__yihan.name, prompt = "#mini__yihan-ask::"..player.id..":"..card:toLogString()}) then
      room:obtainCard(player, cid, true, fk.ReasonGive, to.id, mini__yihan.name)
    else
      room:useVirtualCard("slash", nil, player, to, mini__yihan.name, true)
    end
  end,
})

return mini__yihan
