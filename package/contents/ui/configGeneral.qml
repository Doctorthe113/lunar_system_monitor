import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_networkInterface: ifaceField.text
    property string cfg_fontFamily
    property int cfg_fontSize: 10
    property string cfg_updateInterval
    property alias cfg_showCpu: showCpuCheck.checked

    FontDialog {
        id: fontDialog
        selectedFont: Qt.font({
            family: cfg_fontFamily || "Sans Serif",
            pointSize: cfg_fontSize
        })
        onAccepted: {
            cfg_fontFamily = selectedFont.family
            cfg_fontSize = selectedFont.pointSize
        }
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        TextField {
            id: ifaceField
            Kirigami.FormData.label: i18n("Network Interface:")
            placeholderText: i18n("Leave empty for all")
        }

        Button {
            Kirigami.FormData.label: i18n("Font:")
            text: (cfg_fontFamily || i18n("Default")) + " " + cfg_fontSize + "pt"
            onClicked: fontDialog.open()
        }

        ComboBox {
            id: intervalCombo
            Kirigami.FormData.label: i18n("Update Interval:")
            model: [
                { text: "0.5s", value: "500" },
                { text: "1s",   value: "1000" },
                { text: "1.5s", value: "1500" },
                { text: "2s",   value: "2000" }
            ]
            textRole: "text"
            currentIndex: {
                var vals = ["500", "1000", "1500", "2000"]
                var idx = vals.indexOf(cfg_updateInterval)
                return idx >= 0 ? idx : 0
            }
            onActivated: cfg_updateInterval = model[currentIndex].value
        }

        CheckBox {
            id: showCpuCheck
            Kirigami.FormData.label: i18n("Show CPU Usage:")
            text: i18n("Enabled")
        }
    }
}
