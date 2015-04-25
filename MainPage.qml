import QtQuick 2.4
import Material 0.1

Page {
	id: page
	property string token

	title: "moodtapes"

	MouseArea {
		anchors.fill: parent
		onClicked: {
			pageStack.push(Qt.resolvedUrl("PlayerPage.qml"), { token: token })
		}
	}
}
