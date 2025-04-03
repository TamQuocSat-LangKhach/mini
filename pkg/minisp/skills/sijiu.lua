local sijiu = fk.CreateSkill {
  name = "sijiu"
}

Fk:loadTranslationTable{
  ["sijiu"] = "思旧",
  [":sijiu"] = "每轮结束时，若你本轮获得过其他角色的牌，你可以摸一张牌并观看一名其他角色的手牌。",

  ["#sijiu-choose"] = "思旧：观看一名其他角色的手牌",

  ["$sijiu1"] = "悼嵇生之永辞兮，顾日影而弹琴。",
  ["$sijiu2"] = "托运遇于领会兮，寄余命于寸阴。",
}

local U = require "packages/utility/utility"

sijiu:addEffect(fk.RoundEnd, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player)
      return
        player:hasSkill(sijiu.name) and
        #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from and move.from ~= move.to and move.to == player and move.toArea == Card.PlayerHand then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  return true
                end
              end
            end
          end
          return false
        end,
        Player.HistoryRound
      ) > 0
  end,
  on_use = function (self, event, target, player)
    ---@type string
    local skillName = sijiu.name
    local room = player.room
    player:drawCards(1, skillName)
    if not player:isAlive() then
      return false
    end

    local targets = table.filter(room:getOtherPlayers(player, false), function (p) return not p:isKongcheng() end)
    if #targets == 0 then return false end
    local tos = room:askToChoosePlayers(
      player,
      {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#sijiu-choose",
        skill_name = skillName,
        cancelable = false,
      }
    )
    if #tos > 0 then
      U.viewCards(player, tos[1]:getCardIds("h"), skillName, "$ViewCardsFrom:" .. tos[1].id)
    end
  end,
})

return sijiu
