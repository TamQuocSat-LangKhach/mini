local miniexFenli = fk.CreateSkill {
  name = "miniex__fenli"
}

Fk:loadTranslationTable{
  ["miniex__fenli"] = "焚离",
  [":miniex__fenli"] = "出牌阶段限一次，你可以消耗2点“谋略”值，弃置至多两名座次相邻角色各一张牌，若这些牌颜色相同，你可以再消耗2点“谋略”值，对这些角色依次造成1点火焰伤害。",

  ["#miniex__fenli"] = "焚离：消耗2点“谋略”值，弃置至多两名座次相邻角色各一张牌",
  ["#miniex__fenli-damage"] = "焚离：可以消耗2点“谋略”值，对其各造成1点火焰伤害",

  ["$miniex__fenli1"] = "东风催火，焚尽敌舟。",
  ["$miniex__fenli2"] = "江火若白日，百里腾烟云。",
}

local miniUtil = require "packages/mini/mini_util"

miniexFenli:addEffect("active", {
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  prompt = "#miniex__fenli",
  can_use = function(self, player)
    return player:usedSkillTimes(miniexFenli.name, Player.HistoryPhase) == 0 and player:getMark("@mini_moulue") > 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    if to_select:isNude() then return false end
    if #selected == 0 then
      return true
    else
      return to_select:getNextAlive() == selected[1] or selected[1]:getNextAlive() == to_select
    end
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniexFenli.name
    local player = effect.from
    miniUtil.handleMoulue(room, player, -2)
    local tos = effect.tos
    room:sortByAction(tos)

    local colors = {}
    for _, to in ipairs(tos) do
      if not to:isNude() then
        local cid = room:askToChooseCard(
          player,
          {
            target = to,
            flag = "he",
            skill_name = skillName,
          }
        )
        table.insertIfNeed(colors, Fk:getCardById(cid).color)
        room:throwCard(cid, skillName, to, player)
      end
    end
    if
      player:getMark("@mini_moulue") > 1 and
      #colors == 1 and
      room:askToSkillInvoke(
        player,
        {
          skill_name = skillName,
          prompt = "#miniex__fenli-damage",
        }
      )
    then
      miniUtil.handleMoulue(room, player, -2)
      for _, to in ipairs(tos) do
        if not to.dead then
          room:doIndicate(player.id, {to.id})
          room:damage{
            from = player,
            to = to,
            damage = 1,
            skillName = skillName,
            damageType = fk.FireDamage,
          }
        end
      end
    end
  end,
})

return miniexFenli
