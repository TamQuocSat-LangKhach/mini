local extension = Package("mini_extreme")
extension.extensionName = "mini"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["mini_extreme"] = "小程序-登峰造极",
  ["mini"] = "小程序",
  ["miniex"] = "极",
}

---韵律技转韵
---@param room Room
---@param player ServerPlayer
---@param skillName string
---@param scope? integer
local function changeRhyme(room, player, skillName, scope)
  scope = scope or Player.HistoryPhase
  room:setPlayerMark(player, MarkEnum.SwithSkillPreName .. skillName, player:getSwitchSkillState(skillName, true))
  room:notifySkillInvoked(player, skillName, "switch")
  player:setSkillUseHistory(skillName, 0, scope)
end

local lvbu = General(extension, "miniex__lvbu", "qun", 4)
local mini_xiaohu = fk.CreateTriggerSkill{
  name = "mini_xiaohu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, false, self.name, true, ".", "#mini_xiaohu-invoke", true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if not player.dead then
      local card = room:getCardsFromPileByRule("slash", 1, "allPiles")
      if #card > 0 then
        room:moveCards({
          ids = card,
          to = player.id,
          toArea = Card.PlayerHand,
          moveReason = fk.ReasonJustMove,
          proposer = player.id,
          skillName = self.name,
        })
      end
    end
  end,
}
local mini_xiaohu_targetmod = fk.CreateTargetModSkill{
  name = "#mini_xiaohu_targetmod",
  extra_target_func = function(self, player, skill)
    if player:hasSkill("mini_xiaohu") and skill.trueName == "slash_skill" then
      return 1
    end
  end,
}
mini_xiaohu:addRelatedSkill(mini_xiaohu_targetmod)
lvbu:addSkill("wushuang")
lvbu:addSkill(mini_xiaohu)
Fk:loadTranslationTable{
  ["miniex__lvbu"] = "极吕布",
  ["mini_xiaohu"] = "虓虎",
  [":mini_xiaohu"] = "你使用【杀】可以额外指定一个目标。出牌阶段开始时，你可以弃置一张手牌，获得一张【杀】。",
  ["#mini_xiaohu-invoke"] = "虓虎：你可以弃置一张手牌，获得一张【杀】",

  ["$mini_xiaohu1"] = "趁势争利，所得远胜遵礼守义。",
  ["$mini_xiaohu2"] = "时合当取之，岂能踌躇不行？",
  ["$wushuang_miniex__lvbu1"] = "此身此武，天下无双！",
  ["$wushuang_miniex__lvbu2"] = "乘赤兔，舞画戟，斩将破敌不过举手而为！",
  ["~miniex__lvbu"] = "我天下无敌，却不能与貂蝉共度余生了……",
}

local daqiao = General(extension, "miniex__daqiao", "wu", 3, 3, General.Female)
local mini_xiangzhi = fk.CreateActiveSkill{
  name = "mini_xiangzhi",
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = function(self)
    if Self:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
      return "#mini_xiangzhi-level"
    else
      return "#mini_xiangzhi-oblique"
    end
  end,
  can_use = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 then
      if player:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
        return true
      else
        return player:isWounded()
      end
    end
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if player:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
      player:drawCards(1, self.name)
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p:getMark("@@mini_xiangzhi") ~= 0 then
          local mark = p:getMark("@@mini_xiangzhi")
          if table.contains(mark, player.id) then
            room:doIndicate(player.id, {p.id})
            p:drawCards(1, self.name)
            table.removeOne(mark, player.id)
            if #mark == 0 then mark = 0 end
            room:setPlayerMark(p, "@@mini_xiangzhi", mark)
          end
        end
      end
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p:getMark("@@mini_xiangzhi") ~= 0 then
          local mark = p:getMark("@@mini_xiangzhi")
          if table.contains(mark, player.id) then
            room:doIndicate(player.id, {p.id})
            if p:isWounded() then
              room:recover({
                who = p,
                num = 1,
                recoverBy = player,
                skillName = self.name
              })
            end
            table.removeOne(mark, player.id)
            if #mark == 0 then mark = 0 end
            room:setPlayerMark(p, "@@mini_xiangzhi", mark)
          end
        end
      end
    end
  end,
}
local mini_xiangzhi_record = fk.CreateTriggerSkill{
  name = "#mini_xiangzhi_record",

  refresh_events = {fk.EventLoseSkill, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if player == target then
      if event == fk.EventLoseSkill then
        return data.name == "mini_xiangzhi"
      else
        return player:hasSkill("mini_xiangzhi", true, true)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      if p:getMark("@@mini_xiangzhi") ~= 0 then
        local mark = p:getMark("@@mini_xiangzhi")
        if table.contains(mark, player.id) then
          table.removeOne(mark, player.id)
          if #mark == 0 then mark = 0 end
          room:setPlayerMark(p, "@@mini_xiangzhi", mark)
        end
      end
    end
  end,
}
local mini_jielie = fk.CreateActiveSkill{
  name = "mini_jielie",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#mini_jielie",
  interaction = function()
    return UI.ComboBox {choices = {"mini_jielie1", "mini_jielie2"}}
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if self.interaction.data == "mini_jielie1" then
      local use = room:askForUseCard(target, ".", "^(jink,nullification)|.|.|hand", "#mini_jielie-use:"..player.id, true)
      if use then
        room:useCard(use)
        if not player.dead and use.card.trueName == "slash" and use.card.color == Card.Red then
          room:loseHp(player, 1, self.name)
          if not player.dead then
            player:setSkillUseHistory(self.name, 0, Player.HistoryPhase)
          end
        end
      end
    else
      local mark = target:getMark("@@mini_xiangzhi")
      if mark == 0 then mark = {} end
      table.insertIfNeed(mark, player.id)
      room:setPlayerMark(target, "@@mini_xiangzhi", mark)
    end
    if not player.dead and player:hasSkill("mini_xiangzhi", true) then
      changeRhyme(room, player, "mini_xiangzhi")
    end
  end,
}
mini_xiangzhi:addRelatedSkill(mini_xiangzhi_record)
daqiao:addSkill(mini_xiangzhi)
daqiao:addSkill(mini_jielie)
Fk:loadTranslationTable{
  ["miniex__daqiao"] = "极大乔",
  ["mini_xiangzhi"] = "相知",
  [":mini_xiangzhi"] = "韵律技，出牌阶段限一次，平：你摸一张牌；仄：你回复1点体力。<br>转韵：你发动〖节烈〗后。<br>"..
  "<font color='grey'>\"<b>韵律技</b>\"<br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
  "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_jielie"] = "节烈",
  [":mini_jielie"] = "出牌阶段限一次，你可以选择一项，令一名其他角色：1.其可以使用一张手牌，若此牌为红色【杀】，则你失去1点体力，"..
  "然后你可以再次发动〖节烈〗；2.你下次发动〖相知〗时，令其获得相同效果。",
  ["#mini_xiangzhi-level"] = "相知：你可以摸一张牌",
  ["#mini_xiangzhi-oblique"] = "相知：你可以回复1点体力",
  ["#mini_jielie"] = "节烈：令一名其他角色执行一项",
  ["mini_jielie1"] = "使用一张手牌",
  ["mini_jielie2"] = "其下次获得“相知”效果",
  ["#mini_jielie-use"] = "节烈：你可以使用一张牌，若为红色【杀】，%src 失去1点体力且可再次发动“节烈”",
  ["@@mini_xiangzhi"] = "相知",

  ["$mini_xiangzhi1"] = "衣带逐水去，绿川盼君留。",
  ["$mini_xiangzhi2"] = "溪边坐流水，与君共清欢。",
  ["$mini_jielie1"] = "此生逢伯符，足以慰平生。",
  ["$mini_jielie2"] = "所幸遇郎君，流离得良人。",
  ["~miniex__daqiao"] = "忆君如流水，日夜无歇时……",
}

