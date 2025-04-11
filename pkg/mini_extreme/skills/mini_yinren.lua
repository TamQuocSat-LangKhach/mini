local miniYinren = fk.CreateSkill {
  name = "mini_yinren"
}

Fk:loadTranslationTable{
  ["mini_yinren"] = "隐忍",
  [":mini_yinren"] = "回合开始时，你可跳过出牌阶段和弃牌阶段，然后获得以下技能中你没有的第一个技能：〖奸雄〗、〖行殇〗、〖明鉴〗。",

  ["$mini_yinren1"] = "小隐于野，大隐于朝。",
  ["$mini_yinren2"] = "进退有度，举重若轻。",
}

miniYinren:addEffect(fk.TurnStart, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(miniYinren.name) and
      player:canSkip(Player.Play) and
      player:canSkip(Player.Discard)
  end,
  on_use = function(self, event, target, player, data)
    player:skip(Player.Play)
    player:skip(Player.Discard)
    for _, s in ipairs { "ex__jianxiong", "xingshang", "mingjian" } do
      if not player:hasSkill(s, true) then
        player.room:handleAddLoseSkills(player, s, nil)
        break
      end
    end
  end,
})

return miniYinren
