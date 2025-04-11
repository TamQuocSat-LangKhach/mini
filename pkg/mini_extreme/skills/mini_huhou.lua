local miniHuhou = fk.CreateSkill {
  name = "mini_huhou"
}

Fk:loadTranslationTable{
  ["mini_huhou"] = "虎侯",
  [":mini_huhou"] = "与你进行【决斗】的角色不能打出【杀】；你可将一张装备牌当【杀】使用或打出，且以此法使用的【杀】对目标角色造成伤害时，" ..
  "若伤害来源为你，则此伤害+1；当【决斗】造成伤害时，若你为伤害来源，则此伤害+X（X为你发动本技能打出【杀】响应过此【决斗】的次数）",

  ["$mini_huhou1"] = "汝等闻虎啸之威，可知吾虎侯之名？",
  ["$mini_huhou2"] = "虎侯许褚在此，马贼安敢放肆！"
}

miniHuhou:addEffect("viewas", {
  name = "#mini_huhou",
  anim_type = "offensive",
  pattern = "slash",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = miniHuhou.name
    c:addSubcard(cards[1])
    return c
  end,
})

miniHuhou:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    if not (target == player and data.card and player:hasSkill(miniHuhou.name)) then
      return false
    end

    if data.card.trueName == "duel" then
      local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return useEvent and (useEvent.data.extra_data or {}).miniHuhou
    end

    return data.card.trueName == "slash" and table.contains(data.card.skillNames, miniHuhou.name) and data.by_user
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if data.card.trueName == "slash" then
      data:changeDamage(1)
    else
      local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if useEvent then
        data:changeDamage((useEvent.data.extra_data or {}).miniHuhou)
      end
    end
  end,
})

miniHuhou:addEffect(fk.CardResponding, {
  can_refresh = function (self, event, target, player, data)
    return
      target == player and
      table.contains(data.card.skillNames, miniHuhou.name) and
      data.responseToEvent and
      data.responseToEvent.card.trueName == "duel"
  end,
  on_refresh = function (self, event, target, player, data)
    local useEvent = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent and useEvent.data.card.trueName == "duel" then
      useEvent.data.extra_data = useEvent.data.extra_data or {}
      useEvent.data.extra_data.miniHuhou = (useEvent.data.extra_data.miniHuhou or 0) + 1
    end
  end,
})

miniHuhou:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "duel" and player:hasSkill(miniHuhou.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = 0
    data.fixedAddTimesResponsors = { data.to }
  end,
})

miniHuhou:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "duel" and player:hasSkill(miniHuhou.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fixedResponseTimes = 0
    data.fixedAddTimesResponsors = { data.from }
  end,
})

return miniHuhou