local xiaoqiao = General(extension, "miniex__xiaoqiao", "wu", 3, 3, General.Female)
local mini_tongxin = fk.CreateActiveSkill{
  name = "mini_tongxin",
  anim_type = "control",
  card_num = function()
    if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      return 0
    else
      return 1
    end
  end,
  target_num = 1,
  prompt = function(self)
    if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      return "#mini_tongxin-level"
    else
      return "#mini_tongxin-oblique"
    end
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      return false
    else
      return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
    end
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 and to_select ~= Self.id then
      if Self:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
        return not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
      else
        return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if player:getSwitchSkillState("mini_tongxin", false) == fk.SwitchYang then
      local card = room:askForCard(target, 1, 1, false, self.name, false, ".", "#mini_tongxin-give:"..player.id)
      room:obtainCard(player.id, card[1], false, fk.ReasonGive)
      if not target.dead and target:getHandcardNum() <= player:getHandcardNum() then
        target:drawCards(1, self.name)
      end
    else
      room:obtainCard(target.id, effect.cards[1], false, fk.ReasonGive)
      if not target.dead and target:getHandcardNum() >= player:getHandcardNum() then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
local mini_tongxin_record = fk.CreateTriggerSkill{
  name = "#mini_tongxin_record",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("mini_tongxin", true) and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("mini_tongxin-turn")
    if player.phase == Player.Play and not table.contains(mark, data.card:getTypeString()) then
      changeRhyme(room, player, "mini_tongxin")
    end
    table.insertIfNeed(mark, data.card:getTypeString())
    room:setPlayerMark(player, "mini_tongxin-turn", mark)
  end,
}
local mini_shaoyan = fk.CreateTriggerSkill{
  name = "mini_shaoyan",
  anim_type = "drawcard",
  events ={fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.room:getPlayerById(data.from):getHandcardNum() > player:getHandcardNum() and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
mini_tongxin:addRelatedSkill(mini_tongxin_record)
xiaoqiao:addSkill(mini_tongxin)
xiaoqiao:addSkill(mini_shaoyan)
Fk:loadTranslationTable{
  ["miniex__xiaoqiao"] = "极小乔",
  ["mini_tongxin"] = "同心",
  [":mini_tongxin"] = "韵律技，出牌阶段限一次，平：你可以令一名其他角色交给你一张手牌，然后若其手牌数不大于你，其摸一张牌；"..
  "仄：你可以交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害。<br>转韵：出牌阶段，使用本回合未使用过的类型的牌。<br>"..
  "<font color='grey'>\"<b>韵律技</b>\"<br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
  "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_shaoyan"] = "韶颜",
  [":mini_shaoyan"] = "每回合限一次，当你成为其他角色使用牌的目标后，若其手牌数大于你，你摸一张牌。",
  ["#mini_tongxin-level"] = "同心：令一名角色交给你一张手牌，然后若其手牌数不大于你，其摸一张牌",
  ["#mini_tongxin-oblique"] = "同心：交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害",
  ["#mini_tongxin-give"] = "同心：你需交给 %src 一张手牌",

  ["$mini_tongxin1"] = "嘘~心悦何须盟誓，二人同心足矣。",
  ["$mini_tongxin2"] = "看！公瑾与我，如钱之两面，此方口自然为心！",
  ["$mini_shaoyan1"] = "揽二乔于东南？哼，痴人说梦！",
  ["$mini_shaoyan2"] = "有公瑾在，曹贼安可过江东天险？",
  ["~miniex__xiaoqiao"] = "公瑾，好想你再拥我入怀……",
}

--- 加减谋略值
---@param room Room @ 房间
---@param player ServerPlayer @ 角色
---@param num integer @ 加减值，负为减
local function handleMoulue(room, player, num)
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
  ["#addMoulue"] = "%from 加了 %arg 点谋略值，现在的谋略值为 %arg2 点",
  ["#minusMoulue"] = "%from 减了 %arg 点谋略值，现在的谋略值为 %arg2 点",
}

local guojia = General(extension, "miniex__guojia", "wei", 3)
local mini_suanlve = fk.CreateTriggerSkill{
  name = "mini_suanlve",
  anim_type = "special",
  events = {fk.GameStart, fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    if event == fk.GameStart then
      return player:getMark("@mini_moulue") < 5
    else
      if player:getMark("@mini_moulue") >= 5 then return end
      local card_types = {}
      local room = player.room
      local logic = room.logic
      local e = logic:getCurrentEvent()
      local end_id = e.id
      local events = logic.event_recorder[GameEvent.UseCard] or Util.DummyTable
      for i = #events, 1, -1 do
        e = events[i]
        if e.id <= end_id then break end
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(card_types, use.card.type)
        end
      end
      if #card_types > 0 then
        self.cost_data = #card_types
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      handleMoulue(room, player, 3)
    else
      handleMoulue(room, player, self.cost_data)
    end
  end,
}
local mini_dingce = fk.CreateViewAsSkill{
  name = "mini_dingce",
  pattern = ".",
  interaction = function()
    local names = {}
      local card = Fk:cloneCard(Self:getMark("mini_dingce-turn"))
      if ((Fk.currentResponsePattern == nil and card.skill:canUse(Self, card) and not Self:prohibitUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        names = {Self:getMark("mini_dingce-turn")}
      end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    handleMoulue(player.room, player, -1)
  end,
  enabled_at_play = function(self, player)
    if player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or player:getMark("mini_dingce-turn") == 0 or player:isNude() or
      player:getMark("@mini_moulue") < 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
      return true
    end
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or player:getMark("mini_dingce-turn") == 0 or player:isNude() or
      player:getMark("@mini_moulue") < 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    if card.skill:canUse(Self, card) and not Self:prohibitUse(card) then
      return true
    end
  end,
}
local mini_dingce_record = fk.CreateTriggerSkill{
  name = "#mini_dingce_record",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and (data.card.type == Card.TypeBasic or data.card:isCommonTrick())
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "mini_dingce-turn", data.card.name)
  end,
}
local mini_miaoji = fk.CreateViewAsSkill{
  name = "mini_miaoji",
  pattern = "dismantlement,nullification,ex_nihilo",
  interaction = function()
    local all_names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    local names = {}
    for name, v in pairs(all_names) do
      if Self:getMark("@mini_moulue") >= v then
        local card = Fk:cloneCard(name)
        if ((Fk.currentResponsePattern == nil and Self:canUse(card) and not Self:prohibitUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
          table.insertIfNeed(names, name)
        end
      end
    end
    if #names > 0 then
      return UI.ComboBox { choices = names, all_choices = {"dismantlement", "nullification", "ex_nihilo"} }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    handleMoulue(player.room, player, - names[use.card.trueName])
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(self.name) > 0 then return false end
    local all_names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    for name, v in pairs(all_names) do
      if Self:getMark("@mini_moulue") >= v then
        local card = Fk:cloneCard(name)
        if ((Fk.currentResponsePattern == nil and Self:canUse(card) and not Self:prohibitUse(card)) or
            (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
          return true
        end
      end
    end
  end,
}
guojia:addSkill(mini_suanlve)
mini_dingce:addRelatedSkill(mini_dingce_record)
guojia:addSkill(mini_dingce)
guojia:addRelatedSkill(mini_miaoji)
Fk:loadTranslationTable{
  ["miniex__guojia"] = "极郭嘉",
  ["mini_suanlve"] = "算略",
  [":mini_suanlve"] = "游戏开始时，你获得3点谋略值。每个回合结束时，你获得X点谋略值（X为你本回合使用牌的类别数）。"..
  "<br><font color='grey'>#\"<b>谋略值</b>\"：谋略值上限为5，有谋略值的角色拥有〖妙计〗。</font>",
  ["mini_dingce"] = "定策",
  [":mini_dingce"] = "每回合限一次，你可以消耗1点谋略值，将一张牌当你本回合使用的上一张基本牌或普通锦囊牌使用。",
  ["mini_miaoji"] = "妙计",
  [":mini_miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；3.【无懈可击】或【无中生有】。",
  ["@mini_moulue"] = "谋略值",

  ["$mini_dingce1"] = "观天下之势，以措平乱之策。",
  ["$mini_dingce2"] = "主公已有成略，进可依计而行。",
  ["$mini_suanlve1"] = "敌我之人，皆可为我所欲。",
  ["$mini_suanlve2"] = "谋，无主则困；事，无备则废。",
  ["$mini_miaoji1"] = "计能规于未肇，虑能防于未然。",
  ["$mini_miaoji2"] = "心静则神策生，虑远则计谋成。",
  ["~miniex__guojia"] = "经此一别，已无再见之日……",
}

local machao = General(extension, "miniex__machao", "shu", 4)
local qipao = fk.CreateTriggerSkill{
  name = "mini_qipao",
  events = {fk.TargetSpecified},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and not player.room:getPlayerById(data.to).dead 
  end,
  on_cost = function(self, event, target, player, data)
    return target.room:askForSkillInvoke(player, self.name, data, "#mini_qipao-ask::" .. data.to)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(data.to)
    local choices = {"mini_qipao_invalid"}
    if #target:getCardIds(Player.Equip) > 0 then table.insert(choices, 1, "mini_qipao_discard") end
    local choice = room:askForChoice(target, choices, self.name)
    if choice == "mini_qipao_discard" then
      target:throwAllCards("e")
    else
      data.disresponsive = true
      room:setPlayerMark(target, MarkEnum.UncompulsoryInvalidity .. "-turn", 1)
    end
  end,
}

local zhuixi = fk.CreateTriggerSkill{
  name = "mini_zhuixi",
  events = {fk.EventPhaseStart},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and target.phase == Player.Finish and table.every(player.room.alive_players, function(p) return player:inMyAttackRange(p) or player == p end) and not player:prohibitUse(Fk:cloneCard("slash"))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not player:isProhibited(p, slash) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#mini_zhuixi-ask", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local slash = Fk:cloneCard("slash")
    slash.skillName = self.name
    player.room:useCard{
      from = target.id,
      tos = table.map(self.cost_data, function(pid) return { pid } end),
      card = slash,
      extraUse = true,
    }
  end,
}
local mini_zhuixi_distance = fk.CreateDistanceSkill{
  name = "#mini_zhuixi_distance",
  fixed_func = function(self, from, to)
    if from:hasSkill(self) and #to:getEquipments(Card.SubtypeOffensiveRide) == 0 and #to:getEquipments(Card.SubtypeDefensiveRide) == 0 then
      return 1
    end
  end,
}
zhuixi:addRelatedSkill(mini_zhuixi_distance)

machao:addSkill(qipao)
machao:addSkill(zhuixi)

Fk:loadTranslationTable{
  ["miniex__machao"] = "极马超",
  ["mini_qipao"] = "弃袍",
  [":mini_qipao"] = "当你使用【杀】指定目标后，你可令其选择一项：1. 弃置装备区内的所有牌（至少一张）；2. 此回合非锁定技失效且不能响应此【杀】。",
  ["mini_zhuixi"] = "追袭",
  [":mini_zhuixi"] = "①结束阶段，若其他角色均处于你的攻击范围内，你可选择一名角色，视为对其使用【杀】。②你至装备区里没有坐骑牌的角色的距离视为1。",

  ["#mini_qipao-ask"] = "你可对 %dest 发动“弃袍”",
  ["mini_qipao_discard"] = "弃置装备区内的所有牌",
  ["mini_qipao_invalid"] = "此回合非锁定技失效且不能响应此【杀】",
  ["@@mini_qipao-turn"] = "弃袍",
  ["#mini_qipao_dr"] = "弃袍",
  ["#mini_zhuixi-ask"] = "追袭：你可选择一名角色，视为对其使用【杀】",

  ["$mini_qipao1"] = "哼，凭汝瘦马断矛，安可伤我？",
  ["$mini_qipao2"] = "汝与其行口舌之快，不若寻趁手之兵！",
  ["$mini_zhuixi1"] = "万军在前，汝何敢拒我？",
  ["$mini_zhuixi2"] = "此战为胜者生，汝敢战否？",
  ["~miniex__machao"] = "曹贼！战场再见，吾必杀汝！",
}

local zhugeliang = General(extension, "miniex__zhugeliang", "shu", 3)
local sangu = fk.CreateTriggerSkill{
  name = "mini_sangu",
  events = {fk.TargetConfirmed},
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    player:getMark("@mini_sangu") > 0 and player:getMark("@mini_sangu") % 3 == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@mini_sangu", 0)
    if player:getMark("@mini_moulue") < 5 then
      handleMoulue(room, player, 3)
    end
    room:askForGuanxing(player, room:getNCards(3), nil, nil, self.name)
  end,

  refresh_events = {fk.TargetConfirmed},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini_sangu", 1)
  end,
}

local yanshi = fk.CreateActiveSkill{
  name = "mini_yanshi",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == player:getMark("_mini_yanshi-phase")
  end,
  target_num = 0,
  card_num = function(self)
    return Self:usedSkillTimes(self.name, Player.HistoryPhase) > 0 and 1 or 0
  end,
  card_filter = function(self, to_select, selected_cards)
    return #selected_cards < (Self:usedSkillTimes(self.name, Player.HistoryPhase) > 0 and 1 or 0)
    and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  interaction = function(self)
    local all_choices = {"Top", "Bottom"}
    local choices = table.simpleClone(all_choices)
    table.removeOne(choices, Self:getMark("_mini_yanshi_record-phase"))
    return UI.ComboBox { choices = choices, all_choices = all_choices }
  end,
  prompt = function(self, selected_cards, selected_targets)
    local choices = {"Top", "Bottom"}
    table.removeOne(choices, Self:getMark("_mini_yanshi_record-phase"))
    if #choices == 1 then
      return "#mini_yanshi_only:::" .. choices[1]
    else
      return "#mini_yanshi_choose"
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choice = self.interaction.data
    if not choice then return false end
    room:setPlayerMark(player, "_mini_yanshi_record-phase", choice)
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, player, player)
      if player.dead then return end
    end
    player:drawCards(1, self.name, choice == "Bottom" and "bottom" or "top", "@@mini_yanshi-inhand-phase")
  end,
}
local yanshi_delay = fk.CreateTriggerSkill{
  name = "#mini_yanshi_delay",
  refresh_events = {fk.PreCardUse},
  can_refresh = function(self, event, target, player, data)
    return target == player and table.find(Card:getIdList(data.card), function(id)
      return Fk:getCardById(id):getMark("@@mini_yanshi-inhand-phase") > 0
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "mini_yanshi", "special")
    room:addPlayerMark(player, "_mini_yanshi-phase")
  end,
}
yanshi:addRelatedSkill(yanshi_delay)

zhugeliang:addSkill(sangu)
zhugeliang:addSkill(yanshi)
zhugeliang:addRelatedSkill("mini_miaoji")

Fk:loadTranslationTable{
  ["miniex__zhugeliang"] = "极诸葛亮",
  ["mini_sangu"] = "三顾",
  [":mini_sangu"] = "锁定技，每当有三张牌指定你为目标后，你获得3点“谋略值”，然后你观看牌堆顶的三张牌并将这些牌置于牌堆顶或牌堆底。"..
  "<br><font color='grey'>#\"<b>谋略值</b>\"：谋略值上限为5，有谋略值的角色拥有〖妙计〗。</font>",
  ["mini_yanshi"] = "演势",
  [":mini_yanshi"] = "出牌阶段限一次，你可从牌堆顶或牌堆底（不可与你此阶段上一次选择的相同）摸一张牌。若你于此阶段使用了此牌，你可弃置一张牌再次发动〖演势〗。",

  ["@mini_sangu"] = "三顾",
  ["@@mini_yanshi-inhand-phase"] = "演势",
  ["#mini_yanshi_choose"] = "演势：选择从牌堆顶或牌堆底摸一张牌",
  ["#mini_yanshi_only"] = "演势：从%arg摸一张牌",

  ["$mini_sangu1"] = "大梦先觉，感三顾之诚，布天下三分。",
  ["$mini_sangu2"] = "卧龙初晓，铭鱼水之情，托死生之志。",
  ["$mini_yanshi1"] = "进荆州，取巴蜀，以成峙鼎三分之势。",
  ["$mini_yanshi2"] = "天下虽多庸饶，亦在隆中方寸之间。",
  ["$mini_miaoji_miniex__zhugeliang1"] = "大梦先觉，感三顾之诚，布天下三分。",
  ["$mini_miaoji_miniex__zhugeliang2"] = "卧龙初晓，铭鱼水之情，托死生之志。",
  ["~miniex__zhugeliang"] = "君臣鱼水犹昨日，煌煌天命终不归……",
}

local huangyueying = General(extension, "miniex__huangyueying", "shu", 3, 3, General.Female)
local miaobi = fk.CreateTriggerSkill{
  name = "mini_miaobi",
  events = {fk.CardUseFinished, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if event == fk.CardUseFinished then
      if not (player:hasSkill(self) and player.phase == Player.Play
      and data.card.type == Card.TypeTrick and U.isPureCard(data.card) and not table.contains(player:getTableMark("_mini_miaobi_used-turn"), data.card.trueName)) then return false end
      local room = player.room
      if room:getCardArea(data.card) ~= Card.Processing then return false end
      local targets = {}
      for _, pid in ipairs(TargetGroup:getRealTargets(data.tos)) do
        local p = room:getPlayerById(pid)
        if not p.dead then
          table.insertIfNeed(targets, pid)
        end
      end
      if #targets > 0 then
        self.cost_data = targets
        return true
      end
    else
      return #player:getPile("mini_miaobi_penmanship") > 0 and player.phase == Player.Start
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.CardUseFinished then
      local targets = self.cost_data
      local room = player.room
      if #targets == 1 then
        if room:askForSkillInvoke(player, self.name, data, "#mini_miaobi_only-ask::" .. targets[1] .. ":" .. data.card:toLogString()) then
          self.cost_data = targets[1]
          return true
        end
      else
        local tos = player.room:askForChoosePlayers(player, targets, 1, 1, "#mini_miaobi-ask:::" .. data.card:toLogString(), self.name)
        if #tos > 0 then
          self.cost_data = tos[1]
          return true
        end
      end
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      local record = player:getTableMark("_mini_miaobi_used-turn")
      table.insert(record, data.card.trueName)
      room:setPlayerMark(player, "_mini_miaobi_used-turn", record)
      local to = room:getPlayerById(self.cost_data)
      to:addToPile("mini_miaobi_penmanship", data.card, true, self.name)
      if table.contains(to:getPile("mini_miaobi_penmanship"), data.card.id) then
        record = to:getTableMark("_mini_miaobi")
        record[tostring(player.id)] = record[tostring(player.id)] or {}
        table.insert(record[tostring(player.id)], data.card.id)
        room:setPlayerMark(to, "_mini_miaobi", record)
      end
    else
      local record = table.simpleClone(player:getMark("_mini_miaobi"))
      for k, v in pairs(record) do
        local from = room:getPlayerById(tonumber(k))
        local cards = table.filter(v, function (cid)
          return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
        end)
        if not from.dead and #cards > 0 then
          local c = {}
          if player ~= from then
            c = room:askForCard(player, 1, 1, true, self.name, true, ".|.|.|.|.|trick", "#mini_miaobi_delay:" .. from.id)
          end
          if #c > 0 then
            room:moveCardTo(c, Card.PlayerHand, from, fk.ReasonGive, self.name, nil, true, from.id)
            cards = table.filter(cards, function (cid)
              return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
            end)
            room:moveCards{
              ids = cards,
              info = table.map(cards, function(id) return {cardId = id, fromArea = Card.PlayerSpecial,
                fromSpecialName = "mini_miaobi_penmanship"} end),
              from = player.id,
              toArea = Card.DiscardPile,
              moveReason = fk.ReasonPutIntoDiscardPile,
              skillName = self.name,
            }
          else
            for _, cid in ipairs(cards) do
              local card = Fk:getCardById(cid)
              if from:canUse(card) and not from:prohibitUse(card) and not from:isProhibited(player, card) and
                  (card.skill:modTargetFilter(player.id, {}, from.id, card, false)) then
                local tos = { {player.id} }
                if card.skill:getMinTargetNum() == 2 then
                  local targets = table.filter(room.alive_players, function (p)
                    return card.skill:targetFilter(p.id, {player.id}, {}, card)
                  end)
                  if #targets > 0 then
                    local to_slash = room:askForChoosePlayers(from, table.map(targets, Util.IdMapper), 1, 1, "#mini_miaobi-choose::"..player.id..":"..card:toLogString(), self.name, false)
                    if #to_slash > 0 then
                      table.insert(tos, to_slash)
                    end
                  end
                end

                if #tos >= card.skill:getMinTargetNum() then
                  room:useCard({
                    from = from.id,
                    tos = tos,
                    card = card,
                  })
                end
              end
            end
            cards = table.filter(cards, function (cid)
              return table.contains(player:getPile("mini_miaobi_penmanship"), cid)
            end)
          end
        end
        if #cards > 0 then
          room:moveCards{
            ids = cards,
            info = table.map(cards, function(id) return {cardId = id, fromArea = Card.PlayerSpecial,
              fromSpecialName = "mini_miaobi_penmanship"} end),
            from = player.id,
            toArea = Card.DiscardPile,
            moveReason = fk.ReasonPutIntoDiscardPile,
            skillName = self.name,
          }
        end
      end
      room:setPlayerMark(player, "_mini_miaobi", 0)
    end
  end,
}
local huixin = fk.CreateTriggerSkill{
  name = "mini_huixin",
  events = {fk.TurnStart},
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = #player:getCardIds("e")
    room:handleAddLoseSkills(player, num % 2 == 0 and "ex__jizhi" or "mini_jifeng")
    local logic = room.logic
    logic:getCurrentEvent():findParent(GameEvent.Turn):addExitFunc(function()
      room:handleAddLoseSkills(player, '-ex__jizhi|-mini_jifeng')
    end)
  end,
}

local jifeng = fk.CreateActiveSkill{
  name = "mini_jifeng",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  card_num = 1,
  card_filter = function(self, to_select)
    return not Self:prohibitDiscard(Fk:getCardById(to_select)) and Fk:currentRoom():getCardArea(to_select) == Player.Hand
  end,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from, from)
    if from:isAlive() then
      local card = room:getCardsFromPileByRule(".|.|.|.|.|trick")
      if #card > 0 then
        room:obtainCard(from, card[1], true, fk.ReasonPrey)
      end
    end
  end,
}

huangyueying:addSkill(miaobi)
huangyueying:addSkill(huixin)
huangyueying:addRelatedSkill("ex__jizhi")
huangyueying:addRelatedSkill(jifeng)

Fk:loadTranslationTable{
  ["miniex__huangyueying"] = "极黄月英",
  ["mini_miaobi"] = "妙笔",
  [":mini_miaobi"] = "当你于出牌阶段内使用的、非转化且非虚拟的锦囊牌结算结束后，你可将此牌置于其中一个目标角色的武将牌上（每牌名每回合限一次）。拥有“妙笔”牌的角色的准备阶段，其选择一项：1. 交给你一张锦囊牌，将“妙笔”牌置入弃牌堆；2. 你对其依次使用“妙笔”牌。",
  ["mini_huixin"] = "慧心",
  [":mini_huixin"] = "回合开始时，若你装备区里的牌的数量为：偶数，此回合你拥有〖集智〗；奇数，此回合你拥有〖祭风〗。",
  -- 集智：当你使用非转化的锦囊牌时，你可以摸一张牌。本回合你以此法获得的牌不计入手牌上限。 不想写了
  ["mini_jifeng"] = "祭风", -- 神诸葛
  [":mini_jifeng"] = "出牌阶段限一次，你可弃置一张手牌，然后从牌堆中随机获得一张锦囊牌。",

  ["#mini_miaobi_only-ask"] = "妙笔：你可将%arg置于%dest的武将牌上",
  ["#mini_miaobi-ask"] = "妙笔：你可将%arg置于一个目标角色的武将牌上",
  ["mini_miaobi_penmanship"] = "妙笔",
  ["#mini_miaobi_delay"] = "妙笔：将一张锦囊牌交给 %src，否则其对你依次使用“妙笔”牌",
  ["#mini_miaobi-choose"] = "妙笔：选择对%dest使用的%arg的副目标",

  ["$mini_miaobi1"] = "行舟泛知海，点墨启新灵。",
  ["$mini_miaobi2"] = "纵横览前贤，风月皆成鉴。",
  ["$mini_huixin1"] = "星霜岂堪渡，蕙心自娟娟。",
  ["$mini_huixin2"] = "清心澄若水，兰蕙寄芳姿。",
  ["~miniex__huangyueying"] = "纨质陨残暮，思旧梦魂远。",
}

local miniex__caocao = General(extension, "miniex__caocao", "wei", 4)
local delu = fk.CreateActiveSkill{
  name = "mini_delu",
  prompt = "#mini_delu",
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  min_target_num = 1,
  max_target_num = 99,
  target_filter = function(self, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and target.hp <= Self.hp and Self:canPindian(target)
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = effect.tos
    local pd = U.jointPindian(player, table.map(targets, Util.Id2PlayerMapper), self.name)
    local winner = pd.winner
    if winner then
      table.insert(targets, player.id)
      table.removeOne(targets, winner.id)
      if winner == player then player:broadcastSkillInvoke("guixin") end -- 彩蛋
      if winner.dead then return false end
      room:sortPlayersByAction(targets)
      for _, pid in ipairs(targets) do
        local p = room:getPlayerById(pid)
        if not p:isAllNude() then
          local id = table.random(p:getCardIds{ Player.Hand, Player.Equip, Player.Judge})
          room:obtainCard(winner, id, false, fk.ReasonPrey)
          room:delay(100)
        end
      end
    end
  end,
}
local delu_delay = fk.CreateTriggerSkill{
  name = "#mini_delu_delay",
  mute = true,
  events = {fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    return data.from == player and data.reason == "mini_delu"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.fromCard.number = math.min(data.fromCard.number + #data.tos + 1, 13)
  end,
}
delu:addRelatedSkill(delu_delay)

local zhujiu = fk.CreateActiveSkill{
  name = "mini_zhujiu",
  prompt = "#mini_zhujiu",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  target_num = 1,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 1 then return false end
    local target = Fk:currentRoom():getPlayerById(to_select)
    return to_select ~= Self.id and not target:isKongcheng()
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local result = U.askForJointCard({player, target}, 1, 1, false, self.name, false, ".|.|.|hand", "#askForZhujiu")
    local fromCard, toCard = result[player.id][1], result[target.id][1]
    U.swapCards(room, player, player, target, {fromCard}, {toCard}, self.name)
    if Fk:getCardById(fromCard):compareColorWith(Fk:getCardById(toCard)) then
      if player:isWounded() and not player.dead then
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    elseif not player.dead and not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}

miniex__caocao:addSkill(delu)
miniex__caocao:addSkill(zhujiu)
miniex__caocao:addSkill("hujia") -- 村

Fk:loadTranslationTable{
  ["miniex__caocao"] = "极曹操",
  ["mini_delu"] = "得鹿",
  [":mini_delu"] = "出牌阶段限一次，你可与任意名体力值不大于你的角色进行一次<a href='zhuluPindian'>逐鹿</a>，赢的角色依次获得没赢的角色区域内随机一张牌。此次你拼点的牌点数+X（X为参加拼点的角色数）。",
  ["mini_zhujiu"] = "煮酒",
  [":mini_zhujiu"] = "出牌阶段限一次，你可选择一名其他角色，你与其同时选择一张手牌并交换，若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害。",
  ["zhuluPindian"] = "<b>逐鹿</b>：即“共同拼点”，所有目标角色一起拼点，至多有一个胜者，点数最大者有多人时视为无胜者。",

  ["#mini_delu_delay"] = "得鹿",
  ["#mini_delu_get"] = "得鹿：获得%dest区域内一张牌",
  ["#mini_delu"] = "得鹿：你可与任意名体力值不大于你的角色共同拼点，<br />赢的角色依次获得没赢的角色区域内随机一张牌",
  ["#askForZhujiu"] = "煮酒：选择一张手牌交换",
  ["#mini_zhujiu"] = "煮酒：你可选择一名其他角色，你与其同时选择一张手牌并交换，<br />若这两张牌颜色相同/不同，你回复1点体力/你对其造成1点伤害",

  ["$mini_delu1"] = "今吾得鹿中原，欲请诸雄会猎四方！",
  ["$mini_delu2"] = "天下所图者为何？哼！不过吾彀中之物尔！",
  ["$mini_zhujiu1"] = "天下风云几多事，青梅煮酒论英雄。",
  ["$mini_zhujiu2"] = "玄德久历四方，可识天下英雄？",
  ["~miniex__caocao"] = "吾之一生或负天下，然终不负己心。",
}

local simayi = General(extension, "miniex__simayi", "wei", 3)

local yinren = fk.CreateTriggerSkill{
  name = "mini_yinren",
  anim_type = "defensive",
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player.skipped_phases[Player.Play] and not player.skipped_phases[Player.Discard]
  end,
  on_use = function(self, event, target, player, data)
    player:skip(Player.Play)
    player:skip(Player.Discard)
    for _, s in ipairs{"ex__jianxiong", "xingshang", "mingjian"} do
      if not player:hasSkill(s) then
        player.room:handleAddLoseSkills(player, s, nil)
        break
      end
    end
  end,
}

local duoquan = fk.CreateTriggerSkill{
  name = "mini_duoquan",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#mini_duoquan", self.name, true, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = room:getPlayerById(self.cost_data)
    local choice = U.askforViewCardsAndChoice(player, target:getCardIds("h"), {"basic", "trick", "equip"}, self.name, "#mini_duoquan-ask::" .. target.id)
    local record = target:getTableMark("_mini_duoquan")
    record[tostring(player.id)] = choice
    room:setPlayerMark(target, "_mini_duoquan", record)
  end,
}
local duoquan_delay = fk.CreateTriggerSkill{
  name = "#mini_duoquan_delay",
  events = {fk.CardUsing},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target:getMark("_mini_duoquan") ~= 0 and target:getMark("_mini_duoquan")[tostring(player.id)] == data.card:getTypeString()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:doIndicate(player.id, {target.id})
    local record = target:getMark("_mini_duoquan")
    record[tostring(player.id)] = nil
    if table.empty(record) then record = 0 end
    room:setPlayerMark(target, "_mini_duoquan", record)
    if data.toCard ~= nil then
      data.toCard = nil
    else
      data.tos = {}
    end
    room.logic:getCurrentEvent():addCleaner(function(s)
      if player.dead then return end
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if not e then return end
      local use = e.data[1]
      local ids = table.filter(Card:getIdList(use.card), function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #ids == 0 then return end
      U.askForUseRealCard(room, player, ids, ".", "mini_duoquan", "#mini_duoquan-use", {expand_pile = ids})
    end)
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return player == target and target:getMark("_mini_duoquan") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local record = target:getMark("_mini_duoquan")
    for k, v in pairs(record) do
      if v ~= data.card:getTypeString() then
        record[k] = nil
      end
    end
    if table.empty(record) then record = 0 end
    target.room:setPlayerMark(target, "_mini_duoquan", record)
  end,
}
duoquan:addRelatedSkill(duoquan_delay)

simayi:addSkill(yinren)
simayi:addSkill(duoquan)
simayi:addRelatedSkill("ex__jianxiong")
simayi:addRelatedSkill("xingshang")
simayi:addRelatedSkill("mingjian")

Fk:loadTranslationTable{
  ["miniex__simayi"] = "极司马懿",
  ["mini_yinren"] = "隐忍",
  [":mini_yinren"] = "回合开始时，你可跳过出牌阶段和弃牌阶段，然后获得以下技能中你没有的第一个技能：〖奸雄〗、〖行殇〗、〖明鉴〗。",
  ["mini_duoquan"] = "夺权",
  [":mini_duoquan"] = "结束阶段，你可观看一名其他角色的手牌，秘密选择一种类型，当其使用下一张牌时，若此牌的类型与你选择的类型相同，则你令取消之，然后当此牌结算完毕后，你可使用此牌对应的一张实体牌。",

  ["#mini_duoquan"] = "夺权：你可选择一名其他角色，观看其手牌并秘密选择一种类型",
  ["#mini_duoquan-use"] = "夺权：你可以使用其中的一张牌",
  ["#mini_duoquan_delay"] = "夺权",
  ["#mini_duoquan-ask"] = "夺权：观看%dest的手牌，选择一种类型",

  ["$mini_yinren1"] = "小隐于野，大隐于朝。",
  ["$mini_yinren2"] = "进退有度，举重若轻。",
  ["$mini_duoquan1"] = "曹氏三代基业，一朝尽入我手！",
  ["$mini_duoquan2"] = "为政者不仁，自可夺之！",
  ["~miniex__simayi"] = "辟基立业，就交于子元了……",
}

local yuanshao = General(extension, "miniex__yuanshao", "qun", 4)

local hongtu = fk.CreateActiveSkill{
  name = "mini_zunbei",
  anim_type = "offensive",
  prompt = "#mini_zunbei",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and table.find(Fk:currentRoom().alive_players, function(p)
      return player:canPindian(p) and player ~= p
    end)
  end,
  target_filter = Util.FalseFunc,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.filter(room.alive_players, function(p)
      return player:canPindian(p) and player ~= p
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local pd = U.jointPindian(player, targets, self.name)
    local winner = pd.winner
    if winner and not winner.dead then
      local card = Fk:cloneCard("archery_attack")
      if not U.canUseCard(room, winner, card) then return end
      local tos = table.map(table.filter(room.alive_players, function(p)
        return U.canUseCardTo(room, winner, p, card)
      end), Util.IdMapper)
      local use = { ---@type CardUseStruct
        from = winner.id,
        tos = table.map(tos, function(id) return {id} end),
        card = card,
        extraUse = true,
      }
      room:useCard(use)
      if use.damageDealt and not player.dead then
        local num = 0
        for _, id in ipairs(tos) do
          if use.damageDealt[id] then
            num = num + use.damageDealt[id]
          end
        end
        player:drawCards(num, self.name)
      end
    elseif not winner then
      player:setSkillUseHistory(self.name, 0, Player.HistoryPhase)
    end
  end,
}

local damage_nature_table = {
  [fk.NormalDamage] = "normal_damage",
  [fk.FireDamage] = "fire_damage",
  [fk.ThunderDamage] = "thunder_damage",
  [fk.IceDamage] = "ice_damage",
}

local mengshou = fk.CreateTriggerSkill{
  name = "mini_mengshou",
  events = {fk.DamageInflicted},
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.from and data.from ~= player and player:usedSkillTimes(self.name, Player.HistoryRound) == 0) then return end
    local x, y = 0, 0
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from == player then
        x = x + 1
      elseif damage.from == data.from then
        y = y + 1
      end
      return false
    end, Player.HistoryRound)
    return y <= x
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#mini_mengshou-ask::" .. data.from.id .. ":" .. data.damage .. ":" .. damage_nature_table[data.damageType])
  end,
  on_use = function (self, event, target, player, data)
    player.room:sendLog{
      type = "#BreastplateSkill",
      from = player.id,
      arg = self.name,
      arg2 = data.damage,
      arg3 = damage_nature_table[data.damageType],
    }
    return true
  end
}

yuanshao:addSkill(hongtu)
yuanshao:addSkill(mengshou)

Fk:loadTranslationTable{
  ["miniex__yuanshao"] = "极袁绍",
  ["mini_zunbei"] = "尊北",
  [":mini_zunbei"] = "出牌阶段限一次，你可与所有其他角色进行一次<a href='zhuluPindian'>逐鹿</a>，然后若此次“逐鹿”：有胜者，则胜者视为使用一张【万箭齐发】，此牌结算结束后，你摸X张牌（X为受到此牌伤害的角色数）；没有胜者，则此技能视为此阶段未发动过。",
  ["mini_mengshou"] = "盟首",
  [":mini_mengshou"] = "每轮限一次，当你受到其他角色造成的伤害时，若其本轮造成的伤害值不大于你，你可防止此伤害。",

  ["#mini_zunbei"] = "尊北：你可与所有其他角色共同拼点，<br/>若有胜者，则胜者视为使用一张【万箭齐发】，此牌结算结束后，你摸X张牌（X为受到此牌伤害的角色数）；<br/>没有胜者，则此技能视为此阶段未发动过",
  ["#mini_mengshou-ask"] = "盟首：你可防止 %dest 造成的 %arg 点 %arg2 伤害",

  ["$mini_zunbei1"] = "今据四州之地，足以称雄。",
  ["$mini_zunbei2"] = "昔讨董卓，今肃河北，吾当为汉室首功。",
  ["$mini_mengshou1"] = "董贼弑君篡权，为天下所不容！",
  ["$mini_mengshou2"] = "今歃血为盟，誓诛此逆贼！",
  ["~miniex__yuanshao"] = "思谋无断，始至今日……",
}

local lusu = General(extension, "miniex__lusu", "wu", 3)

local lvyuan = fk.CreateTriggerSkill{
  name = "mini_lvyuan",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isNude()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local throw = room:askForDiscard(player, 1, #player:getCardIds("he"), true, self.name, false, nil, "#mini_lvyuan-discard")
    if player.dead then return end
    player:drawCards(#throw, self.name)
    if #throw == 1 then return end
    local color = Fk:getCardById(throw[1]).color
    if color == Card.NoColor then return end
    if table.every(throw, function(id) return Fk:getCardById(id).color == color end) then
      room:setPlayerMark(player, "@mini_lvyuan", color == Card.Black and "red" or "black")
    end
  end,

  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@mini_lvyuan") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@mini_lvyuan", 0)
  end
}
local lvyuan_delay = fk.CreateTriggerSkill{
  name = "#mini_lvyuan_delay",
  mute = true,
  events = {fk.AfterCardsMove},
  can_trigger = function (self, event, target, player, data)
    if player:getMark("@mini_lvyuan") == 0 or player.dead then return false end
    local num = 0
    for _, move in ipairs(data) do
      if move.from == player.id and (move.to ~= move.from or not table.contains({Card.PlayerEquip, Card.PlayerHand}, move.toArea)) then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId):getColorString() == player:getMark("@mini_lvyuan") and info.fromArea == Card.PlayerHand then
            num = num +1
          end
        end
      end
    end
    if num > 0 then
      self.cost_data = num
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:notifySkillInvoked(player, lvyuan.name, "drawcard")
    player:broadcastSkillInvoke(lvyuan.name)
    player:drawCards(self.cost_data, self.name)
  end
}
lvyuan:addRelatedSkill(lvyuan_delay)

local hezong = fk.CreateTriggerSkill{
  name = "mini_hezong",
  events = {fk.RoundStart},
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local targets = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper), 2, 2, "#mini_hezong-ask", self.name, true)
    if #targets > 0 then
      self.cost_data = targets
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = self.cost_data
    for i, pid in ipairs(targets) do
      local p = room:getPlayerById(pid)
      local record = p:getTableMark("@mini_hezong-round")
      table.insertIfNeed(record, room:getPlayerById(targets[3-i]).general)
      room:setPlayerMark(p, "@mini_hezong-round", record)
      record = p:getTableMark("_mini_hezong-round")
      table.insertIfNeed(record, targets[3-i])
      room:setPlayerMark(p, "_mini_hezong-round", targets[3-i])
    end
  end
}
local hezong_delay = fk.CreateTriggerSkill{
  name = "#mini_hezong_delay",
  mute = true,
  events = {fk.CardUseFinished, fk.TargetConfirming},
  can_trigger = function (self, event, target, player, data)
    if data.card.trueName ~= "slash" or target.id ~= player:getMark("_mini_hezong-round") then return false end
    if event == fk.CardUseFinished then
      local tos = TargetGroup:getRealTargets(data.tos)
      if #tos == 0 or tos[1] == player.id or tos[1] == player:getMark("_mini_hezong-round") then return end
      for _, pid in ipairs(tos) do
        if pid ~= tos[1] then
          return false
        end
      end
      self.cost_data = tos[1]
      return not player.room:getPlayerById(tos[1]).dead
    else
      self.cost_data = nil
      return U.isOnlyTarget(target, data, event) and data.from ~= player.id and data.from ~= player:getMark("_mini_hezong-round")
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local responser = target == player and room:getPlayerById(player:getMark("_mini_hezong-round")) or player
    if event == fk.CardUseFinished then
      local to = self.cost_data
      local use = room:askForUseCard(responser, "slash", "slash", "#mini_hezong-use:" .. target.id .. ":" .. to, true, {exclusive_targets = {to}, bypass_times = true, bypass_distances = true })
      if use then
        use.extraUse = true
        room:useCard(use)
      elseif not responser:isNude() then
        local card = room:askForCard(responser, 1, 1, true, self.name, false, nil, "#mini_hezong-give_slash::" .. target.id)
        room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
      end
    else
      local card = room:askForCard(responser, 1, 1, true, self.name, true, "jink", "#mini_hezong-give::" .. target.id)
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonGive, self.name, nil, true, player.id)
      else
        AimGroup:addTargets(room, data, responser.id)
      end
    end
  end
}
hezong:addRelatedSkill(hezong_delay)

lusu:addSkill(lvyuan)
lusu:addSkill(hezong)

Fk:loadTranslationTable{
  ["miniex__lusu"] = "极鲁肃",
  ["mini_lvyuan"] = "虑远",
  [":mini_lvyuan"] = "结束阶段，你可以弃置任意张牌并摸等量的牌，然后若你以此法弃置了至少两张牌且颜色相同，直到你的下回合开始时，当你失去另一种颜色的一张手牌后，你摸一张牌。",
  ["mini_hezong"] = "合纵",
  [":mini_hezong"] = "每轮开始时，你可以选择两名角色，本轮内：" ..
    "当其中一名角色使用【杀】指定除这些角色以外的角色为唯一目标结算后，另一名角色须对相同目标使用一张【杀】，否则交给其一张牌；" ..
    "当其中一名角色成为除这些角色以外的角色使用【杀】的唯一目标时，另一名角色须交给目标角色一张【闪】，否则成为此【杀】的额外目标。",

  ["@mini_lvyuan"] = "虑远",
  ["#mini_lvyuan-discard"] = "虑远：弃置任意张牌并摸等量的牌",
  ["#mini_lvyuan_delay"] = "虑远",
  ["#mini_hezong-ask"] = "是否发动 合纵，选择两名角色",
  ["@mini_hezong-round"] = "合纵",
  ["#mini_hezong_delay"] = "合纵",
  ["#mini_hezong-use"] = "合纵：你需对 %dest 使用一张【杀】，否则交给 %src 一张牌",
  ["#mini_hezong-give_slash"] = "合纵：交给 %dest 一张牌",
  ["#mini_hezong-give"] = "合纵：你需交给 %dest 一张【闪】，否则成为此【杀】的额外目标",

  ["$mini_lvyuan1"] = "天下风云多变，皆在肃胸腹之中。",
  ["$mini_lvyuan2"] = "卓识远虑，胜乃可图。",
  ["$mini_hezong1"] = "合众弱以攻一强，此为破曹之策也。",
  ["$mini_hezong2"] = "孙刘分则为弱，合则无往不利。",
  ["~miniex__lusu"] = "孙刘永结一心，天下必归吾主，咳咳咳……",
}

local miniex__xuchu = General(extension, "miniex__xuchu", "wei", 4)

local huhou = fk.CreateViewAsSkill{
  name = "mini_huhou",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function (self, player, use)
    use.additionalDamage = (use.additionalDamage or 0) + 1
  end
}
local huhou_dmg = fk.CreateTriggerSkill{
  name = "#mini_huhou_delay",
  events = {fk.DamageCaused},
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and data.card and data.card.trueName == "duel" and (player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard).data[1].extra_data or {}).miniHuhou
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.damage = data.damage + 1
  end,

  refresh_events = {fk.CardResponding},
  can_refresh = function (self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, huhou.name) and data.responseToEvent and data.responseToEvent.card.trueName == "duel"
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local useEvent = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if useEvent and useEvent.data[1].card.trueName == "duel" then
      useEvent.data[1].extra_data = useEvent.data[1].extra_data or {}
      useEvent.data[1].extra_data.miniHuhou = true
    end
  end
}
huhou:addRelatedSkill(huhou_dmg)
local huhou_response = fk.CreateTriggerSkill{
  name = "#mini_huhou_response",
  anim_type = "offensive",
  mute = true,
  main_skill = huhou,
  events = {fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.card.trueName == "duel"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, huhou.name, "offensive")
    player:broadcastSkillInvoke(huhou.name)
    data.fixedResponseTimes = data.fixedResponseTimes or {}
    data.fixedResponseTimes["slash"] = 0
    data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
    table.insert(data.fixedAddTimesResponsors, (event == fk.TargetSpecified and data.to or data.from))
  end,
}
huhou:addRelatedSkill(huhou_response)
miniex__xuchu:addSkill(huhou)

local wuwei = fk.CreateTriggerSkill{
  name = "mini_wuwei",
  events = {fk.EventPhaseStart},
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and target == player and player.phase == Player.Finish
  end,
  on_cost = function (self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper), 1, 1, "#mini_wuwei-ask", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = self.cost_data
    room:setPlayerMark(player, "_mini_wuwei", to)
    target = room:getPlayerById(to)
    local records = target:getTableMark("@mini_wuwei")
    table.insertIfNeed(records, player.general)
    room:setPlayerMark(target, "@mini_wuwei", records)
  end
}
local wuwei_delay = fk.CreateTriggerSkill {
  name = "#mini_wuwei_delay",
  mute = true,
  events = {fk.TargetConfirmed, fk.CardUseFinished},
  can_trigger = function (self, event, target, player, data)
    if event == fk.TargetConfirmed then
      return target:getMark("@mini_wuwei") ~= 0 and player:getMark("_mini_wuwei") == target.id and
        target.hp <= player.hp and data.card.is_damage_card and not table.contains(data.card.skillNames, wuwei.name)
    else
      return target == player and (data.extra_data or {}).wuweiDelay
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.TargetConfirmed then
      player.room:notifySkillInvoked(player, wuwei.name, "defensive")
      player:broadcastSkillInvoke(wuwei.name)
      room:doIndicate(player.id, {target.id})
      table.insertIfNeed(data.nullifiedTargets, target.id)
      if player.dead or room:getPlayerById(data.from).dead then return end
      data.extra_data = data.extra_data or {}
      data.extra_data.wuweiDelay = true
      data.extra_data.wuweiDelayTable = data.extra_data.wuweiDelayTable or {}
      table.insert(data.extra_data.wuweiDelayTable, player.id)
    else
      local duelTable = data.extra_data.wuweiDelayTable
      room:sortPlayersByAction(duelTable)
      for _, pid in ipairs(duelTable) do
        if player.dead then return end
        local p = room:getPlayerById(pid)
        if not p.dead then
          local card = Fk:cloneCard("duel")
          card.skillName = wuwei.name
          room:useVirtualCard("duel", nil, player, p, wuwei.name, true)
        end
      end
    end
  end,

  refresh_events = {fk.TurnStart, fk.BuryVictim},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("_mini_wuwei") ~= 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    target = room:getPlayerById(player:getMark("_mini_wuwei"))
    local records = target:getTableMark("@mini_wuwei")
    table.removeOne(records, player.general)
    room:setPlayerMark(target, "@mini_wuwei", #records > 0 and records or 0)
    player.room:setPlayerMark(player, "_mini_wuwei", 0)
  end
}
wuwei:addRelatedSkill(wuwei_delay)
miniex__xuchu:addSkill(wuwei)
Fk:loadTranslationTable{
  ["miniex__xuchu"] = "极许褚",
  ["mini_huhou"] = "虎侯",
  [":mini_huhou"] = "①与你【决斗】的角色不能打出【杀】。②你可将一张装备牌当【杀】使用或打出，此【杀】或以此法响应的【决斗】伤害+1。",
  ["mini_wuwei"] = "武卫",
  [":mini_wuwei"] = "结束阶段，你可以选择一名角色，直到你的下回合开始，当其不以此法成为伤害牌的目标后，若其体力值不大于你，你令此牌对其无效，然后此牌结算结束后，使用者视为对你使用一张【决斗】。",

  ["#mini_huhou_response"] = "虎侯",
  ["#mini_huhou_delay"] = "虎侯",
  ["#mini_wuwei-ask"] = "是否发动对一名角色发动 武卫？",
  ["@mini_wuwei"] = "被武卫",
  ["#mini_wuwei_delay"] = "武卫",

  ["$mini_huhou1"] = "汝等闻虎啸之威，可知吾虎侯之名？",
  ["$mini_huhou2"] = "虎侯许褚在此，马贼安敢放肆！",
  ["$mini_wuwei1"] = "得丞相恩遇，褚必拼死以护！",
  ["$mini_wuwei2"] = "丞相避箭，吾来断后！",
  ["~miniex__xuchu"] = "丞相，丞相！呃啊……",
}

local miniex__xunyu = General(extension, "miniex__xunyu", "wei", 3)
local wangzuo = fk.CreateTriggerSkill {
  name = "mini_wangzuo",
  events = {fk.EventPhaseChanging},
  can_trigger = function (self, event, target, player, data)
    return player == target and player:hasSkill(self) and data.to > Player.Judge and data.to < Player.Finish and player:usedSkillTimes(self.name) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      1, 1, "#mini_wangzuo-ask:::" .. U.ConvertPhse(data.to), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:getPlayerById(self.cost_data):gainAnExtraPhase(data.to)
    return true
  end,
}

local juxian = fk.CreateTriggerSkill{
  name = "mini_juxian",
  events = {fk.AfterCardsMove},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player.room.current ~= player then return false end
    local room = player.room
    local to_get = {}
    local move_event = room.logic:getCurrentEvent()
    local parent_event = move_event.parent
    if parent_event and (parent_event.event == GameEvent.UseCard or parent_event.event == GameEvent.RespondCard) then
      local parent_data = parent_event.data[1]
      if parent_data.from ~= player.id then
        local card_ids = room:getSubcardsByRule(parent_data.card)
        for _, move in ipairs(data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              local id = info.cardId
              if info.fromArea == Card.Processing and room:getCardArea(id) == Card.DiscardPile and
              table.contains(card_ids, id) then
                table.insertIfNeed(to_get, id)
              end
            end
          end
        end
      end
    else
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          local from = move.from
          if from and from ~= player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(to_get, info.cardId)
              end
            end
          end
        end
      end
    end
    if #to_get > 0 then
      self.cost_data = to_get
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local cards = self.cost_data
    player.room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, self.name)
  end,
}

local xianshi = fk.CreateTriggerSkill{
  name = "mini_xianshi",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cids = room:askForArrangeCards(player, self.name,
    {room:getNCards(3), player:getCardIds(Player.Hand), "pile_draw", "$Hand"}, "#mini_xianshi-exchange", true)
    U.swapCardsWithPile(player, cids[1], cids[2], self.name, "Top")
  end,
}

miniex__xunyu:addSkill(wangzuo)
miniex__xunyu:addSkill(juxian)
miniex__xunyu:addSkill(xianshi)

Fk:loadTranslationTable{
  ["miniex__xunyu"] = "极荀彧",
  ["mini_wangzuo"] = "王佐",
  [":mini_wangzuo"] = "每回合限一次，你可跳过摸牌阶段、出牌阶段或弃牌阶段，然后令一名其他角色执行一个对应的额外阶段。<br><font color='grey'>不要报告和此技能有关的，如与阶段、回合有关的bug。",
  ["mini_juxian"] = "举贤",
  [":mini_juxian"] = "你的回合内，当其他角色的牌因使用、打出或弃置而进入弃牌堆后，你获得之。",
  ["mini_xianshi"] = "先识",
  [":mini_xianshi"] = "一名角色的摸牌阶段开始时，你可观看牌堆顶的三张牌并用任意张手牌交换其中等量张牌。",

  ["#mini_wangzuo-ask"] = "你可以发动〖王佐〗，跳过 %arg，选择一名其他角色，令其执行 %arg",
  ["#mini_xianshi-exchange"] = "先识：观看牌堆顶的三张牌并用任意张手牌交换",
}

local miniex__zhenji = General(extension, "miniex__zhenji", "wei", 3, 3, General.Female)
local shenfu = fk.CreateTriggerSkill{
  name = "mini_shenfu",
  events = {fk.Damaged, fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and (event == fk.Damaged or (target == player and player.phase == Player.Start and player:getMark("@mini_shenfu_luoshen") > 0))
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.Damaged then
      return true
    else
      return player.room:askForSkillInvoke(player, self.name, data, "#mini_shenfu-invoke:::" .. player:getMark("@mini_shenfu_luoshen"))
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:addPlayerMark(player, "@mini_shenfu_luoshen", data.damage)
    else
      local num = player:getMark("@mini_shenfu_luoshen")
      room:setPlayerMark(player, "@mini_shenfu_luoshen", 0)
      local cards = room:getNCards(num)
      room:moveCards{
        ids = cards,
        toArea = Card.Processing,
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
        proposer = player.id,
      }
      for _, id in ipairs(cards) do
        local card = Fk:getCardById(id)
        if card.color == Card.Black and room:getCardArea(id) == Card.Processing and U.canUseCard(room, player, card) then
          local use = U.askForUseRealCard(room, player, {id}, ".", self.name, "#mini_shenfu-use:::" .. card:toLogString(), {expand_pile = {id}, extra_use = true}, true)
          if use then
            room:useCard(use)
          end
        end
      end
      room:cleanProcessingArea(cards, self.name)
    end
  end
}
local siyuan = fk.CreateTriggerSkill{
  name = "mini_siyuan",
  events = {fk.Damaged},
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from
  end,
  on_cost = function (self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      1, 1, "#mini_siyuan-invoke:" .. data.from.id, self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    room:damage{
      from = data.from,
      to = to,
      damage = 1,
      skillName = self.name,
      isVirtualDMG = true,
    }
  end
}
miniex__zhenji:addSkill(shenfu)
miniex__zhenji:addSkill(siyuan)
Fk:loadTranslationTable{
  ["miniex__zhenji"] = "极甄姬",
  ["mini_shenfu"] = "神赋",
  [":mini_shenfu"] = "①当一名角色受到伤害后，你获得X枚“洛神”（X为伤害值）。②准备阶段，你可弃所有“洛神”，亮出牌堆顶等量张牌，然后可依次使用其中的黑色牌。",
  ["mini_siyuan"] = "思怨",
  [":mini_siyuan"] = "当你受到伤害后，你可选择一名其他角色，令伤害来源视为对其造成过1点伤害。",

  ["@mini_shenfu_luoshen"] = "洛神",
  ["#mini_shenfu-invoke"] = "你可以发动〖神赋〗，弃所有“洛神”，亮出牌堆顶 %arg 张牌，然后可依次使用其中的黑色牌",
  ["#mini_shenfu-use"] = "神赋：你可以使用 %arg",
  ["#mini_siyuan-invoke"] = "你可以发动〖思怨〗，选择一名其他角色，令 %src 视为对其造成过1点伤害",
}

local miniex__sunce = General(extension, "miniex__sunce", "wu", 4)
local taoni = fk.CreateTriggerSkill{
  name = "mini_taoni",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and player.hp > 0
  end,
  on_cost = function (self, event, target, player, data)
    local choices = {}
    for i = 1, player.hp do
      table.insert(choices, tostring(i))
    end
    table.insert(choices, "Cancel")
    local choice = player.room:askForChoice(player, choices, self.name, "#mini_taoni-invoke")
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local num = tonumber(self.cost_data) ---@type integer
    local room = player.room
    room:loseHp(player, num, self.name)
    if player.dead then return end
    room:drawCards(player, num, self.name)
    if player.dead then return end
    local targets = table.map(table.filter(room:getOtherPlayers(player, false), function(p) return p:getMark("@@mini_taoni") == 0 end), Util.IdMapper)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(player, targets, 1, num, "#mini_taoni-choose:::" .. num, self.name, false)
      table.forEach(tos, function(pid) room:addPlayerMark(room:getPlayerById(pid), "@@mini_taoni", 1) end)
    end
    room:setPlayerMark(player, "_mini_taoni-turn", 1)
  end
}
local taoni_maxcards = fk.CreateMaxCardsSkill{
  name = "#mini_taoni_maxcards",
  fixed_func = function(self, player)
    if player:getMark("_mini_taoni-turn") ~= 0 then
      return player.maxHp
    end
  end
}
taoni:addRelatedSkill(taoni_maxcards)

local pingjiang = fk.CreateActiveSkill{
  name = "mini_pingjiang",
  anim_type = "offensive",
  prompt = "#mini_pingjiang-active",
  can_use = function (self, player, card, extra_data)
    return U.canUseCard(Fk:currentRoom(), player, Fk:cloneCard("duel")) and player:getMark("@@mini_pingjiang_invalid-turn") == 0
  end,
  target_num = 1,
  target_filter = function (self, to_select)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if target:getMark("@@mini_taoni") > 0 then
      local card = Fk:cloneCard("duel")
      card.skillName = self.name
      return U.canUseCardTo(Fk:currentRoom(), Self, target, card)
    end
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local use = room:useVirtualCard("duel", nil, player, target, self.name, true)
    if use.damageDealt then
      if use.damageDealt[target.id] then
        room:setPlayerMark(target, "@@mini_taoni", 0)
        room:addPlayerMark(player, "@mini_pingjiang-turn")
      end
      if use.damageDealt[player.id] then
        room:setPlayerMark(player, "@@mini_pingjiang_invalid-turn", 1)
        room:setPlayerMark(player, "@mini_pingjiang-turn", 0)
      end
    end
  end,
}
local pingjiang_buff = fk.CreateTriggerSkill{
  name = "#mini_pingjiang_buff",
  anim_type = "offensive",
  events = {fk.TargetSpecified, fk.TargetConfirmed, fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if player:getMark("@mini_pingjiang-turn") == 0 or not data.card or data.card.trueName ~= "duel" then return end
    if event == fk.TargetSpecified then
      return target == player
    elseif event == fk.TargetConfirmed then
      return data.to == player.id
    else
      return target == player and player.room.logic:damageByCardEffect()
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local num = player:getMark("@mini_pingjiang-turn")
    if event ~= fk.DamageCaused then
      data.fixedResponseTimes = data.fixedResponseTimes or {}
      data.fixedResponseTimes["slash"] = (data.fixedResponseTimes["slash"] or 1) + 1
      data.fixedAddTimesResponsors = data.fixedAddTimesResponsors or {}
      table.insert(data.fixedAddTimesResponsors, (event == fk.TargetSpecified and data.to or data.from))
    else
      data.damage = data.damage + num
    end
  end,
}
pingjiang:addRelatedSkill(pingjiang_buff)

local dingye = fk.CreateTriggerSkill{
  name = "mini_dingye",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and player.phase == Player.Finish and player:isWounded()) then return end
    local targets = {}
    player.room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      table.insertIfNeed(targets, damage.to.id)
      return false
    end)
    if #targets > 0 then
      self.cost_data = #targets
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local num = self.cost_data
    player.room:recover{
      from = player,
      who = player,
      num = num,
      reason = self.name
    }
  end
}

miniex__sunce:addSkill(taoni)
miniex__sunce:addSkill(pingjiang)
miniex__sunce:addSkill(dingye)

Fk:loadTranslationTable{
  ["miniex__sunce"] = "极孙策",
  ["mini_taoni"] = "讨逆",
  [":mini_taoni"] = "出牌阶段开始时，你可失去任意点体力，摸X张牌，然后令至多X名没有“讨逆”的其他角色各获得1枚“讨逆”，然后此回合你的手牌上限为你的体力上限。（X为你以此法失去的体力值）",
  ["mini_pingjiang"] = "平江",
  [":mini_pingjiang"] = "出牌阶段，你可选择一名有“讨逆”的角色，视为对其使用【决斗】。若其受到了此【决斗】的伤害，" ..
  "弃其“讨逆”，你此回合使用的【决斗】目标角色需要打出【杀】的数量+1，对目标角色造成的伤害+1；若你受到了此【决斗】的伤害，此技能此回合失效。",
  ["mini_dingye"] = "鼎业",
  [":mini_dingye"] = "结束阶段，你回复X点体力。（X为此回合受到过伤害的角色数）",

  ["#mini_taoni-invoke"] = "你可以发动〖讨逆〗，失去任意点体力，摸等量张牌，然后令至多等量名角色获得“讨逆”",
  ["#mini_taoni-choose"] = "讨逆：选择至多%arg名角色获得“讨逆”",
  ["@@mini_taoni"] = "讨逆",
  ["#mini_pingjiang-active"] = "你可以发动〖平江〗，选择一名有“讨逆”的角色，视为对其使用【决斗】",
  ["@mini_pingjiang-turn"] = "平江",
  ["@@mini_pingjiang_invalid-turn"] = "平江失效",
  ["#mini_pingjiang_buff"] = "平江",
}

local sunquan = General(extension, "miniex__sunquan", "wu", 4)

local zongxi = fk.CreateActiveSkill{
  name = "mini__zongxi",
  anim_type = "control",
  min_card_num = 1,
  min_target_num = 2,
  prompt = "#mini__zongxi",
  card_filter = function(self, to_select, selected)
    return #selected < 4 and table.contains(Self.player_cards[Player.Hand], to_select)
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if #selected < #selected_cards and not to:isKongcheng() then
      return to_select == Self.id or Self:canPindian(to)
    end
  end,
  feasible = function(self, selected, selected_cards)
    return #selected > 1 and #selected == #selected_cards
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:sortPlayersByAction(effect.tos)
    local tos = table.map(effect.tos, Util.Id2PlayerMapper)
    local cards = effect.cards
    if #cards > 1 then
      cards = room:askForGuanxing(player, cards, nil, {0,0}, self.name, true).top
    end
    if #cards > 0 then
      room:moveCards({
        ids = table.reverse(cards),
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
      })
    end
    tos = table.filter(tos, function(p) return not p.dead and not p:isKongcheng() end)
    if #tos < 2 then return end
    local first = table.remove(tos, 1)
    local pd = U.jointPindian(first, tos, self.name)
    local winner = pd.winner
    if winner and not winner.dead then
      winner:drawCards(2, self.name)
    end
    if player.dead then return end
    local ids = {}
    if pd.from ~= player then
      local cid = pd.fromCard:getEffectiveId()
      if cid and room:getCardArea(cid) == Card.DiscardPile then
        table.insert(ids, cid)
      end
    end
    for _, pid in ipairs(effect.tos) do
      if pd.results[pid] and pd.results[pid].toCard then
        local cid = pd.results[pid].toCard:getEffectiveId()
        if cid and room:getCardArea(cid) == Card.DiscardPile then
          table.insert(ids, cid)
        end
      end
    end
    room:obtainCard(player, ids, true, fk.ReasonJustMove, player.id, self.name)
  end,
}
sunquan:addSkill(zongxi)

local luheng = fk.CreateTriggerSkill{
  name = "mini__luheng",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Finish
    and player:usedSkillTimes(zongxi.name, Player.HistoryTurn) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    room.logic:getEventsOfScope(U.JointPindianEvent, 1, function(e)
      local pd = e.data[1]
      table.insertIfNeed(targets, pd.from)
      table.insertTableIfNeed(targets, pd.tos)
    end, Player.HistoryTurn)
    targets = table.filter(targets, function(p) return not p.dead and p ~= player end)
    if #targets == 0 then return false end
    local maxNum = 0
    for _, p in ipairs(targets) do
      maxNum = math.max(maxNum, p:getHandcardNum())
    end
    targets = table.filter(targets, function(p) return p:getHandcardNum() == maxNum end)
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#mini__luheng-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:useVirtualCard("slash", nil, player, player.room:getPlayerById(self.cost_data.tos[1]), self.name, true)
  end,
}
sunquan:addSkill(luheng)

Fk:loadTranslationTable{
  ["miniex__sunquan"] = "极孙权",

  ["mini__zongxi"] = "纵阋",
  [":mini__zongxi"] = "出牌阶段限一次，你可将至多四张手牌以任意顺序置于牌堆顶，然后令X名角色进行<a href='zhuluPindian'>逐鹿</a>(X为你以此法置于牌堆的牌数)，赢的角色摸两张牌。“逐鹿”结束后，你获得其他角色的“逐鹿”牌。",
  ["#mini__zongxi"] = "纵阋：将至多4张手牌置于牌堆顶，令等量名角色共同拼点",

  ["mini__luheng"] = "戮衡",
  [":mini__luheng"] = "结束阶段，若你本回合发动过“纵阋”，你可选择一名本回合参与过“逐鹿”中手牌数最多的其他角色，视为对其使用一张【杀】。",
  ["#mini__luheng-choose"] = "戮衡：选择参与过“逐鹿”中手牌数最多的其他角色，视为对其使用一张【杀】",
}

local zhouyu = General(extension, "miniex__zhouyu", "wu", 3)

local miniex__yingrui = fk.CreateTriggerSkill{
  name = "miniex__yingrui",
  anim_type = "special",
  events = {fk.EventPhaseEnd, fk.Deathed},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player:getMark("@mini_moulue") >= 5 then return end
    if event == fk.EventPhaseEnd then
      return player == target and player.phase == Player.Draw
    else
      return data.damage and data.damage.from == player
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    handleMoulue(player.room, player, 4)
  end,
}
zhouyu:addSkill(miniex__yingrui)

local miniex__fenli = fk.CreateActiveSkill{
  name = "miniex__fenli",
  anim_type = "control",
  card_num = 0,
  min_target_num = 1,
  prompt = "#miniex__fenli",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getMark("@mini_moulue") > 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    local to = Fk:currentRoom():getPlayerById(to_select)
    if to:isNude() then return false end
    if #selected == 0 then
      return true
    else
      local first = Fk:currentRoom():getPlayerById(selected[1])
      return to:getNextAlive() == first or first:getNextAlive() == to
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    handleMoulue(room, player, -2)
    local tos = effect.tos
    room:sortPlayersByAction(tos)
    tos = table.map(tos, Util.Id2PlayerMapper)
    local colors = {}
    for _, to in ipairs(tos) do
      if not to:isNude() then
        local cid = room:askForCardChosen(player, to, "he", self.name)
        table.insertIfNeed(colors, Fk:getCardById(cid).color)
        room:throwCard(cid, self.name, to, player)
      end
    end
    if player:getMark("@mini_moulue") > 1 and #colors == 1 and room:askForSkillInvoke(player, self.name, nil,
    "#miniex__fenli-damage") then
      handleMoulue(room, player, -2)
      for _, to in ipairs(tos) do
        if not to.dead then
          room:doIndicate(player.id, {to.id})
          room:damage { from = player, to = to, damage = 1, skillName = self.name, damageType = fk.FireDamage }
        end
      end
    end
  end,
}
zhouyu:addSkill(miniex__fenli)

local miniex__qugu = fk.CreateTriggerSkill{
  name = "miniex__qugu",
  anim_type = "drawcard",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.from and data.from ~= player.id
    and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      local firstEvent = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        return table.contains(TargetGroup:getRealTargets(e.data[1].tos), player.id)
      end, Player.HistoryTurn)[1]
      local useParent = player.room.logic:getCurrentEvent()
      return useParent and firstEvent and useParent.id == firstEvent.id
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getCardsFromPileByRule(".|.|.|.|.|^"..data.card:getTypeString())
    if #ids > 0 then
      room:obtainCard(player, ids, true, fk.ReasonJustMove, player.id, self.name)
    end
  end,
}
--zhouyu:addSkill(miniex__qugu)

Fk:loadTranslationTable{
  ["miniex__zhouyu"] = "极周瑜",

  ["miniex__yingrui"] = "英锐",
  [":miniex__yingrui"] = "摸牌阶段结束时，或当你杀死一名角色后，你获得4点“谋略”值。",

  ["miniex__fenli"] = "焚离",
  [":miniex__fenli"] = "出牌阶段限一次，你可以消耗2点“谋略”值，弃置至多两名座次相邻角色各一张牌，若这些牌颜色相同，你可以再消耗2点“谋略”值，对这些角色依次造成1点火焰伤害。",
  ["#miniex__fenli"] = "焚离：消耗2点“谋略”值，弃置至多两名座次相邻角色各一张牌",
  ["#miniex__fenli-damage"] = "焚离：可以消耗2点“谋略”值，对其各造成1点火焰伤害",

  ["miniex__qugu"] = "曲顾",
  [":miniex__qugu"] = "每回合你首次成为其他角色使用牌的目标后，你可以从牌堆中获得一张与此牌类别不同的牌。",
}

local miniex__caiwenji = General(extension, "miniex__caiwenji", "qun", 3, 3, General.Female)
local mini_beijia = fk.CreateViewAsSkill{
  name = "mini_beijia",
  anim_type = "control",
  card_num = 1,
  prompt = function(self)
    local number = Self:getMark("@mini_beijia")
    if Self:getSwitchSkillState(self.name, false) == fk.SwitchYang then
      return "#mini_beijia-level:::" .. number
    else
      return "#mini_beijia-oblique:::" .. number
    end
  end,
  interaction = function()
    local all_names = U.getAllCardNames(Self:getSwitchSkillState("mini_beijia", false) == fk.SwitchYang and "t" or "b")
    local names = U.getViewAsCardNames(Self, "mini_beijia", all_names)
    if #names > 0 then
      return U.CardNameBox { choices = names, all_choices = all_names }
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getMark("@mini_beijia") ~= 0
  end,
  enabled_at_response = function (self, player, response)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getMark("@mini_beijia") ~= 0 and not response
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local number = Self:getMark("@mini_beijia")
      if Self:getSwitchSkillState(self.name, false) == fk.SwitchYang then
        return Fk:getCardById(to_select).number > number
      else
        return Fk:getCardById(to_select).number < number
      end
    end
  end,
  view_as = function (self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end
}
local mini_beijia_record = fk.CreateTriggerSkill{
  name = "#mini_beijia_record",
  refresh_events = {fk.CardUsing, fk.EventAcquireSkill, fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    if target ~= player then return end
    if event == fk.CardUsing then return player:hasSkill("mini_beijia")
    else return data.name == "mini_beijia" end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventAcquireSkill then
      room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        if use and use.from == player.id then
          room:setPlayerMark(player, "@mini_beijia", math.max(use.card.number, 0))
          return true
        end
        return false
      end, 1)
    elseif event == fk.EventLoseSkill then
      room:setPlayerMark(player, "@mini_beijia", 0)
    else
      local last_num = player:getMark("@mini_beijia")
      if player.phase == Player.Play and last_num == data.card.number then
        changeRhyme(room, player, "mini_beijia", Player.HistoryPhase)
      end
      room:setPlayerMark(player, "@mini_beijia", math.max(data.card.number, 0))
    end
  end,
}
mini_beijia:addRelatedSkill(mini_beijia_record)

local mini_sifu = fk.CreateActiveSkill{
  name = "mini_sifu",
  prompt = "#mini_sifu-active",
  anim_type = "drawcard",
  target_num = 0,
  card_num = 0,
  card_filter = Util.FalseFunc,
  can_use = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local nums = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data[1]
      if use and use.from == player.id and use.card.number > 0 then
        table.insertIfNeed(nums, use.card.number)
      end
      return false
    end, Player.HistoryTurn)
    local _nums = table.concat(nums, ",")
    local cards = room:getCardsFromPileByRule(".|" .. _nums)
    table.insertTable(cards, room:getCardsFromPileByRule(".|^(" .. _nums .. ")"))
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, self.name)
    end
  end
}
miniex__caiwenji:addSkill(mini_beijia)
miniex__caiwenji:addSkill(mini_sifu)

Fk:loadTranslationTable{
  ["miniex__caiwenji"] = "极蔡文姬",
  ["mini_beijia"] = "悲笳",
  [":mini_beijia"] = "韵律技，每回合限一次，平：你可将一张点数大于X的牌当任意普通锦囊牌使用；仄：你可将一张点数小于X的牌当任意基本牌使用；" ..
    "转韵：出牌阶段，使用一张点数等于X的牌（X为你使用的上一张牌的点数）。<br>" ..
    "<font color='grey'>\"<b>韵律技</b>\"<br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
    "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_sifu"] = "思赋",
  [":mini_sifu"] = "出牌阶段限一次，你可从牌堆中随机获得你本回合使用过和未使用过的点数的牌各一张。",

  ["@mini_beijia"] = "悲笳",
  ["#mini_beijia-level"] = "悲笳（平）：你可将一张点数大于%arg的牌当任意普通锦囊牌使用",
  ["#mini_beijia-oblique"] = "悲笳（仄）：你可将一张点数小于%arg的牌当任意基本牌使用",
  ["#mini_sifu-active"] = "发动 思赋，从牌堆中随机获得你本回合使用过和未使用过的点数的牌各一张",
}

local guanyu = General(extension, "miniex__guanyu", "shu", 4)

local mini__yihan = fk.CreateActiveSkill{
  name = "mini__yihan",
  prompt = "#mini__yihan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  times = function(self)
    return 1 + Self:getMark("mini_strive_times-round") - Self:usedSkillTimes(self.name, Player.HistoryRound)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) < 1 + player:getMark("mini_strive_times-round")
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local useables = {}
    local useableTrues = {}
    local extra_data = {bypass_times = true}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type ~= Card.TypeEquip and not to:prohibitUse(card) and card.skill:canUse(to, card, extra_data) then
        table.insertIfNeed(useables, card.name)
        table.insertIfNeed(useableTrues, card.trueName)
      end
    end
    if #useables > 0 then
      local pattern = table.concat(useableTrues, ",") .. "|.|.|.|" .. table.concat(useables, ",")
      local equips = to:getCardIds("e")
      if #equips > 0 then
        pattern = pattern .. "|.|^(" .. table.concat(equips, ",") .. ")"
      end
      local use = room:askForUseCard(to, self.name, pattern, "#mini__yihan", true, extra_data)
      if use then
        use.extraUse = true
        room:useCard(use)
        return
      end
    end
    room:useVirtualCard("slash", nil, player, to, self.name, true)
  end,
}

local MiniStriveSkillRecord = fk.CreateTriggerSkill{
  name = "#mini_strive_reocrd",
  refresh_events = {fk.Damage, fk.Damaged},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("mini_strive_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini_strive_times-round", 1)
  end,
}
mini__yihan:addRelatedSkill(MiniStriveSkillRecord)

guanyu:addSkill(mini__yihan)

local mini__wuwei = fk.CreateActiveSkill{
  name = "mini__wuwei",
  prompt = function (self)
    return "#mini__wuwei:::"..(Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1)
  end,
  anim_type = "offensive",
  target_num = 1,
  can_use = function(self, player)
    return true
  end,
  card_filter = function (self, to_select, selected)
    local num = Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1
    return #selected < num and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, cards)
    local num = Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1
    if #cards == num then
      return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isNude()
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local myNum = 0
    for _, id in ipairs(effect.cards) do
      myNum = myNum + Fk:getCardById(id).number
    end
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead then return end
    local cardNum = #effect.cards
    local to = room:getPlayerById(effect.tos[1])
    local toNum, toCards = 0, to:getCardIds("he")
    if #toCards > cardNum then
      toCards = room:askForCardsChosen(player, to, cardNum, cardNum, "he", self.name)
    end
    for _, id in ipairs(toCards) do
      if Fk:getCardById(id).type == Card.TypeEquip then
        toNum = toNum + Fk:getCardById(id).number
      end
    end
    room:throwCard(toCards, self.name, to, player)
    if not to.dead and myNum <= toNum then
      room:damage { from = player, to = to, damage = 1, skillName = self.name, damageType = fk.ThunderDamage }
    end
  end,
}
guanyu:addSkill(mini__wuwei)

Fk:loadTranslationTable{
  ["miniex__guanyu"] = "极关羽",

  ["mini__yihan"] = "翊汉",
  [":mini__yihan"] = "<a href='MiniStriveSkill'>奋武技</a>，出牌阶段，你可令一名其他角色选择一项：1、使用一张非装备牌；2、令你视为对其使用一张无次数限制的【杀】。",
  ["#mini__yihan"] = "翊汉：令一名其他角色选择使用非装备牌，否则被你使用【杀】",
  ["#mini__yihan-use"] = "翊汉：你需使用一张非装备牌，否则被【杀】！",
  ["MiniStriveSkill"] = "奋武技，每轮使用次数为（本轮你造成和受到的伤害值）+1，且至多为5。",

  ["mini__wuwei"] = "武威",
  [":mini__wuwei"] = "出牌阶段，你可以弃置X+1牌(X为此阶段“武威”的发动次数)，然后弃置一名角色等量张牌。若你因此弃置的牌点数之和不大于其被弃置的装备牌点数之和，你对其造成1点雷电伤害。",
  ["#mini__wuwei"] = "武威：弃置 %arg 张牌并弃置一名角色等量张牌，然后可能对其造成伤害",
}

return extension
