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

Fk:loadTranslationTable{
  ["rhyme_skill"] = "<b>韵律技：</b><br>一种特殊的技能，分为“平”和“仄”两种状态。游戏开始时，韵律技处于“平”状态；满足“转韵”条件后，"..
  "韵律技会转换到另一个状态，且重置技能发动次数。",
  ["mini_moulue"] = "<b>谋略值：</b><br>谋略值上限为5，有谋略值的角色拥有技能<a href=':mini_miaoji'>〖妙计〗</a>。",
  ["zhuluPindian"] = "<b>逐鹿：</b><br>即“共同拼点”，所有目标角色一起拼点，至多有一个胜者，点数最大者有多人时视为无胜者。",
  ["MiniStriveSkill"] = "<b>奋武技：</b><br>每轮使用次数为（本轮你造成和受到的伤害值）+1，且至多为5。",
}

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
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    if player:getSwitchSkillState("mini_xiangzhi", false) == fk.SwitchYang then
      player:drawCards(1, self.name)
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if table.contains(p:getTableMark("@@mini_xiangzhi"), player.id) and p:isAlive() then
          room:doIndicate(player.id, {p.id})
          p:drawCards(1, self.name)
          room:removeTableMark(p, "@@mini_xiangzhi", player.id)
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
        if table.contains(p:getTableMark("@@mini_xiangzhi"), player.id) and p:isAlive() then
          room:doIndicate(player.id, {p.id})
          if p:isWounded() then
            room:recover({
              who = p,
              num = 1,
              recoverBy = player,
              skillName = self.name
            })
          end
          room:removeTableMark(p, "@@mini_xiangzhi", player.id)
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
      room:removeTableMark(p, "@@mini_xiangzhi", player.id)
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
  [":mini_xiangzhi"] = "<a href='rhyme_skill'>韵律技</a>，出牌阶段限一次，平：你摸一张牌；仄：你回复1点体力。<br>转韵：你发动〖节烈〗后。",
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
  [":mini_tongxin"] = "<a href='rhyme_skill'>韵律技</a>，出牌阶段限一次，平：你可以令一名其他角色交给你一张手牌，然后若其手牌数不大于你，"..
  "其摸一张牌；仄：你可以交给一名其他角色一张手牌，然后若其手牌数不小于你，你对其造成1点伤害。<br>转韵：出牌阶段，使用本回合未使用过的类型的牌。",
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
  interaction = function(self, player)
    local names = {}
      local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
      if ((Fk.currentResponsePattern == nil and card.skill:canUse(Self, card) and not Self:prohibitUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        names = {Self:getMark("mini_dingce-turn")}
      end
    if #names == 0 then return end
    return U.CardNameBox {choices = names}
  end,
  handly_pile = true,
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
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and player:getMark("mini_dingce-turn") ~= 0 and
      player:getMark("@mini_moulue") > 0 and
      #U.getViewAsCardNames(player, self.name, {"mini_dingce-turn"}) > 0
  end,
  enabled_at_response = function(self, player, response)
    if response or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or
      player:getMark("mini_dingce-turn") == 0 or (player:isNude() and #player:getHandlyIds() == 0) or
      player:getMark("@mini_moulue") < 1 then return false end
    local card = Fk:cloneCard(player:getMark("mini_dingce-turn"))
    return #U.getViewAsCardNames(player, self.name, {"mini_dingce-turn"}) > 0
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
  prompt = function (self)
    local all_names = {["dismantlement"] = 1, ["nullification"] = 3, ["ex_nihilo"] = 3}
    return "#mini_miaoji:::"..self.interaction.data..":"..all_names[self.interaction.data]
  end,
  interaction = function(self, player)
    local names = {}
    if player:getMark("@mini_moulue") > 2 then
      names = {"dismantlement", "nullification", "ex_nihilo"}
    elseif player:getMark("@mini_moulue") > 0 then
      names = {"dismantlement"}
    end
    names = U.getViewAsCardNames(player, self.name, names)
    return U.CardNameBox { choices = names, all_choices = {"dismantlement", "nullification", "ex_nihilo"} }
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
    local names = {}
    if player:getMark("@mini_moulue") > 2 then
      names = {"dismantlement", "nullification", "ex_nihilo"}
    elseif player:getMark("@mini_moulue") > 0 then
      names = {"dismantlement"}
    end
    return #U.getViewAsCardNames(player, self.name, names) > 0
  end,
}
guojia:addSkill(mini_suanlve)
mini_dingce:addRelatedSkill(mini_dingce_record)
guojia:addSkill(mini_dingce)
guojia:addRelatedSkill(mini_miaoji)
Fk:loadTranslationTable{
  ["miniex__guojia"] = "极郭嘉",
  ["mini_suanlve"] = "算略",
  [":mini_suanlve"] = "游戏开始时，你获得3点<a href='mini_moulue'>谋略值</a>。每个回合结束时，你获得X点谋略值（X为你本回合使用牌的类别数）。",
  ["mini_dingce"] = "定策",
  [":mini_dingce"] = "每回合限一次，你可以消耗1点谋略值，将一张牌当你本回合使用的上一张基本牌或普通锦囊牌使用。",
  ["mini_miaoji"] = "妙计",
  [":mini_miaoji"] = "每回合限一次，你可以消耗1~3点谋略值，视为使用对应的牌：1.【过河拆桥】；3.【无懈可击】或【无中生有】。",
  ["@mini_moulue"] = "谋略值",
  ["#mini_miaoji"] = "妙计：消耗%arg2点谋略值，视为使用【%arg】",

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
    for _, p in ipairs(room:getOtherPlayers(player, false)) do
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
  [":mini_sangu"] = "锁定技，每当有三张牌指定你为目标后，你获得3点<a href='mini_moulue'>谋略值</a>，然后你观看牌堆顶的三张牌并将这些牌"..
  "置于牌堆顶或牌堆底。",
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
      room:addTableMark(player, "_mini_miaobi_used-turn", data.card.trueName)
      local to = room:getPlayerById(self.cost_data)
      to:addToPile("mini_miaobi_penmanship", data.card, true, self.name)
      if table.contains(to:getPile("mini_miaobi_penmanship"), data.card.id) then
        local record = to:getTableMark("_mini_miaobi")
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
                  (card.skill:modTargetFilter(player.id, {}, from, card, false)) then
                local tos = { {player.id} }
                if card.skill:getMinTargetNum() == 2 then
                  local targets = table.filter(room.alive_players, function (p)
                    return player ~= p and card.skill:targetFilter(p.id, {player.id}, {}, card, nil, from)
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
    local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
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
      room:askForUseRealCard(player, ids, "mini_duoquan", "#mini_duoquan-use", {
        bypass_times = true,
        extraUse = true,
        expand_pile = ids,
      })
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
        return winner:canUseTo(card, p, { bypass_times = true, bypass_distances = true })
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
      room:addTableMarkIfNeed(p, "@mini_hezong-round", room:getPlayerById(targets[3-i]).general)
      room:addTableMarkIfNeed(p, "_mini_hezong-round", targets[3-i])
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
    room:addTableMarkIfNeed(target, "@mini_wuwei", player.general)
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
    player:skip(data.to)
    player.room:getPlayerById(self.cost_data):gainAnExtraPhase(data.to)
  end,
}

local juxian = fk.CreateTriggerSkill{
  name = "mini_juxian",
  events = {fk.AfterCardsMove},
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player:getMark("mini_juxian-turn") > 2 or player.room.current ~= player then return false end
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
    local room = player.room
    local cards = self.cost_data
    local x = player:getMark("mini_juxian-turn")
    if x >= 3 then return false end
    if #cards + x > 3 then
      cards = table.random(cards, 3-x)
    end
    room:addPlayerMark(player, "mini_juxian-turn", #cards)
    room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, self.name)
  end,
}

local xianshi = fk.CreateTriggerSkill{
  name = "mini_xianshi",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Draw and player:usedSkillTimes(self.name, Player.HistoryRound) == 0
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
  [":mini_wangzuo"] = "每回合限一次，你可跳过摸牌阶段、出牌阶段或弃牌阶段，然后令一名其他角色执行一个对应的额外阶段。<br><font color='red'><small>不要报告和此技能有关的，如与阶段、回合有关的bug。</small></font>",
  ["mini_juxian"] = "举贤",
  [":mini_juxian"] = "你的回合内，当其他角色的牌因使用、打出或弃置而进入弃牌堆后，你获得之（至多为3）。",
  ["mini_xianshi"] = "先识",
  [":mini_xianshi"] = "每轮限一次，一名角色的摸牌阶段开始时，你可观看牌堆顶的三张牌并用任意张手牌交换其中等量张牌。",

  ["#mini_wangzuo-ask"] = "你可以发动〖王佐〗，跳过 %arg，选择一名其他角色，令其执行 %arg",
  ["#mini_xianshi-exchange"] = "先识：观看牌堆顶的三张牌并用任意张手牌交换",

  ["$mini_wangzuo1"] = "扶汉忠节守，佐王定策成。",
  ["$mini_wangzuo2"] = "平乱锄奸，以匡社稷。",
  ["$mini_juxian1"] = "遍推贤能，以襄明公大业。",
  ["$mini_juxian2"] = "天下贤才之至，皆系于明公。",
  ["$mini_xianshi1"] = "见识通达，以全乱世之机。",
  ["$mini_xianshi2"] = "储先谋后，万事皆成。",
  ["~miniex__xunyu"] = "初旨可共图，殊途难同归。",
}

local miniex__zhenji = General(extension, "miniex__zhenji", "wei", 3, 3, General.Female)
local shenfu = fk.CreateTriggerSkill{
  name = "mini_shenfu",
  events = {fk.Damaged, fk.EventPhaseStart},
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Damaged then
        return player:getMark("@mini_shenfu_luoshen") < 6
      elseif event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and player:getMark("@mini_shenfu_luoshen") > 0
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:addPlayerMark(player, "@mini_shenfu_luoshen", math.min(data.damage, 6 - player:getMark("@mini_shenfu_luoshen")))
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
      local choice = room:askForChoice(player, {"mini_shenfu_black", "mini_shenfu_red"}, self.name)
      if choice == "mini_shenfu_black" then
        for _, id in ipairs(cards) do
          local card = Fk:getCardById(id)
          if card.color == Card.Black and room:getCardArea(id) == Card.Processing and U.canUseCard(room, player, card) then
            local use = room:askForUseRealCard(player, {id}, self.name, "#mini_shenfu-use:::"..card:toLogString(),
            {
              bypass_times = true,
              expand_pile = {id},
              extra_use = true,
            }, true)
            if use then
              room:useCard(use)
            end
          end
        end
      else
        local red = table.filter(cards ,function (id)
          return Fk:getCardById(id).color == Card.Red
        end)
        if #red > 0 then
          room:obtainCard(player, red, true, fk.ReasonJustMove, player.id, self.name)
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
  [":mini_shenfu"] = "①当一名角色受到1点伤害后，你获得1枚“洛神”标记，上限为6。结束阶段，你弃置所有“洛神”标记，亮出牌堆顶等量张牌，"..
  "然后选择一项：1.可以依次使用其中的黑色牌；2.获得其中的红色牌。",
  ["mini_siyuan"] = "思怨",
  [":mini_siyuan"] = "当你受到伤害后，你可以选择一名其他角色，令伤害来源视为对其造成过1点伤害。",

  ["@mini_shenfu_luoshen"] = "洛神",
  ["mini_shenfu_black"] = "依次使用其中的黑色牌",
  ["mini_shenfu_red"] = "获得其中的红色牌",
  ["#mini_shenfu-use"] = "神赋：你可以使用 %arg",
  ["#mini_siyuan-invoke"] = "你可以发动〖思怨〗，选择一名其他角色，令 %src 视为对其造成过1点伤害",

  ["$mini_shenfu1"] = "往事尽于此赋，来者惟于清零。",
  ["$mini_shenfu2"] = "我身飘零于尘，此心空寄洛水。",
  ["$mini_siyuan1"] = "陛下既不怜我，何不赦我归去。",
  ["$mini_siyuan2"] = "后宫三千佳丽，无我一人又何妨",
  ["~miniex__zhenji"] = "以发覆面，何等凄凉……",
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
    return U.canUseCard(Fk:currentRoom(), player, Fk:cloneCard("duel"))
  end,
  target_num = 1,
  target_filter = function (self, to_select)
    local target = Fk:currentRoom():getPlayerById(to_select)
    if target:getMark("@@mini_taoni") > 0 then
      local card = Fk:cloneCard("duel")
      card.skillName = self.name
      return Self:canUseTo(card, target, { bypass_times = true, bypass_distances = true })
    end
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(target, "@@mini_taoni", 0)
    local use = room:useVirtualCard("duel", nil, player, target, self.name, true)
    if use.damageDealt then
      if use.damageDealt[target.id] then
        room:addPlayerMark(player, "@mini_pingjiang-turn")
      else
        room:invalidateSkill(player, self.name, "-turn")
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
      data.fixedResponseTimes["slash"] = (data.fixedResponseTimes["slash"] or 1) + num
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
    table.removeOne(targets, player.id)
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
  [":mini_taoni"] = "出牌阶段开始时，你可失去任意点体力，摸等量的牌，"..
  "然后令至多X名没有“讨逆”的其他角色各获得1枚“讨逆”（X为你以此法失去的体力值），此回合你的手牌上限为你的体力上限。",
  ["mini_pingjiang"] = "平江",
  [":mini_pingjiang"] = "出牌阶段，你可选择一名有“讨逆”的角色，弃其“讨逆”，视为对其使用【决斗】。" ..
  "若其受到了此【决斗】的伤害，你此回合使用的【决斗】目标角色需要打出【杀】的数量+1，对目标角色造成的伤害+1；否则此技能此回合失效。",
  ["mini_dingye"] = "鼎业",
  [":mini_dingye"] = "结束阶段，你回复X点体力。（X为此回合受到过伤害的其他角色数）",

  ["#mini_taoni-invoke"] = "你可以发动〖讨逆〗，失去任意点体力，摸等量张牌，然后令至多等量名角色获得“讨逆”",
  ["#mini_taoni-choose"] = "讨逆：选择至多%arg名角色获得“讨逆”",
  ["@@mini_taoni"] = "讨逆",
  ["#mini_pingjiang-active"] = "你可以发动〖平江〗，选择一名有“讨逆”的角色，视为对其使用【决斗】",
  ["@mini_pingjiang-turn"] = "平江",
  ["#mini_pingjiang_buff"] = "平江",

  ["$mini_taoni1"] = "欲立万丈之基，先净门庭之度。",
  ["$mini_taoni2"] = "扫定四野，百姓自当归附。",
  ["$mini_pingjiang1"] = "一山难存二虎，东吴岂容二王？",
  ["$mini_pingjiang2"] = "九州东南，尽是孙家天下。",
  ["$mini_dingye1"] = "凭三江之固，以观天下成败！",
  ["$mini_dingye2"] = "吾志岂安于此，当在天下万方！",
  ["~miniex__sunce"] = "有众卿鼎力相辅，仲谋必成大事。",
}

local sunquan = General(extension, "miniex__sunquan", "wu", 4)

local zongxi = fk.CreateActiveSkill{
  name = "mini__zongxi",
  anim_type = "control",
  min_card_num = 1,
  min_target_num = 2,
  prompt = "#mini__zongxi",
  card_filter = function(self, to_select, selected)
    return #selected < 3 and table.contains(Self.player_cards[Player.Hand], to_select)
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
  [":mini__zongxi"] = "出牌阶段限一次，你可将至多三张牌以任意顺序置于牌堆顶，然后令X名角色进行<a href='zhuluPindian'>逐鹿</a>（X为你以此法置于牌堆的牌数），赢的角色摸两张牌。“逐鹿”结束后，你获得其他角色的“逐鹿”牌。",
  ["#mini__zongxi"] = "纵阋：将至多三张牌置于牌堆顶，令等量名角色共同拼点",

  ["mini__luheng"] = "戮衡",
  [":mini__luheng"] = "结束阶段，若你本回合发动过“纵阋”，你可选择一名本回合参与过“逐鹿”中手牌数最多的其他角色，视为对其使用一张【杀】。",
  ["#mini__luheng-choose"] = "戮衡：选择参与过“逐鹿”中手牌数最多的其他角色，视为对其使用一张【杀】",

  ["$mini__luheng1"] = "放肆！汝可知欺君之罪？",
  ["$mini__luheng2"] = "卿欲试朕之龙威乎？",
  ["$mini__zongxi1"] = "承位者当以才德为先，无需遵长幼之序。",
  ["$mini__zongxi2"] = "太子当取诸子中之贤者，可稳一国之气运。",
  ["~miniex__sunquan"] = "余子碌碌，竟无承位之人。",
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
zhouyu:addRelatedSkill("mini_miaoji")
Fk:loadTranslationTable{
  ["miniex__zhouyu"] = "极周瑜",

  ["miniex__yingrui"] = "英锐",
  [":miniex__yingrui"] = "摸牌阶段结束时，或当你杀死一名角色后，你获得4点<a href='mini_moulue'>谋略值</a>。",

  ["miniex__fenli"] = "焚离",
  [":miniex__fenli"] = "出牌阶段限一次，你可以消耗2点“谋略”值，弃置至多两名座次相邻角色各一张牌，若这些牌颜色相同，你可以再消耗2点“谋略”值，对这些角色依次造成1点火焰伤害。",
  ["#miniex__fenli"] = "焚离：消耗2点“谋略”值，弃置至多两名座次相邻角色各一张牌",
  ["#miniex__fenli-damage"] = "焚离：可以消耗2点“谋略”值，对其各造成1点火焰伤害",

  ["miniex__qugu"] = "曲顾",
  [":miniex__qugu"] = "每回合你首次成为其他角色使用牌的目标后，你可以从牌堆中获得一张与此牌类别不同的牌。",

  ["$miniex__yingrui1"] = "有吾筹谋，岂有败战之理？",
  ["$miniex__yingrui2"] = "坚铠精械，正为今日之战！",
  ["$miniex__fenli1"] = "东风催火，焚尽敌舟。",
  ["$miniex__fenli2"] = "江火若白日，百里腾烟云。",
  ["$miniex__qugu1"] = "妙手易有，佳音难得。",
  ["$miniex__qugu2"] = "曲有误处，难免回顾。",
  ["~miniex__zhouyu"] = "伯符，瑜来也……",
}

local miniex__caiwenji = General(extension, "miniex__caiwenji", "qun", 3, 3, General.Female)
local mini_beijia = fk.CreateViewAsSkill{
  name = "mini_beijia",
  anim_type = "control",
  card_num = 1,
  pattern = ".",
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
      return U.CardNameBox { choices = names, all_choices = all_names, default_choice = "AskForCardsChosen" }
    end
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and player:getMark("@mini_beijia") ~= 0
  end,
  enabled_at_response = function (self, player, response)
    if player:usedSkillTimes(self.name) == 0 and player:getMark("@mini_beijia") ~= 0 and not response then
      if player:getSwitchSkillState("mini_beijia", false) == fk.SwitchYang then
        return Exppattern:Parse(Fk.currentResponsePattern):matchExp(".|.|.|.|.|trick|.")
      else
        return Exppattern:Parse(Fk.currentResponsePattern):matchExp(".|.|.|.|.|basic|.")
      end
    end
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and Fk.all_card_types[self.interaction.data] ~= nil then
      local number = Self:getMark("@mini_beijia")
      if Self:getSwitchSkillState(self.name, false) == fk.SwitchYang then
        return Fk:getCardById(to_select).number > number
      else
        return Fk:getCardById(to_select).number < number
      end
    end
  end,
  view_as = function (self, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local c = Fk:cloneCard(self.interaction.data)
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
      local use = e.data[1]
      if use.from == player.id then
        room:setPlayerMark(player, "@mini_beijia", math.max(use.card.number, 0))
        return true
      end
    end, 1)
  end,
  on_lose = function (self, player, is_death)
    player.room:setPlayerMark(player, "@mini_beijia", 0)
  end,
}
local mini_beijia_record = fk.CreateTriggerSkill{
  name = "#mini_beijia_record",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(mini_beijia, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local last_num = player:getMark("@mini_beijia")
    if player.phase == Player.Play and last_num == data.card.number then
      changeRhyme(room, player, "mini_beijia", Player.HistoryTurn)
    end
    room:setPlayerMark(player, "@mini_beijia", math.max(data.card.number, 0))
  end,
}
mini_beijia:addRelatedSkill(mini_beijia_record)

local mini_sifu = fk.CreateActiveSkill{
  name = "mini_sifu",
  prompt = "#mini_sifu-active",
  anim_type = "drawcard",
  interaction = function()
    local numbers = { {}, {} }
    local record = Self:getTableMark("mini_sifu_record-turn")
    for i = 1, 13, 1 do
      if table.contains(record, i) then
        table.insert(numbers[1], i)
      else
        table.insert(numbers[2], i)
      end
    end
    local area_names = { "mini_sifu_used", "mini_sifu_non_used" }

    if Self:getMark("mini_sifu_choice2-phase") > 0 then
      table.remove(numbers, 2)
      table.remove(area_names, 2)
    end

    if Self:getMark("mini_sifu_choice1-phase") > 0 then
      table.remove(numbers, 1)
      table.remove(area_names, 1)
    end

    return {
      type = "custom",
      qml_path = "packages/mini/qml/SiFuInteraction",
      numbers = numbers,
      area_names = area_names,
    }
  end,
  target_num = 0,
  card_num = 0,
  times = function(self)
    if Self.phase == Player.Play then
      local x = 0
      if Self:getMark("mini_sifu_choice1-phase") == 0 then
        x = x + 1
      end
      if Self:getMark("mini_sifu_choice2-phase") == 0 then
        x = x + 1
      end
      return x
    end
    return -1
  end,
  card_filter = Util.FalseFunc,
  can_use = function (self, player)
    return player:getMark("mini_sifu_choice1-phase") == 0 or player:getMark("mini_sifu_choice2-phase") == 0
  end,
  feasible = function(self)
    return tonumber(self.interaction.data)
  end,
  on_use = function (self, room, effect)
    local player = room:getPlayerById(effect.from)
    if table.contains(player:getTableMark("mini_sifu_record-turn"), tonumber(self.interaction.data)) then
      room:setPlayerMark(player, "mini_sifu_choice1-phase", 1)
    else
      room:setPlayerMark(player, "mini_sifu_choice2-phase", 1)
    end

    local cards = room:getCardsFromPileByRule(".|" .. self.interaction.data)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player.id, self.name)
    end
  end,

  on_acquire = function (self, player, is_start)
    local room = player.room
    if room.current ~= player then return end
    local turn = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
    if turn == nil then return end
    local nums = {}
    room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
      local use = e.data[1]
      if use.from == player.id then
        table.insertIfNeed(nums, use.card.number)
      end
    end, turn.id)
    if #nums > 0 then
      room:setPlayerMark(player, "mini_sifu_record-turn", nums)
    end
  end,
  on_lose = function (self, player, is_death)
    local room = player.room
    room:setPlayerMark(player, "mini_sifu_choice1-phase", 0)
    room:setPlayerMark(player, "mini_sifu_choice2-phase", 0)
  end,
}

local mini_sifu_record = fk.CreateTriggerSkill{
  name = "#mini_sifu_record",

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(mini_sifu, true) and
    player.room.current == player and player.phase ~= Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "mini_sifu_record-turn", data.card.number)
  end,
}
mini_sifu:addRelatedSkill(mini_sifu_record)

miniex__caiwenji:addSkill(mini_beijia)
miniex__caiwenji:addSkill(mini_sifu)

Fk:loadTranslationTable{
  ["miniex__caiwenji"] = "极蔡文姬",
  ["mini_beijia"] = "悲笳",
  [":mini_beijia"] = "<a href='rhyme_skill'>韵律技</a>，每回合限一次，平：你可以将一张点数大于X的牌当任意普通锦囊牌使用；仄："..
  "你可以将一张点数小于X的牌当任意基本牌使用。<br>转韵：出牌阶段，使用一张点数等于X的牌（X为你使用的上一张牌的点数）。",
  ["mini_sifu"] = "思赋",
  [":mini_sifu"] = "出牌阶段各限一次，你可以选择一个本回合你使用/未使用过的牌的点数，然后从牌堆里随机获得一张该点数的牌。",

  ["@mini_beijia"] = "悲笳",
  ["#mini_beijia-level"] = "悲笳（平）：你可将一张点数大于%arg的牌当任意普通锦囊牌使用",
  ["#mini_beijia-oblique"] = "悲笳（仄）：你可将一张点数小于%arg的牌当任意基本牌使用",
  ["#mini_sifu-active"] = "发动 思赋，从牌堆中随机获得一张指定点数的牌",
  ["mini_sifu_choice"] = "选择点数",
  ["mini_sifu_used"] = "已使用",
  ["mini_sifu_non_used"] = "未使用",

  ["$mini_beijia1"] = "干戈日寻兮道路危，民卒流亡兮共哀悲。",
  ["$mini_beijia2"] = "烟尘蔽野兮胡虏盛，志意乖兮节义亏。",
  ["$mini_sifu1"] = "云山万重兮归路遐，疾风千里兮扬尘沙。",
  ["$mini_sifu2"] = "无日无夜兮不思我乡土，禀气合生兮莫过我最苦。",
  ["~miniex__caiwenji"] = "怨兮欲问天，天苍苍兮上无缘……",
}

local guanyu = General(extension, "miniex__guanyu", "shu", 4)

local mini__yihan = fk.CreateActiveSkill{
  name = "mini__yihan",
  prompt = "#mini__yihan",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    local cid = room:askForCardChosen(player, to, "h", self.name)
    to:showCards({cid})
    local card = Fk:getCardById(cid)
    if room:askForSkillInvoke(to, self.name, nil, "#mini__yihan-ask::"..player.id..":"..card:toLogString()) then
      room:obtainCard(player, cid, true, fk.ReasonGive, to.id, self.name)
    else
      room:useVirtualCard("slash", nil, player, to, self.name, true)
    end
  end,
}
guanyu:addSkill(mini__yihan)

local mini__wuwei = fk.CreateActiveSkill{
  name = "mini__wuwei",
  prompt = function (self)
    return "#mini__wuwei:::"..(Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1)
  end,
  anim_type = "offensive",
  target_num = 1,
  times = function(self)
    return 1 + Self:getMark("mini_strive_times-round") - Self:usedSkillTimes(self.name, Player.HistoryRound)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) < (1 + player:getMark("mini_strive_times-round"))
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
      toNum = toNum + Fk:getCardById(id).number
    end
    room:throwCard(toCards, self.name, to, player)
    if not to.dead and myNum <= toNum then
      room:damage { from = player, to = to, damage = 1, skillName = self.name, damageType = fk.ThunderDamage }
    end
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
mini__wuwei:addRelatedSkill(MiniStriveSkillRecord)

guanyu:addSkill(mini__wuwei)

Fk:loadTranslationTable{
  ["miniex__guanyu"] = "极关羽",

  ["mini__yihan"] = "翊汉",
  [":mini__yihan"] = "出牌阶段限一次，你可以展示一名其他角色的一张手牌，然后令其选择一项：1.将此牌交给你；2.令你视为对其使用一张无次数限制的【杀】。",
  ["#mini__yihan"] = "翊汉：展示一名其他角色的一张手牌，其需交给你，否则被你使用【杀】",
  ["#mini__yihan-ask"] = "翊汉：点“确定”：将%arg交给%dest；“取消”：被他使用【杀】",

  ["mini__wuwei"] = "武威",
  [":mini__wuwei"] = "<a href='MiniStriveSkill'>奋武技</a>，出牌阶段，你可以弃置X+1张牌（X为此阶段本技能的发动次数），然后弃置一名角色等量张牌。若你弃置自己的牌点数之和不大于弃置其的牌点数之和，你对其造成1点雷电伤害。",
  ["#mini__wuwei"] = "武威：弃置 %arg 张牌并弃置一名角色等量张牌，然后可能对其造成伤害",

  ["$mini__yihan1"] = "大丈夫匡汉为任，岂耽于浮名。",
  ["$mini__yihan2"] = "助兄复汉，某义不容辞。",
  ["$mini__wuwei1"] = "三军既出，自怯敌之胆。",
  ["$mini__wuwei2"] = "来将何人？可知关某之名！",
  ["~miniex__guanyu"] = "大丈夫为忠为义，何惜死乎！",
}

local jiangwei = General(extension, "miniex__jiangwei", "shu", 4)
local gujin = fk.CreateTriggerSkill{
  name = "mini__gujin",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player:getMark("@mini_moulue") >= 5 then return end
    return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data[1]
      return use.from ~= player.id and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
    end, Player.HistoryTurn) == 0
  end,
  on_use = function(self, event, target, player, data)
    handleMoulue(player.room, player, 1)
  end,
}
local gujin_trigger = fk.CreateTriggerSkill{
  name = "#mini__gujin_trigger",
  main_skill = gujin,
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.CardEffectCancelledOut},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill("mini__gujin") and data.card.trueName == "slash" and
      data.to == player.id and player:getMark("@mini_moulue") < 5
  end,
  on_use = function(self, event, target, player, data)
    handleMoulue(player.room, player, 2)
  end,
}
gujin:addRelatedSkill(gujin_trigger)
jiangwei:addSkill(gujin)
jiangwei:addRelatedSkill("mini_miaoji")
Fk:loadTranslationTable{
  ["miniex__jiangwei"] = "极姜维",
}
Fk:loadTranslationTable{
  ["mini__gujin"] = "鼓进",
  [":mini__gujin"] = "锁定技，每名角色的回合结束时，若本回合你未成为过其他角色使用牌的目标，你获得1点<a href='mini_moulue'>谋略值</a>。"..
  "当你抵消其他角色对你使用的【杀】后，你获得2点<a href='mini_moulue'>谋略值</a>。",
  ["#mini__gujin_trigger"] = "鼓进",
}
local qumou = fk.CreateTriggerSkill{
  name = "mini__qumou",
  anim_type = "special",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"basic", "trick", "Cancel"}, self.name, "#mini__qumou-choice")
    if choice ~= "Cancel" then
      self.cost_data = {choice = choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local type = self.cost_data.choice
    room:addTableMarkIfNeed(player, "mini__qumou-turn", type)
    type = type == "basic" and "trick" or "basic"
    room:setPlayerMark(player, "@mini__qumou_"..type, 2)
  end,

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    if target == player then
      if data.card.type == Card.TypeBasic and player:getMark("@mini__qumou_basic") > 0 then
        return true
      elseif data.card:isCommonTrick() and player:getMark("@mini__qumou_trick") > 0 then
        return true
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
    data.extra_data = data.extra_data or {}
    data.extra_data.mini__qumou = true
    player.room:removePlayerMark(player, "@mini__qumou_"..data.card:getTypeString(), 1)
  end,
}
local qumou_trigger = fk.CreateTriggerSkill{
  name = "#mini__qumou_trigger",
  anim_type = "control",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and #player.room:getUseExtraTargets(data) > 0 and
      data.extra_data and data.extra_data.mini__qumou
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, room:getUseExtraTargets(data), 1, 1,
      "#mini__qumou_trigger-choose:::"..data.card:toLogString(), "mini__qumou", true, false)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("mini__qumou")
    local room = player.room
      table.insert(data.tos, self.cost_data.tos)
      room:sendLog{
        type = "#AddTargetsBySkill",
        from = player.id,
        to = self.cost_data.tos,
        arg = "mini__qumou",
        arg2 = data.card:toLogString()
      }
  end,
}
local qumou_targetmod = fk.CreateTargetModSkill{
  name = "#mini__qumou_targetmod",
  bypass_distances = function(self, player, skill, card)
    if card then
      if card.type == Card.TypeBasic and player:getMark("@mini__qumou_basic") > 0 then
        return true
      end
      if card:isCommonTrick() and player:getMark("@mini__qumou_trick") > 0 then
        return true
      end
    end
  end,
  bypass_times = function (self, player, skill, scope, card)
    if card then
      if card.type == Card.TypeBasic and player:getMark("@mini__qumou_basic") > 0 then
        return true
      end
      if card:isCommonTrick() and player:getMark("@mini__qumou_trick") > 0 then
        return true
      end
    end
  end,
}
local qumou_prohibit = fk.CreateProhibitSkill{
  name = "#mini__qumou_prohibit",
  prohibit_use = function(self, player, card)
    return table.contains(player:getTableMark("mini__qumou-turn"), card:getTypeString())
  end,
  prohibit_response = function (self, player, card)
    return table.contains(player:getTableMark("mini__qumou-turn"), card:getTypeString())
  end,
  prohibit_discard = function (self, player, card)
    return table.contains(player:getTableMark("mini__qumou-turn"), card:getTypeString())
  end,
}
qumou:addRelatedSkill(qumou_trigger)
qumou:addRelatedSkill(qumou_targetmod)
qumou:addRelatedSkill(qumou_prohibit)
jiangwei:addSkill(qumou)
Fk:loadTranslationTable{
  ["mini__qumou"] = "屈谋",
  [":mini__qumou"] = "出牌阶段开始时，你可以令你本回合无法使用、打出或弃置基本牌/锦囊牌。若如此做，你使用的下两张普通锦囊牌/基本牌无距离和"..
  "次数限制，且可以多选择一个目标。",
  ["#mini__qumou-choice"] = "屈谋：本回合无法使用、打出或弃置一种牌，你使用下两张另一种牌无距离次数限制且可以多选择一个目标",
  ["@mini__qumou_basic"] = "屈谋 基本牌",
  ["@mini__qumou_trick"] = "屈谋 锦囊牌",
  ["#mini__qumou_trigger"] = "屈谋",
  ["#mini__qumou_trigger-choose"] = "屈谋：你可以为此%arg额外指定一个目标",
}

