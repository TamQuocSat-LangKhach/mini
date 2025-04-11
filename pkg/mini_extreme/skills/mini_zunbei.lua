local miniZunbei = fk.CreateSkill {
  name = "mini_zunbei"
}

Fk:loadTranslationTable{
  ["mini_zunbei"] = "尊北",
  [":mini_zunbei"] = "出牌阶段限一次，你可与所有其他角色进行一次<a href='zhuluPindian'>逐鹿</a>，胜者，" .. 
  "视为使用一张【万箭齐发】。此牌结算结束后，你摸X张牌（X为受到此牌伤害的角色数）。",

  ["#mini_zunbei"] = "尊北：你可与所有其他角色逐鹿，胜者视为使用【万箭齐发】且你摸受到此牌伤害角色数的牌。",

  ["$mini_zunbei1"] = "今据四州之地，足以称雄。",
  ["$mini_zunbei2"] = "昔讨董卓，今肃河北，吾当为汉室首功。",
}

local U = require "packages/utility/utility"

miniZunbei:addEffect("active", {
  anim_type = "offensive",
  prompt = "#mini_zunbei",
  can_use = function(self, player)
    return
      player:usedSkillTimes(miniZunbei.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return player:canPindian(p) and player ~= p
      end)
  end,
  target_filter = Util.FalseFunc,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = miniZunbei.name
    local player = effect.from
    local targets = table.filter(room.alive_players, function(p)
      return player:canPindian(p) and player ~= p
    end)
    room:doIndicate(player, targets)
    local pd = U.startZhuLu(player, targets, skillName)
    local winner = pd.winner
    if winner and winner:isAlive() then
      local card = Fk:cloneCard("archery_attack")
      if not player:canUse(card, { bypass_times = true, bypass_distances = true }) then return end
      local tos = table.filter(room.alive_players, function(p)
        return winner:canUseTo(card, p, { bypass_times = true, bypass_distances = true })
      end)

      ---@type UseCardDataSpec
      local use = {
        from = winner,
        tos = tos,
        card = card,
        extraUse = true,
      }
      room:useCard(use)
      if use.damageDealt and player:isAlive() then
        local num = 0
        for _, id in ipairs(tos) do
          if use.damageDealt[id] then
            num = num + use.damageDealt[id]
          end
        end
        player:drawCards(num, skillName)
      end
    end
  end,
})

return miniZunbei
