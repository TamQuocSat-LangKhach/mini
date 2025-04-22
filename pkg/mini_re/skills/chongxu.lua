local chongxu = fk.CreateSkill {
  name = "mini__chongxu",
}

Fk:loadTranslationTable {
  ["mini__chongxu"] = "冲虚",
  [":mini__chongxu"] = "出牌阶段限一次，你获得5点积分，消耗积分执行效果：升级〖妙剑〗（3分）；升级〖莲华〗（3分）；摸一张牌（2分）。",

  ["#mini__chongxu"] = "冲虚：获得5点积分，消耗积分执行效果",
  ["#mini__chongxu-choice"] = "冲虚：消耗积分执行效果（还剩%arg分）",
  ["update_miaojian"] = "升级〖妙剑〗（3分）",
  ["update_lianhuas"] = "升级〖莲华〗（3分）",
  ["mini__chongxu_draw"] = "摸一张牌（2分）",

  ["$mini__chongxu1"] = "阳炁冲三关，斩尸除阴魔。",
  ["$mini__chongxu2"] = "蒲团清静坐，神归了道真。",
}

chongxu:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#mini__chongxu",
  can_use = function(self, player)
    return player:usedSkillTimes(chongxu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local n = 5
    local choice = "mini__chongxu_draw"
    local all_choices = {"update_miaojian", "update_lianhuas", "mini__chongxu_draw", "Cancel"}
    while n > 1 and choice ~= "Cancel" and not player.dead do
      local choices = table.simpleClone(all_choices)
      if not (n > 2 and player:hasSkill("lianhuas", true) and player:getMark("lianhuas") < 2) then
        table.remove(choices, 2)
      end
      if not (n > 2 and player:hasSkill("miaojian", true) and player:getMark("miaojian") < 2) then
        table.remove(choices, 1)
      end
      choice = room:askToChoice(player, {
        choices = choices,
        skill_name = chongxu.name,
        prompt = "#mini__chongxu-choice:::"..n,
        all_choices = all_choices,
      })
      if choice == "mini__chongxu_draw" then
        n = n - 2
        player:drawCards(1, chongxu.name)
      elseif choice == "update_miaojian" then
        n = n - 3
        room:addPlayerMark(player, "miaojian", 1)
      elseif choice == "update_lianhuas" then
        n = n - 3
        room:addPlayerMark(player, "lianhuas", 1)
      end
    end
  end,
})

return chongxu