local caozhi = General(extension, "miniex__caozhi", "wei", 3)
local caiyi = fk.CreateTriggerSkill{
  name = "mini__caiyi",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 or
      (player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryGame) == 0) then return end
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonUse then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and
            not table.find(player:getCardIds("h"), function (id)
              return Fk:getCardById(id).type == Fk:getCardById(info.cardId).type
            end) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.min(3, player:usedSkillTimes(self.name, Player.HistoryGame) - 1)
    local types = {}
    for _, id in ipairs(player:getCardIds("h")) do
      table.insertIfNeed(types, Fk:getCardById(id).type)
    end
    n = n + #types
    local cards = room:getNCards(n)
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonJustMove, self.name, nil, true, player.id)
    local red, black = {}, {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color == Card.Red then
        table.insert(red, id)
      elseif Fk:getCardById(id).color == Card.Black then
        table.insert(black, id)
      end
    end
    local choices = {}
    if #red > 0 then
      table.insert(choices, "red")
    end
    if #black > 0 then
      table.insert(choices, "black")
    end
    local choice = room:askForChoice(player, choices, self.name, "#mini__caiyi-choice")
    if choice == "red" then
      room:moveCardTo(red, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
    else
      room:moveCardTo(black, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
    end
    room:cleanProcessingArea(cards)
  end,
}
caozhi:addSkill(caiyi)
Fk:loadTranslationTable{
  ["miniex__caozhi"] = "极曹植",
}
Fk:loadTranslationTable{
  ["mini__caiyi"] = "才溢",
  [":mini__caiyi"] = "每回合限一次，当你因使用而失去一种类别的所有手牌后，你可以展示牌堆顶X张牌（X为你手牌的类别数），然后获得其中一种颜色的"..
  "所有牌。本局游戏你每发动一次此技能，以此法展示牌的数量额外+1（至多+3）。",
  ["#mini__caiyi-choice"] = "才溢：获得其中一种颜色的牌",
}
local yaoxiang = fk.CreateViewAsSkill{
  name = "mini__yaoxiang",
  anim_type = "support",
  pattern = "analeptic",
  prompt = "#mini__yaoxiang",
  card_filter = Util.FalseFunc,
  view_as = function(self)
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    return c
  end,
  before_use = function(self, player)
    local types = {"basic", "trick", "equip"}
    for _, id in ipairs(player:getCardIds("h")) do
      table.removeOne(types, Fk:getCardById(id):getTypeString())
    end
    if #types > 0 then
      local room = player.room
      local pattern = ".|.|.|.|.|"..table.concat(types, ",")
      local ids = room:getCardsFromPileByRule(pattern)
      if #ids > 0 then
        room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
      end
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function (self, player, response)
    return not response and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
}
local yaoxiang_trigger = fk.CreateTriggerSkill{
  name = "#mini__yaoxiang_trigger",
  anim_type = "special",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:usedSkillTimes("mini__yaoxiang", Player.HistoryTurn) > 0 and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"mini__yaoxiang_invalidate"}
    if player.faceup then
      table.insert(choices, 1, "turnOver")
    end
    local choice = room:askForChoice(player, choices, "mini__yaoxiang")
    if choice == "turnOver" then
      player:turnOver()
    else
      room:invalidateSkill(player, "mini__caiyi", "-round")
    end
  end,
}
yaoxiang:addRelatedSkill(yaoxiang_trigger)
caozhi:addSkill(yaoxiang)
Fk:loadTranslationTable{
  ["mini__yaoxiang"] = "遨想",
  [":mini__yaoxiang"] = "每回合限一次，你可以视为使用一张【酒】，并随机获得一张手牌中未拥有的类别的牌。若如此做，当前回合结束时，你选择一项："..
  "1.若你未翻面，将武将牌至背面；2.令〖才溢〗本轮失效。",
  ["#mini__yaoxiang"] = "遨想：视为使用【酒】并获得一张手牌中缺少的类别的牌",
  ["#mini__yaoxiang_trigger"] = "才溢",
  ["mini__yaoxiang_invalidate"] = "“才溢”本轮失效",
}

local liubei = General(extension, "miniex__liubei", "shu", 4)
local guizhi = fk.CreateTriggerSkill{
  name = "mini__guizhi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player), function (p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return player:canPindian(p)
    end)
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 4, "#mini__guizhi-choose", self.name)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      self.cost_data = {tos = tos}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = U.jointPindian(player, table.map(self.cost_data.tos, Util.Id2PlayerMapper), self.name)
    if pindian.winner and not pindian.winner.dead then
      local n = 0
      if pindian.fromCard then
        n = 1
      end
      for _, _ in pairs(pindian.results) do
        n = n + 1
      end
      n = n - 1
      if n > 0 then
        room:setPlayerMark(pindian.winner, "@mini__guizhi", math.max(n, pindian.winner:getMark("@mini__guizhi")))
      end
    end
    if not player.dead and not (pindian.winner and pindian.winner == player) and pindian.fromCard then
      local n, num = pindian.fromCard.number, 0
      for _, result in pairs(pindian.results) do
        if result.toCard and result.toCard.number > n then
          num = num + 1
        end
      end
      local cards = table.random(room.draw_pile, num)
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, false, player.id)
      end
    end
  end,
}
local guizhi_refresh = fk.CreateTriggerSkill{
  name = "#mini__guizhi_refresh",

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("@mini__guizhi") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@mini__guizhi-phase", player:getMark("@mini__guizhi"))
    room:setPlayerMark(player, "@mini__guizhi", 0)
  end,
}
local guizhi_refresh2 = fk.CreateTriggerSkill{
  name = "#mini__guizhi_refresh2",

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@mini__guizhi-phase") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__guizhi-phase", 1)
    data.extraUse = true
  end,
}
local guizhi_targetmod = fk.CreateTargetModSkill{
  name = "#mini__guizhi_targetmod",
  bypass_times = function (self, player, skill, scope, card, to)
    return card and player:getMark("@mini__guizhi-phase") > 0
  end,
}
guizhi:addRelatedSkill(guizhi_refresh)
guizhi:addRelatedSkill(guizhi_refresh2)
guizhi:addRelatedSkill(guizhi_targetmod)
liubei:addSkill(guizhi)
Fk:loadTranslationTable{
  ["miniex__liubei"] = "极刘备",
}
Fk:loadTranslationTable{
  ["mini__guizhi"] = "圭志",
  [":mini__guizhi"] = "准备阶段，你可以与至多四名其他角色进行<a href='zhuluPindian'>逐鹿</a>，胜者下个出牌阶段使用的前X张牌无次数限制"..
  "（X为本次逐鹿没赢的角色数）。若你没赢，则你从牌堆中随机获得点数大于你逐鹿牌的张数的牌。",
  ["#mini__guizhi-choose"] = "圭志：与至多四名角色拼点，赢者使用牌无次数限制，若你没赢则摸牌",
  ["@mini__guizhi"] = "圭志",
  ["@mini__guizhi-phase"] = "圭志",
}
local hengyi = fk.CreateTriggerSkill{
  name = "mini__hengyi",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      local ids = {}
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      if #ids == 0 then return end
      if player:isKongcheng() then
        return true
      else
        return table.find(ids, function (id)
          return table.every(player:getCardIds("h"), function (id2)
            return Fk:getCardById(id).number >= Fk:getCardById(id2).number
          end)
        end)
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    if #ids == 0 then return end
    ids = table.filter(ids, function (id)
      return table.every(player:getCardIds("h"), function (id2)
        return Fk:getCardById(id).number >= Fk:getCardById(id2).number
      end) and
      table.every(ids, function (id2)
        return Fk:getCardById(id).number >= Fk:getCardById(id2).number
      end)
    end)
    local room = player.room
    room:setPlayerMark(player, "mini__hengyi-tmp", ids)
    local success, dat = room:askForUseActiveSkill(player, "mini__hengyi_active", "#mini__hengyi-invoke", true, nil, false)
    room:setPlayerMark(player, "mini__hengyi-tmp", 0)
    if success and dat then
      self.cost_data = {tos = dat.targets, cards = dat.cards, choice = dat.interaction}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if self.cost_data.choice == "draw2" then
      player:drawCards(2, self.name)
    else
      room:moveCardTo(self.cost_data.cards, Card.PlayerHand, self.cost_data.tos[1], fk.ReasonJustMove, self.name, nil, true, player.id)
    end
  end,
}
local hengyi_active = fk.CreateActiveSkill{
  name = "mini__hengyi_active",
  expand_pile = function (self, player)
    return player:getTableMark("mini__hengyi-tmp")
  end,
  interaction = function (self, player)
    local choices = {"draw2"}
    if table.find(player:getTableMark("mini__hengyi-tmp"), function (id)
      return not table.contains({Card.Void, Card.PlayerSpecial}, Fk:currentRoom():getCardArea(id))
    end) then
      table.insert(choices, 1, "mini__hengyi_give")
    end
    return UI.ComboBox {choices = choices }
  end,
  card_filter = function(self, to_select, selected, player)
    if self.interaction.data == "draw2" then
      return false
    else
      return #selected == 0 and table.contains(player:getTableMark("mini__hengyi-tmp"), to_select) and
        not table.contains({Card.Void, Card.PlayerSpecial}, Fk:currentRoom():getCardArea(to_select))
    end
  end,
  target_filter = function(self, to_select, selected, _, _, _, player)
    if self.interaction.data == "draw2" then
      return false
    else
      return #selected == 0 and to_select ~= player.id
    end
  end,
  feasible = function (self, selected, selected_cards, player)
    if self.interaction.data == "draw2" then
      return #selected == 0 and #selected_cards == 0
    else
      return #selected == 1 and #selected_cards == 1
    end
  end,
}
Fk:addSkill(hengyi_active)
liubei:addSkill(hengyi)
Fk:loadTranslationTable{
  ["mini__hengyi"] = "恒毅",
  [":mini__hengyi"] = "每回合限一次，当你失去手牌中点数最大的牌后，你可以选择一项：1.令一名其他角色获得此牌；2.摸两张牌。",
  ["mini__hengyi_active"] = "恒毅",
  ["#mini__hengyi-invoke"] = "恒毅：你可以选择一项",
  ["mini__hengyi_give"] = "令一名角色获得失去的牌",
}

