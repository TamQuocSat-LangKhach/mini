local lianhuas = fk.CreateSkill {
  name = "lianhuas",
  dynamic_desc = function (self, player, lang)
    return "lianhuas"..player:getMark(self.name)
  end,
}

Fk:loadTranslationTable{
  ["lianhuas"] = "莲华",
  [":lianhuas"] = "当你成为【杀】的目标时，你摸一张牌。<br>二阶：当你成为【杀】的目标时，你摸一张牌，然后你判定，若为♠，取消之。<br>"..
  "三阶：当你成为【杀】的目标时，你摸一张牌，然后使用者需弃置一张牌，否则取消之。",

  [":lianhuas0"] = "当你成为【杀】的目标时，你摸一张牌。",
  [":lianhuas1"] = "当你成为【杀】的目标时，你摸一张牌，然后你判定，若为♠，取消之。",
  [":lianhuas2"] = "当你成为【杀】的目标时，你摸一张牌，然后使用者需弃置一张牌，否则取消之。",

  ["#lianhuas-discard"] = "莲华：你需弃置一张牌，否则 %src 取消此【杀】",

  ["$lianhuas1"] = "刀兵水火，速离身形。",
  ["$lianhuas2"] = "体有金光，覆映全身。",
}

lianhuas:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianhuas.name) and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, lianhuas.name)
    if player.dead or player:getMark(lianhuas.name) == 0 then return end
    if player:getMark(lianhuas.name) == 1 then
      local judge = {
        who = player,
        reason = lianhuas.name,
        pattern = ".|.|spade",
      }
      room:judge(judge)
      if judge:matchPattern() then
        data:cancelTarget(player)
      end
    elseif player:getMark(lianhuas.name) == 2 then
      if data.from.dead or data.from:isNude() or
        #room:askToDiscard(data.from, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = lianhuas.name,
          cancelable = true,
          prompt = "#lianhuas-discard:"..player.id,
        }) == 0 then
          data:cancelTarget(player)
      end
    end
  end,
})

return lianhuas
