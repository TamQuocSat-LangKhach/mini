local miniWangzuo = fk.CreateSkill {
  name = "mini_wangzuo"
}

Fk:loadTranslationTable{
  ["mini_wangzuo"] = "王佐",
  [":mini_wangzuo"] = "每回合限一次，你可跳过摸牌阶段、出牌阶段或弃牌阶段，然后令一名其他角色执行一个对应的额外阶段。" ..
  "<br><font color=><small>不要报告和此技能有关的，如与阶段、回合有关的bug。</small></font>",

  ["#mini_wangzuo-ask"] = "你可以发动〖王佐〗，跳过 %arg，选择一名其他角色，令其执行 %arg",

  ["$mini_wangzuo1"] = "扶汉忠节守，佐王定策成。",
  ["$mini_wangzuo2"] = "平乱锄奸，以匡社稷。",
}

local U = require "packages/utility/utility"

miniWangzuo:addEffect(fk.EventPhaseChanging, {
  can_trigger = function (self, event, target, player, data)
    return
      player == target and
      player:hasSkill(miniWangzuo.name) and
      not data.skipped and
      data.phase > Player.Judge and
      data.phase < Player.Finish and
      player:usedSkillTimes(miniWangzuo.name) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local to = player.room:askToChoosePlayers(
      player,
      {
        targets = player.room:getOtherPlayers(player, false),
        min_num = 1,
        max_num = 1,
        prompt = "#mini_wangzuo-ask:::" .. U.ConvertPhse(data.phase),
        skill_name = miniWangzuo.name,
      }
    )
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    data.skipped = true
    event:getCostData(self):gainAnExtraPhase(data.phase)
  end,
})

return miniWangzuo
