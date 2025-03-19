local huhou = fk.CreateSkill {
  name = "mini_huhou"
}

Fk:loadTranslationTable{
  ['mini_huhou'] = '虎侯',
  ['#mini_huhou_delay'] = '虎侯',
  ['#mini_huhou_response'] = '虎侯',
  [':mini_huhou'] = '①与你【决斗】的角色不能打出【杀】。②你可将一张装备牌当【杀】使用或打出，此【杀】或以此法响应的【决斗】伤害+1。',
  ['$mini_huhou1'] = '汝等闻虎啸之威，可知吾虎侯之名？',
  ['$mini_huhou2'] = '虎侯许褚在此，马贼安敢放肆！'
}

huhou:addEffect('viewas', {
  name = "#mini_huhou",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = huhou.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function (self, player, use)
    use.additionalDamage = (use.additionalDamage or 0) + 1
  end
})

huhou:addEffect(fk.DamageCaused, {
  name = "#mini_huhou_delay",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.trueName == "duel" and (player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).data[1].extra_data or {}).miniHuhou
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,

  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, huhou.name) and data.responseToEvent and data.responseToEvent.card.trueName == "duel"
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local useEvent = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent and useEvent.data[1].card.trueName == "duel" then
      useEvent.data[1].extra_data = useEvent.data[1].extra_data or {}
      useEvent.data[1].extra_data.miniHuhou = true
    end
  end,
})

huhou:addEffect({fk.TargetSpecified, fk.TargetConfirmed}, {
  name = "#mini_huhou_response",
  anim_type = "offensive",
  mute = true,
  main_skill = huhou.name,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huhou) and target == player and data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, huhou.name, "offensive")
    player:broadcastSkillInvoke(huhou.name)
    data.fixedResponseTimes = data.fixedResponseTimes or {}
    data.fixedResponseTimes["slash"] = 0
    data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
    table.insert(data.fixedAddTimesResponsors, (event == fk.TargetSpecified and data.to or data.from))
  end,
})

return huhou