local zhurong = General(extension, "miniex__zhurong", "shu", 4, 4, General.Female)
local xiangwei = fk.CreateTriggerSkill{
  name = "mini__xiangwei",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Start then
      local card = Fk:cloneCard("savage_assault")
      card.skillName = self.name
      return player:canUse(card)
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("savage_assault")
    card.skillName = self.name
    local use = {
      from = player.id,
      card = card,
    }
    room:useCard(use)
    if player.dead then return end
    local choices = {}
    local targets, n = {}, 0
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not (use.damageDealt and use.damageDealt[p.id]) then
        table.insert(targets, p.id)
      end
    end
    for _, p in ipairs(room.players) do
      if use.damageDealt and use.damageDealt[p.id] then
        n = n + 1
      end
    end
    if #targets > 0 then
      table.insert(choices, "mini__xiangwei_bypass_times")
    end
    if n > 0 then
      table.insert(choices, "mini__xiangwei_slash:::"..n)
    end
    local choice = room:askForChoice(player, choices, self.name, "#mini__xiangwei-turn")
    if choice == "mini__xiangwei_bypass_times" then
      room:setPlayerMark(player, "@@mini__xiangwei_bypass_times-turn", targets)
    else
      room:setPlayerMark(player, "@mini__xiangwei_slash-turn", n)
    end
  end,
}
local xiangwei_targetmod = fk.CreateTargetModSkill{
  name = "#mini__xiangwei_targetmod",
  bypass_times = function (self, player, skill, scope, card, to)
    return card and table.contains(player:getTableMark("@@mini__xiangwei_bypass_times-turn"), to.id)
  end,
}
local xiangwei_refresh = fk.CreateTriggerSkill{
  name = "#mini__xiangwei_refresh",

  refresh_events = {fk.PreCardUse},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@mini__xiangwei_slash-turn") > 0 and
      data.card.trueName == "slash"
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__xiangwei_slash-turn", 1)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
}
xiangwei:addRelatedSkill(xiangwei_targetmod)
xiangwei:addRelatedSkill(xiangwei_refresh)
zhurong:addSkill(xiangwei)
Fk:loadTranslationTable{
  ["miniex__zhurong"] = "极祝融",
}
Fk:loadTranslationTable{
  ["mini__xiangwei"] = "象威",
  [":mini__xiangwei"] = "准备阶段，你可以视为使用一张【南蛮入侵】，然后选择一项：1.本回合对未因此牌受到伤害的其他角色使用牌无次数限制；"..
  "2.本回合你使用的下X张【杀】伤害+1（X为受到此牌伤害的角色数）。",
  ["#mini__xiangwei-turn"] = "象威：选择一项本回合生效",
  ["mini__xiangwei_bypass_times"] = "对未受到伤害的角色使用牌无次数限制",
  ["mini__xiangwei_slash"] = "下%arg张【杀】伤害+1",
  ["@@mini__xiangwei_bypass_times-turn"] = "象威 无次数限制",
  ["@mini__xiangwei_slash-turn"] = "象威 杀增伤",
}
local yanfeng = fk.CreateViewAsSkill{
  name = "mini__yanfeng",
  anim_type = "offensive",
  prompt = "#mini__yanfeng",
  times = function(self)
    return 1 + Self:getMark("mini__yanfeng_strive_times-round") - Self:usedSkillTimes(self.name, Player.HistoryRound)
  end,
  handly_pile = true,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("fire__slash")
    card.skillName = self.name
    card:addSubcard(cards[1])
    return card
  end,
  after_use = function (self, player, use)
    local room = player.room
    if player.dead or use.damageDealt or #TargetGroup:getRealTargets(use.tos) ~= 1 then return end
    local to = room:getPlayerById(TargetGroup:getRealTargets(use.tos)[1])
    if to.dead then return end
    local choice = room:askForChoice(to, {
      "mini__yanfeng1:"..player.id,
      "mini__yanfeng2:"..player.id,
    }, self.name)
    if choice[14] == "1" then
      room:damage{
        from = to,
        to = player,
        damage = 1,
        skillName = self.name,
      }
      if not to.dead then
        local cards = table.filter(to:getCardIds("he"), function (id)
          return not to:prohibitDiscard(id)
        end)
        if #cards > 0 then
          room:throwCard(table.random(cards), self.name, to, to)
        end
      end
    else
      room:addTableMarkIfNeed(player, "mini__yanfeng-turn", to.id)
      player:drawCards(1, self.name)
    end
  end,
  enabled_at_play = function (self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) < (1 + player:getMark("mini__yanfeng_strive_times-round"))
  end,
}
local yanfeng_targetmod = fk.CreateTargetModSkill{
  name = "#mini__yanfeng_targetmod",
  bypass_distances = function (self, player, skill, card, to)
    return card and table.contains(card.skillNames, "mini__yanfeng")
  end,
}
local yanfeng_trigger = fk.CreateTriggerSkill{
  name = "#mini__yanfeng_trigger",
  mute = true,
  events = {fk.PreCardEffect},
  can_trigger = function (self, event, target, player, data)
    return data.from == player.id and data.card.trueName == "slash" and
      table.contains(player:getTableMark("mini__yanfeng-turn"), data.to)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:removeTableMark(player, "mini__yanfeng-turn", data.to)
    return true
  end,

  refresh_events = {fk.Damage, fk.Damaged},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("#mini__yanfeng_strive_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__yanfeng_strive_times-round", 1)
  end,
}
yanfeng:addRelatedSkill(yanfeng_targetmod)
yanfeng:addRelatedSkill(yanfeng_trigger)
zhurong:addSkill(yanfeng)
Fk:loadTranslationTable{
  ["mini__yanfeng"] = "炎锋",
  [":mini__yanfeng"] = "<a href='MiniStriveSkill'>奋武技</a>，出牌阶段，你可以将一张牌当无距离限制的火【杀】使用。若此【杀】未造成伤害且"..
  "仅指定唯一目标，你令目标选择一项：1.对你造成1点伤害，然后其随机弃置一张牌；2.令你摸一张牌，本回合你对其使用的下一张【杀】无效。",
  ["#mini__yanfeng"] = "炎锋：你可以将一张牌当无距离限制的火【杀】使用",
  ["mini__yanfeng1"] = "对%src造成1点伤害，你随机弃置一张牌",
  ["mini__yanfeng2"] = "%src摸一张牌，其本回合对你使用的下一张【杀】无效",
}

