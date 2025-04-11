local miniTaoni = fk.CreateSkill {
  name = "mini_taoni"
}

Fk:loadTranslationTable{
  ["mini_taoni"] = "讨逆",
  [":mini_taoni"] = "出牌阶段开始时，你可失去任意点体力，摸等量的牌，" ..
  "然后令至多X名没有“讨逆”的其他角色各获得1枚“讨逆”（X为你以此法失去的体力值），此回合你的手牌上限为你的体力上限。",

  ["#mini_taoni-invoke"] = "你可以发动〖讨逆〗，失去任意点体力，摸等量张牌，然后令至多等量名角色获得“讨逆”",
  ["@@mini_taoni"] = "讨逆",
  ["#mini_taoni-choose"] = "讨逆：选择至多%arg名角色获得“讨逆”",

  ["$mini_taoni1"] = "欲立万丈之基，先净门庭之度。",
  ["$mini_taoni2"] = "扫定四野，百姓自当归附。",
}

miniTaoni:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(miniTaoni.name) and player.phase == Player.Play and player.hp > 0
  end,
  on_cost = function(self, event, target, player)
    local choices = {}
    for i = 1, player.hp do
      table.insert(choices, tostring(i))
    end
    table.insert(choices, "Cancel")
    local choice = player.room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = miniTaoni.name,
        prompt = "#mini_taoni-invoke",
      }
    )
    if choice ~= "Cancel" then
      event:setCostData(self, choice)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    ---@type string
    local skillName = miniTaoni.name
    ---@type integer
    local num = tonumber(event:getCostData(self))
    local room = player.room
    room:loseHp(player, num, skillName)
    if not player:isAlive() then
      return false
    end

    room:drawCards(player, num, skillName)
    if not player:isAlive() then
      return false
    end

    local targets = table.filter(room:getOtherPlayers(player, false), function(p) return p:getMark("@@mini_taoni") == 0 end)
    if #targets > 0 then
      local tos = room:askToChoosePlayers(
        player,
        {
          targets = targets,
          min_num = 1,
          max_num = num,
          prompt = "#mini_taoni-choose:::" .. num,
          skill_name = skillName,
          cancelable = false,
        }
      )
      table.forEach(tos, function(p) room:addPlayerMark(p, "@@mini_taoni", 1) end)
    end
    room:setPlayerMark(player, "_mini_taoni-turn", 1)
  end,
})

miniTaoni:addEffect("maxcards", {
  name = "#mini_taoni_maxcards",
  fixed_func = function(self, player)
    if player:getMark("_mini_taoni-turn") ~= 0 then
      return player.maxHp
    end
  end
})

return miniTaoni
