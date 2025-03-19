local wuyan = fk.CreateSkill {
  name = "mini__wuyan"
}

Fk:loadTranslationTable{
  ['mini__wuyan'] = '无言',
  [':mini__wuyan'] = '锁定技，当你受到锦囊牌造成的伤害时，防止此伤害。',
  ['$mini__wuyan1'] = '别跟我说话！我想静静……',
  ['$mini__wuyan2'] = '不忠不孝之人，不敢开口。',
}

wuyan:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(wuyan.name) and data.card and data.card.type == Card.TypeTrick
  end,
  on_use = Util.TrueFunc,
})

return wuyan