local caorui = General(extension, "miniex__caorui", "wei", 3)
local weisheng = fk.CreateActiveSkill{
  name = "mini__weisheng",
  anim_type = "control",
  prompt = function (self)
    return "#mini__weisheng:::"..(#Fk:currentRoom().alive_players + 1) // 2
  end,
  card_num = 0,
  min_target_num = function ()
    return (#Fk:currentRoom().alive_players + 1) // 2
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    return to_select ~= player.id and player:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = table.map(effect.tos, Util.Id2PlayerMapper)
    local pindian = U.jointPindian(player, targets, self.name)
    local winner = pindian.winner
    if winner and not winner.dead then
      table.insert(targets, player)
      targets = table.filter(targets, function (p)
        return p ~= winner and not p.dead and winner:canUseTo(Fk:cloneCard("slash"), p, {bypass_distances = true, bypass_times = true})
      end)
      if #targets == 0 then return end
      targets = table.map(targets, Util.IdMapper)
      local use = U.askForPlayCard(room, winner, nil, "slash", self.name, "#mini__weisheng-slash", {
        bypass_distances = true,
        bypass_times = true,
        exclusive_targets = targets,
      }, true)
      if use then
        use.extraUse = true
        use.extra_data = use.extra_data or {}
        use.extra_data.mini__weisheng = targets
        use.tos = table.map(targets, function (id) return {id} end)
        room:useCard(use)
      end
    end
  end,
}
local weisheng_delay = fk.CreateTriggerSkill{
  name = "#mini__weisheng_delay",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.mini__weisheng_trigger and
      table.find(data.extra_data.mini__weisheng, function (id)
        return not player.room:getPlayerById(id).dead
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(data.extra_data.mini__weisheng, function (id)
      return not room:getPlayerById(id).dead
    end)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:loseHp(p, 1, "mini__weisheng")
      end
    end
  end,

  refresh_events = {fk.CardEffectCancelledOut},
  can_refresh = function (self, event, target, player, data)
    return target == player and data.extra_data and data.extra_data.mini__weisheng and
      table.contains(data.extra_data.mini__weisheng, data.to)
  end,
  on_refresh = function (self, event, target, player, data)
    data.extra_data.mini__weisheng_trigger = true
    local dat = data.extra_data.mini__weisheng
    for i = #dat, 1, -1 do
      if dat[i] == data.to then
        table.remove(dat, i)
      end
    end
    data.extra_data.mini__weisheng = dat
  end,
}
weisheng:addRelatedSkill(weisheng_delay)
caorui:addSkill(weisheng)
Fk:loadTranslationTable{
  ["miniex__caorui"] = "极曹叡",
}
Fk:loadTranslationTable{
  ["mini__weisheng"] = "威乘",
  [":mini__weisheng"] = "出牌阶段限一次，你可以与至少全场半数（向上取整）角色进行一次<a href='zhuluPindian'>逐鹿</a>，胜者可以使用一张"..
  "指定所有败者为目标的【杀】。若有败者使用【闪】抵消此【杀】，此【杀】结算后，未使用【闪】的败者失去1点体力。",
  ["#mini__weisheng"] = "威乘：与至少%arg名角色拼点，胜者可以使用一张指定所有败者为目标的【杀】",
  ["#mini__weisheng-slash"] = "威乘：你可以使用一张指定所有败者为目标的【杀】",
  ["#mini__weisheng_delay"] = "威乘",
}
local bianguan = fk.CreateTriggerSkill{
  name = "mini__bianguan",
  anim_type = "drawcard",
  frequency = Skill.Compulsory,
  events = {fk.PindianFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and (target == player or data.results[player.id]) and
      player:usedSkillTimes(self.name, Player.HistoryRound) == 0 then
      local room = player.room
      --[[local events = room.logic:getEventsOfScope(U.JointPindianEvent, 1, function(e)
        local pindian = e.data[1]
        return pindian.from == player or pindian.results[player.id]
      end, Player.HistoryRound)
      if #events > 0 and events[1].id == room.logic:getCurrentEvent().id then]]--
      --FIXME: 自定义事件记录器挂了
      if room.logic:getCurrentEvent().event.name ~= U.JointPindianEvent then return end
        if room:getCardArea(data.fromCard) == Card.Processing then
          return true
        end
        for _, result in pairs(data.results) do
          if room:getCardArea(result.toCard) == Card.Processing then
            return true
          end
        end
      --end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    if room:getCardArea(data.fromCard) == Card.Processing then
      table.insertTable(cards, Card:getIdList(data.fromCard))
    end
    for _, result in pairs(data.results) do
      if room:getCardArea(result.toCard) == Card.Processing then
        table.insertTableIfNeed(cards, Card:getIdList(result.toCard))
      end
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id)
  end,
}
local bianguan_trigger = fk.CreateTriggerSkill{
  name = "#mini__bianguan_trigger",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true) and
      #table.filter(player.room.alive_players, function (p)
        return not p:isKongcheng()
      end) > 1
      --无视拼点合法性判断
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return not p:isKongcheng()
    end)
    room:doIndicate(player.id, table.map(targets, Util.IdMapper))
    local src = targets[1]
    table.remove(targets, 1)
    local pindian = U.jointPindian(src, targets, self.name)
    for _, p in ipairs(room:getAlivePlayers()) do
      if pindian.winner ~= p and (p == pindian.from or pindian.results[p.id]) and not p.dead then
        room:loseHp(p, 1, "mini__bianguan")
      end
    end
  end,
}
bianguan:addRelatedSkill(bianguan_trigger)
caorui:addSkill(bianguan)
Fk:loadTranslationTable{
  ["mini__bianguan"] = "变观",
  [":mini__bianguan"] = "锁定技，当你每轮首次参与<a href='zhuluPindian'>逐鹿</a>后，你获得本次逐鹿所有拼点牌。当你死亡时，"..
  "令场上所有存活角色进行一次逐鹿，所有败者失去1点体力。",
  ["#mini__bianguan_trigger"] = "变观",
}

local hetaihou = General(extension, "miniex__hetaihou", "qun", 3, 3, General.Female)
local fuyin = fk.CreateTriggerSkill{
  name = "mini__fuyin",
  anim_type = "control",
  events = {fk.GameStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#mini__fuyin-choose", self.name)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:setPlayerMark(to, "@@mini__fuyin", 1)
  end,

  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function (self, event, target, player, data)
    return target == player and data.to == Player.Draw and player:getMark("@@mini__fuyin") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player:skip(Player.Draw)
  end,
}
local fuyin_trigger = fk.CreateTriggerSkill{
  name = "#mini__fuyin_trigger",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("mini__fuyin")
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.n = data.n + 2
  end,
}
local fuyin_delay = fk.CreateTriggerSkill{
  name = "#mini__fuyin_delay",
  mute = true,
  events = {fk.AfterDrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("mini__fuyin", true) and not player:isNude() and
      table.find(player.room:getOtherPlayers(player), function (p)
        return p:getMark("@@mini__fuyin") > 0
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function (p)
      return p:getMark("@@mini__fuyin") > 0
    end)
    room:askForYiji(player, player:getCardIds("he"), targets, "mini__fuyin", 2, 2, "#mini__fuyin-give")
  end,
}
fuyin:addRelatedSkill(fuyin_trigger)
fuyin:addRelatedSkill(fuyin_delay)
hetaihou:addSkill(fuyin)
Fk:loadTranslationTable{
  ["miniex__hetaihou"] = "极何太后",
}
Fk:loadTranslationTable{
  ["mini__fuyin"] = "覆胤",
  [":mini__fuyin"] = "游戏开始时，你可以令一名其他角色获得“覆胤”标记，有“覆胤”标记的角色跳过摸牌阶段。摸牌阶段，你多摸两张牌，然后交给"..
  "有“覆胤”标记的角色两张牌。",
  ["#mini__fuyin-choose"] = "覆胤：你可以令一名角色获得“覆胤”标记！",
  ["@@mini__fuyin"] = "覆胤",
  ["#mini__fuyin_trigger"] = "覆胤",
  ["#mini__fuyin-give"] = "覆胤：请交给“覆胤”角色两张牌",
}
local qiangji = fk.CreateTriggerSkill{
  name = "mini__qiangji",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if #move.moveInfo > 1 and (move.to and move.to ~= player.id and
          player.room.current.id ~= move.to and move.toArea == Card.PlayerHand) then
          return true
        end
      end
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if #move.moveInfo > 1 and (move.to and move.to ~= player.id and
        player.room.current.id ~= move.to and move.toArea == Card.PlayerHand) then
        table.insertIfNeed(targets, move.to)
      end
    end
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      if not player:hasSkill(self) or player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 then return end
      local p = room:getPlayerById(id)
      if not p.dead then
        self:doCost(event, p, player, nil)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askForChoice(player, {"log_spade", "log_club", "log_heart", "log_diamond", "Cancel"}, self.name,
      "#mini__qiangji-choice::"..target.id)
    if choice ~= "Cancel" then
      self.cost_data = {tos = {target.id}, choice = choice}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = self.cost_data.choice,
      toast = true,
    }
    local nums = {
      ["log_spade"] = 0,
      ["log_club"] = 0,
      ["log_heart"] = 0,
      ["log_diamond"] = 0,
    }
    for _, id in ipairs(target:getCardIds("h")) do
      nums[Fk:getCardById(id):getSuitString(true)] = nums[Fk:getCardById(id):getSuitString(true)] + 1
    end
    local n = nums[self.cost_data.choice]
    for _, num in pairs(nums) do
      if num > n then
        return
      end
    end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}
hetaihou:addSkill(qiangji)
Fk:loadTranslationTable{
  ["mini__qiangji"] = "强忌",
  [":mini__qiangji"] = "每回合限一次，当一名其他角色于其回合外一次性获得至少两张手牌后，你可以猜测其手牌中牌最多的一种花色，若你猜对，"..
  "对其造成1点伤害。",
  ["#mini__qiangji-choice"] = "强忌：猜测 %dest 手牌中最多的花色，若猜对，对其造成1点伤害",
}

local chengong = General(extension, "miniex__chengong", "qun", 3)
Fk:loadTranslationTable{
  ["miniex__chengong"] = "极陈宫",
}
local zuoqing = fk.CreateActiveSkill{
  name = "mini__zuoqing",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#mini__zuoqing",
  interaction = function(self, player)
    local choices = {"loseHp"}
    if #player:getCardIds("e") > 0 then
      table.insert(choices, "mini__zuoqing_discard")
    end
    return UI.ComboBox { choices = choices, all_choices = {"loseHp", "mini__zuoqing_discard"} }
  end,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    return #selected == 0 and not table.contains(player:getTableMark("mini__zuoqing-phase"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "mini__zuoqing-phase", target.id)
    if self.interaction.data == "loseHp" then
      room:loseHp(player, 1, self.name)
    else
      room:throwCard(player:getCardIds("e"), self.name, player, player)
    end
    if target.dead then return end
    local choice = room:askForChoice(target, {"mini__zuoqing_use", "mini__zuoqing_response"}, self.name)
    local n = math.max(1, player:getLostHp())
    room:setPlayerMark(target, "@"..choice, math.max(n, target:getMark("@"..choice)))
  end,
}
local zuoqing_trigger = fk.CreateTriggerSkill{
  name = "#mini__zuoqing_trigger",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@mini__zuoqing_use") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__zuoqing_use", 1)
    player:drawCards(1, "mini__zuoqing")
  end,
}
local zuoqing_trigger2 = fk.CreateTriggerSkill{
  name = "#mini__zuoqing_trigger2",
  anim_type = "drawcard",
  events = {fk.CardResponding},
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:getMark("@mini__zuoqing_response") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:removePlayerMark(player, "@mini__zuoqing_response", 1)
    player:drawCards(1, "mini__zuoqing")
  end,
}
zuoqing:addRelatedSkill(zuoqing_trigger)
zuoqing:addRelatedSkill(zuoqing_trigger2)
chengong:addSkill(zuoqing)
Fk:loadTranslationTable{
  ["mini__zuoqing"] = "佐卿",
  [":mini__zuoqing"] = "出牌阶段每名角色限一次，你可以失去1点体力或弃置装备区内所有装备牌（至少一张），令一名角色选择其接下来"..
  "1.使用；2.打出前X张【杀】时摸一张牌（X为你已损失体力值且至少为1）。",
  ["#mini__zuoqing"] = "佐卿：失去1点体力或弃置装备，令一名角色接下来使用或打出杀时摸一张牌",
  ["mini__zuoqing_discard"] = "弃置所有装备",
  ["mini__zuoqing_use"] = "使用【杀】时摸一张牌",
  ["mini__zuoqing_response"] = "打出【杀】时摸一张牌",
  ["@mini__zuoqing_use"] = "使用杀摸牌",
  ["@mini__zuoqing_response"] = "打出杀摸牌",
  ["#mini__zuoqing_trigger"] = "佐卿",
  ["#mini__zuoqing_trigger2"] = "佐卿",
}
local jianchou = fk.CreateTriggerSkill{
  name = "mini__jianchou",
  anim_type = "masochism",
  events = {fk.Damaged},
  times = function(self)
    return 2 - Self:usedSkillTimes(self.name, Player.HistoryRound)
  end,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card and table.contains({"slash", "duel"}, data.card.trueName) and
      not target.dead and player:usedSkillTimes(self.name, Player.HistoryRound) < 2 and
      data.from and data.from ~= target and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#mini__jianchou-invoke:"..target.id..":"..data.from.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if use_event then
      local use = use_event.data[1]
      use.extra_data = use.extra_data or {}
      use.extra_data.mini__jianchou = use.extra_data.mini__jianchou or {}
      table.insert(use.extra_data.mini__jianchou, {
        from = target,
        to = data.from,
      })
    end
  end,
}
local jianchou_delay = fk.CreateTriggerSkill{
  name = "#mini__jianchou_delay",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if data.extra_data and data.extra_data.mini__jianchou then
      if player.dead then return end
      for _, info in ipairs(data.extra_data.mini__jianchou) do
        if info.from == player and not info.to.dead then
          local card = Fk:cloneCard("duel")
          card.skillName = "mini__jianchou"
          return player:canUseTo(card, info.to)
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local new_info = {}
    for i = #data.extra_data.mini__jianchou, 1, -1 do
      local info = data.extra_data.mini__jianchou[i]
      if info.from == player then
        table.insert(new_info, 1, info.to)
        table.remove(data.extra_data.mini__jianchou, i)
      end
    end
    for _, to in ipairs(new_info) do
      if player.dead then return end
      if not to.dead then
        room:useVirtualCard("duel", nil, player, to, "mini__jianchou")
      end
    end
  end,
}
jianchou:addRelatedSkill(jianchou_delay)
chengong:addSkill(jianchou)
Fk:loadTranslationTable{
  ["mini__jianchou"] = "谏仇",
  [":mini__jianchou"] = "每轮限两次，一名角色受到【杀】或【决斗】造成的伤害后，你可以令其于此牌结算结束后，视为对伤害来源使用一张【决斗】。",
  ["#mini__jianchou-invoke"] = "谏仇：是否令 %src 视为对 %dest 使用【决斗】？",
  ["#mini__jianchou_delay"] = "谏仇",
}

