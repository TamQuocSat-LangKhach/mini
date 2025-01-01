// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Pages
import Fk.RoomElement
import Qt5Compat.GraphicalEffects

GraphicsBox {
  id: root

  property var numbers: []
  property var areaNames: []
  property string prompt : ""
  property string result : ""
  property int padding: 25

  title.text: Util.processPrompt(prompt)
  width: 850
  height: title.height + body.height + padding * 2

  ColumnLayout {
    id: body
    x: padding
    y: parent.height - padding - height
    spacing: 20

    Repeater {
      id: areaRepeater
      model: numbers

      Row {
        spacing: 7

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          color: "#6B5D42"
          width: 20
          height: 100
          radius: 5

          Text {
            anchors.fill: parent
            width: 20
            height: 100
            text: qsTr(Backend.translate(areaNames[index]))
            color: "white"
            font.family: fontLibian.name
            font.pixelSize: 18
            style: Text.Outline
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
          }
        }

        Row {
          id: gridLayout
          y: 17
          spacing: 10

          Repeater {
            id: cardRepeater
            model: numbers[index]

            delegate: Rectangle {
              id: cardItem
              width : 50
              height : 66
              clip : true
              //border.color: "#FEF7D6"
              //border.width: 2
              radius : 2

              enabled : true

              Rectangle {
                id : cardBank
                anchors.fill: parent
                anchors.centerIn: parent
                visible: !this.enabled
                color: Qt.rgba(240, 240, 220, 0.7)
                opacity: 0.7
                z: 2
              }


              Image {
                id: numberItem
                anchors.centerIn: parent
                source: SkinBank.CARD_DIR + "number/black/" + modelData
                scale : 1.5
              }


              MouseArea {
                anchors.fill: parent
                anchors.centerIn: parent
                onClicked: {
                  result = modelData;
                  root.close();
                }


              }

            }
          }
        }
      }
    }

  }

  

}
