import QtQuick 2.4
import Material 0.1
import Qt.labs.settings 1.0
import "httphelper.js" as HTTP

Page {
	id: page

	signal login
	property alias token: settings.token

	Settings {
		id: settings
		property string token
	}

	title: qsTr("Log in to your moodtapes account")

	Column {
		anchors.fill: parent
		anchors.margins: 50

		Image {
			id: logo
			anchors.horizontalCenter: parent.horizontalCenter
			source: "logo.jpg"
		}

		TextField {
			id: emailField
			width: parent.width
			placeholderText: qsTr("e-mail")

			text: "spamgoga@gmail.com"
		}

		TextField {
			id: passField
			width: parent.width
			input.echoMode: TextInput.Password
			placeholderText: qsTr("password")

			text: "ternary6"
		}

		Button {
			id: loginButton
			anchors.horizontalCenter: parent.horizontalCenter
			enabled: emailField.text != "" && passField.text != ""
			text: qsTr("Log in")
			textColor: Theme.accentColor
			elevation: 1

			onClicked: {
				HTTP.postRequest("http://46.101.170.107/signin", encodeURI("email=" + emailField.text + "&password=" + passField.text), function(data) {
					if(data) {
						var dobj = JSON.parse(data)
						if(!dobj.error) {
							settings.token = dobj.session
							login()
						}
					}
				})
			}
		}
	}

	Component.onCompleted: {
		if(settings.token) {
			login()
		}
	}
}