local zhangchunhua = General(extension, "miniex__zhangchunhua", "wei", 3, 3, General.Female)
local juejue = fk.CreateTriggerSkill{
  name = "mini__juejue",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player:getMark("mini__juejue-turn") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1,
      "#mini__juejue-choose", self.name, false)
    room:loseHp(room:getPlayerById(to[1]), 1, self.name)
  end,

  refresh_events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if not player:isKongcheng() or player:getMark("mini__juejue-turn") > 0 then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "mini__juejue-turn", 1)
  end,
}
zhangchunhua:addSkill(juejue)
Fk:loadTranslationTable{
  ["miniex__zhangchunhua"] = "极张春华",
}
Fk:loadTranslationTable{
  ["mini__juejue"] = "绝决",
  [":mini__juejue"] = "锁定技，一名角色回合结束时，若你本回合失去过所有手牌，你令一名角色失去1点体力。",
  ["#mini__juejue-choose"] = "绝决：令一名角色失去1点体力",
}
local qingshiz = fk.CreateTriggerSkill{
  name = "mini__qingshiz",
  anim_type = "control",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and #TargetGroup:getRealTargets(data.tos) == 1 then
      if target == player then
        return TargetGroup:getRealTargets(data.tos)[1] ~= player.id
      else
        return TargetGroup:getRealTargets(data.tos)[1] == player.id
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local to = target.id
    if target == player then
      to = TargetGroup:getRealTargets(data.tos)[1]
    end
    if player.room:askForSkillInvoke(player, self.name, nil,
      "#mini__qingshiz-invoke::"..to..":"..data.card:toLogString()..":"..math.max(1, player:getLostHp())) then
      self.cost_data = {tos = {to}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = math.max(1, player:getLostHp())
    data.extra_data = data.extra_data or {}
    data.extra_data.mini__qingshiz = data.extra_data.mini__qingshiz or {}
    table.insertIfNeed(data.extra_data.mini__qingshiz, player.id)
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:askForDiscard(player, n, n, true, self.name, false, nil, "#mini__qingshiz-discard::"..player.id..":"..n)
    if player.dead or to.dead or to:isNude() then return end
    local cards = to:getCardIds("he")
    if #cards > n then
      cards = room:askForCardsChosen(player, to, n, n, "he", self.name, "#mini__qingshiz-discard::"..to.id..":"..n)
    end
    room:throwCard(cards, self.name, to, player)
  end,
}
local qingshiz_delay = fk.CreateTriggerSkill{
  name = "#mini__qingshiz_delay",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return data.damageDealt and data.extra_data and data.extra_data.mini__qingshiz and
      table.contains(data.extra_data.mini__qingshiz, player.id) and not player.dead
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player:drawCards(math.max(1, player:getLostHp()), "mini__qingshiz")
  end,
}
qingshiz:addRelatedSkill(qingshiz_delay)
zhangchunhua:addSkill(qingshiz)
Fk:loadTranslationTable{
  ["mini__qingshiz"] = "情逝",
  [":mini__qingshiz"] = "你对其他角色使用牌时，或其他角色对你使用牌时，若目标数为1，你可以弃置你与其各X张牌（不足则全弃），然后若此牌造成伤害，"..
  "你摸X张牌（X为你已损失体力值且至少为1）。",
  ["#mini__qingshiz-invoke"] = "情逝：是否弃置你与 %dest 各%arg2张牌？若此%arg造成伤害则你摸牌",
  ["#mini__qingshiz-discard"] = "情逝：弃置 %dest %arg张牌",
  ["#mini__qingshiz_delay"] = "情逝",
}
local qingjuez = fk.CreateTriggerSkill{
  name = "mini__qingjuez",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.hp < 1 and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "mini__qingjuez", 1)
    room:recover{
      who = player,
      num = 1 - player.hp,
      recoverBy = player,
      skillName = self.name,
    }
  end,

  refresh_events = {fk.EventPhaseChanging},
  can_refresh = function (self, event, target, player, data)
    return target == player and data.to == Player.Draw and player:getMark("mini__qingjuez") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "mini__qingjuez", 0)
    player:skip(Player.Draw)
  end,
}
zhangchunhua:addSkill(qingjuez)
Fk:loadTranslationTable{
  ["mini__qingjuez"] = "清绝",
  [":mini__qingjuez"] = "限定技，当你进入濒死状态时，你可以回复体力至1点并跳过下个摸牌阶段。",
}

