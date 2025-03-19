local qingxi = fk.CreateSkill {
  name = "mini__qingxi",
}

Fk:loadTranslationTable{
  ['mini__qingxi'] = '倾袭',
  [':mini__qingxi'] = '当你对其他角色造成伤害时，你可以令其选择一项：1.弃置X张手牌，然后弃置你装备区里的武器牌（X为你的攻击范围）；2.令此伤害+1。',
}

qingxi:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qingxi.name) and data.to and data.to ~= player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getAttackRange()
    if n > data.to:getHandcardNum() then
      data.damage = data.damage + 1
    else
      if #room:askToDiscard(data.to, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = qingxi.name,
        cancelable = true,
        prompt = "#qingxi-discard:::" .. n,
      }) == n then
        if #player:getEquipments(Card.SubtypeWeapon) > 0 then
          room:throwCard(player:getEquipments(Card.SubtypeWeapon), qingxi.name, player, data.to)
        end
      else
        data.damage = data.damage + 1
      end
    end
  end,
})

return qingxi
