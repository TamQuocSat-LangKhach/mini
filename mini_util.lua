---@class miniUtil : Object
---@field public changeRhyme fun(room: Room, player: ServerPlayer, skillName: string, scope?: integer)
local miniUtil = {}

---韵律技转韵
---@param room Room
---@param player ServerPlayer
---@param skillName string
---@param scope? integer
miniUtil.changeRhyme = function(room, player, skillName, scope)
  scope = scope or Player.HistoryPhase
  room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. skillName, player:getSwitchSkillState(skillName, true))
  room:notifySkillInvoked(player, skillName, "switch")
  player:setSkillUseHistory(skillName, 0, scope)
end

--- 加减谋略值
---@param room Room @ 房间
---@param player ServerPlayer @ 角色
---@param num integer @ 加减值，负为减
miniUtil.handleMoulue = function(room, player, num)
  local n = player:getMark("@mini_moulue") or 0
  local new_n = math.min(math.max(n + num, 0), 5)
  room:setPlayerMark(player, "@mini_moulue", new_n)
  room:sendLog{
    type = num > 0 and "#addMoulue" or "#minusMoulue",
    from = player.id,
    arg = math.abs(num),
    arg2 = new_n,
  }
  room:handleAddLoseSkills(player, player:getMark("@mini_moulue") > 0 and "mini_miaoji" or "-mini_miaoji", nil, false, true)
end

Fk:loadTranslationTable{
  ["@mini_moulue"] = "谋略值",
  ["#addMoulue"] = "%from 加了 %arg 点谋略值，现在的谋略值为 %arg2 点",
  ["#minusMoulue"] = "%from 减了 %arg 点谋略值，现在的谋略值为 %arg2 点",
}

return miniUtil