local zhangfei = General(extension, "miniex__zhangfei", "shu", 4)
local hupo = fk.CreateActiveSkill{
  name = "mini__hupo",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#mini__hupo",
  times = function(self)
    return 1 + Self:getMark("mini__hupo_strive_times-round") - Self:usedSkillTimes(self.name, Player.HistoryRound)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryRound) < (1 + player:getMark("mini__hupo_strive_times-round"))
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, _, _, _, player)
    return #selected == 0 and to_select ~= player.id and
      not (player:isKongcheng() and Fk:currentRoom():getPlayerById(to_select):isKongcheng())
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if not player:isKongcheng() then
      player:showCards(player:getCardIds("h"))
    end
    if not target:isKongcheng() and not target.dead then
      target:showCards(target:getCardIds("h"))
    end
    if player.dead or target.dead then return end
    local choices = {}
    if not (player:isNude() and target:isNude()) then
      table.insert(choices, "mini__hupo_discard")
    end
    local cards = table.filter(target:getCardIds("he"), function (id)
      return not table.find(player:getCardIds("he"), function (id2)
        return Fk:getCardById(id).trueName == Fk:getCardById(id2).trueName
      end)
    end)
    if #cards > 0 then
      table.insert(choices, "mini__hupo_prey")
    end
    if #choices == 0 then return end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "mini__hupo_discard" then
      choices = {}
      for _, id in ipairs(player:getCardIds("he")) do
        if not player:prohibitDiscard(id) then
          table.insertIfNeed(choices, Fk:getCardById(id).trueName)
        end
      end
      for _, id in ipairs(target:getCardIds("he")) do
        table.insertIfNeed(choices, Fk:getCardById(id).trueName)
      end
      choice = room:askForChoice(player, choices, self.name, "#mini__hupo-discard")
      local moves = {}
      local ids = table.filter(player:getCardIds("he"), function (id)
        return Fk:getCardById(id).trueName == choice and not player:prohibitDiscard(id)
      end)
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = player.id,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          skillName = self.name,
          proposer = player.id,
          moveVisible = true,
        })
      end
      ids = table.filter(target:getCardIds("he"), function (id)
        return Fk:getCardById(id).trueName == choice
      end)
      if #ids > 0 then
        table.insert(moves, {
          ids = ids,
          from = target.id,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonDiscard,
          skillName = self.name,
          proposer = player.id,
          moveVisible = true,
        })
      end
      room:moveCards(table.unpack(moves))
    else
      cards = U.askforChooseCardsAndChoice(player, cards, {"OK"}, self.name, "#mini__hupo-prey::"..target.id)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, true, player.id)
    end
  end,
}
local hupoStriveSkillRecord = fk.CreateTriggerSkill{
  name = "#mini__hupo_strive_reocrd",
  refresh_events = {fk.Damage, fk.Damaged},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("#mini__hupo_strive_times-round") < 4
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "mini__hupo_strive_times-round", 1)
  end,
}
hupo:addRelatedSkill(hupoStriveSkillRecord)
zhangfei:addSkill(hupo)
Fk:loadTranslationTable{
  ["miniex__zhangfei"] = "极张飞",
}
Fk:loadTranslationTable{
  ["mini__hupo"] = "虎魄",
  [":mini__hupo"] = "<a href='MiniStriveSkill'>奋武技</a>，出牌阶段，你可以展示你与一名其他角色的手牌，然后你选择一项："..
  "1.弃置你与其一个牌名的所有牌；2.获得其一张你没有的牌名的牌。",
  ["#mini__hupo"] = "虎魄：展示你与一名角色所有手牌，然后弃置其中一种牌或获得其一张牌",
  ["mini__hupo_discard"] = "弃置双方一个牌名的所有牌",
  ["mini__hupo_prey"] = "获得其一张你没有的牌名的牌",
  ["#mini__hupo-discard"] = "虎魄：选择要弃置的牌名",
  ["#mini__hupo-prey"] = "虎魄：获得 %dest 的一张牌",
}
local hanxing = fk.CreateTriggerSkill{
  name = "mini__hanxing",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and
      table.contains(TargetGroup:getRealTargets(data.tos), player.id) then
      local events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        return use.from == player.id and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
      end, Player.HistoryTurn)
      return events and player.room.logic:getCurrentEvent().id == events[1].id
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@mini__hanxing", 1)
  end,
}
local hanxing_trigger = fk.CreateTriggerSkill{
  name = "#mini__hanxing_trigger",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@mini__hanxing") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + player:getMark("@mini__hanxing")
    player.room:setPlayerMark(player, "@mini__hanxing", 0)
  end,
}
hanxing:addRelatedSkill(hanxing_trigger)
zhangfei:addSkill(hanxing)
Fk:loadTranslationTable{
  ["mini__hanxing"] = "酣兴",
  [":mini__hanxing"] = "锁定技，每回合你首次对自己使用牌后，你下一次造成的伤害+1。",
  ["@mini__hanxing"] = "酣兴",
  ["#mini__hanxing_trigger"] = "酣兴",
}

return extension
