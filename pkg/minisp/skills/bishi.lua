local bishi = fk.CreateSkill {
  name = "bishi"
}

Fk:loadTranslationTable{
  ['bishi'] = '避仕',
  [':bishi'] = '锁定技，你不能成为伤害类锦囊牌的目标。',
  ['$bishi1'] = '往矣！吾将曳尾于涂中。',
  ['$bishi2'] = '仕途多舛，哪有醉卧山野痛快！',
}

bishi:addEffect('prohibit', {
  frequency = Skill.Compulsory,
  is_prohibited = function(self, player, from, to, card)
    if to:hasSkill(bishi.name) then
      return card.is_damage_card and card.type == Card.TypeTrick
    end
  end,
})

return bishi
