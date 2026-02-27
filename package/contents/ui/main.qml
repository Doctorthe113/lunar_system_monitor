import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property real memUsedGb: 0.0
    property real cpuUsage: 0.0
    property real dlSpeed: 0.0
    property real ulSpeed: 0.0
    property real prevRx: -1
    property real prevTx: -1

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: RowLayout {
        spacing: 8

        PlasmaComponents.Label {
            visible: plasmoid.configuration.showCpu
            text: "\u{F035B} " + root.cpuUsage.toFixed(1) + "%"
            font.family: plasmoid.configuration.fontFamily || undefined
            font.pointSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 10
        }

        PlasmaComponents.Label {
            text: "\u2295 " + root.memUsedGb.toFixed(1) + "G"
            font.family: plasmoid.configuration.fontFamily || undefined
            font.pointSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 10
        }

        PlasmaComponents.Label {
            text: "↓ " + root.formatSpeed(root.dlSpeed)
            font.family: plasmoid.configuration.fontFamily || undefined
            font.pointSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 10
        }

        PlasmaComponents.Label {
            text: "↑ " + root.formatSpeed(root.ulSpeed)
            font.family: plasmoid.configuration.fontFamily || undefined
            font.pointSize: plasmoid.configuration.fontSize > 0 ? plasmoid.configuration.fontSize : 10
        }
    }

    function formatSpeed(bps) {
        if (bps >= 1048576) return (bps / 1048576).toFixed(1) + "MB/s"
        if (bps >= 1024) return (bps / 1024).toFixed(1) + "KB/s"
        return bps.toFixed(1) + "B/s"
    }

    readonly property string netCmd: {
        var iface = plasmoid.configuration.networkInterface
        if (iface && iface.length > 0)
            return "awk '/" + iface + ":/{print $2,$10}' /proc/net/dev"
        return "awk 'NR>2&&!/lo:/{rx+=$2;tx+=$10}END{print rx,tx}' /proc/net/dev"
    }

    P5Support.DataSource {
        id: cpuSource
        engine: "executable"
        connectedSources: plasmoid.configuration.showCpu ? [
            "head -1 /proc/stat; sleep 0.2; head -1 /proc/stat"
        ] : []
        interval: plasmoid.configuration.updateInterval > 0 ? plasmoid.configuration.updateInterval : 500
        onNewData: function(source, data) {
            var lines = data["stdout"].trim().split("\n")
            if (lines.length < 2) return
            var a = lines[0].split(/\s+/).slice(1).map(Number)
            var b = lines[1].split(/\s+/).slice(1).map(Number)
            var totalA = a.reduce(function(s,v){return s+v}, 0)
            var totalB = b.reduce(function(s,v){return s+v}, 0)
            var idleA = a[3] + (a.length > 4 ? a[4] : 0)
            var idleB = b[3] + (b.length > 4 ? b[4] : 0)
            var dt = totalB - totalA
            var di = idleB - idleA
            if (dt > 0) root.cpuUsage = 100 * (1 - di / dt)
        }
    }

    P5Support.DataSource {
        id: memSource
        engine: "executable"
        connectedSources: [
            "awk '/MemTotal:/{t=$2} /MemAvailable:/{a=$2} END{printf \"%.1f\",(t-a)/1048576}' /proc/meminfo"
        ]
        interval: plasmoid.configuration.updateInterval > 0 ? plasmoid.configuration.updateInterval : 500
        onNewData: function(source, data) {
            var val = parseFloat(data["stdout"])
            if (!isNaN(val)) root.memUsedGb = val
        }
    }

    P5Support.DataSource {
        id: netSource
        engine: "executable"
        connectedSources: [root.netCmd]
        interval: plasmoid.configuration.updateInterval > 0 ? plasmoid.configuration.updateInterval : 500
        onNewData: function(source, data) {
            var stdout = data["stdout"]
            if (!stdout) return
            var parts = stdout.trim().split(/\s+/)
            if (parts.length < 2) return
            var rx = parseFloat(parts[0])
            var tx = parseFloat(parts[1])
            if (isNaN(rx) || isNaN(tx)) return
            if (root.prevRx >= 0) {
                var intervalSec = (plasmoid.configuration.updateInterval > 0 ? plasmoid.configuration.updateInterval : 500) / 1000
                root.dlSpeed = (rx - root.prevRx) / intervalSec
                root.ulSpeed = (tx - root.prevTx) / intervalSec
            }
            root.prevRx = rx
            root.prevTx = tx
        }
    }
}
