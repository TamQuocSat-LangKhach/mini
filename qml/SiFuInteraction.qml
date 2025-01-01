// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import Fk
import Fk.Pages

MetroButton {
  id: root
  property string skill
  property var extra_data 
  property var numbers : (extra_data !== undefined) ? extra_data.numbers : []
  property var areaNames : (extra_data !== undefined) ? extra_data.area_names : []
  property string default_choice : "mini_sifu_choice"
  property string answer: default_choice

  text: Util.processPrompt(answer)

  onAnswerChanged: {
    if (!answer) return;
    lcall("UpdateRequestUI", "Interaction", "1", "update", answer);
    // lcall("SetInteractionDataOfSkill", skill, JSON.stringify(answer));
    // roomScene.dashboard.startPending(skill);
  }

  onClicked: {
    answer = default_choice;

    roomScene.popupBox.sourceComponent =
      Qt.createComponent(AppPath + "/packages/mini/qml/SiFuNumberBox.qml");
    
    const box = roomScene.popupBox.item;
    box.numbers = numbers;
    box.areaNames = areaNames;
    box.prompt = skill;
    box.accepted.connect(() => {
      answer = box.result;
    });
  }

}
