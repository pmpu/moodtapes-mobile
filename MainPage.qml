import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import "httphelper.js" as HTTP

Page {
	id: page
	property string token
	property var tapes

	title: "moodtapes"
	actions: [Action {
			iconName: "action/exit_to_app"
			onTriggered: {
				page.actionBar.hidden = true
				page.visible = false
				var lp = pageStack.replace(Qt.resolvedUrl("LoginPage.qml"), { lout: true })
			}
		}]

	function loadMoodList() {
		HTTP.getRequest("http://46.101.170.107/all", function(data) {
			if(data) {
				var moods = JSON.parse(data)
				if(!moods.error) {
					tapes = moods.pages
					moodModel.append(moods.pages)
				}
				else console.log(moods.errorMsg)
			}
		})
	}

	ListView {
		id: moodList
		anchors.fill: parent
		anchors.bottomMargin: 10
		model: ListModel { id: moodModel }

		delegate: ListItem.BaseListItem {
			id: delegate
			property var tape: tapes[index]
			height: 300

			Image {
				id: moodPic
				fillMode: Image.PreserveAspectCrop
				anchors {
					left: parent.left
					right: parent.right
					top: parent.top
					margins: 10
				}
				height: 500

				source: "http://46.101.170.107" + tape.images[0].file
			}

			Timer {
				id: tagshowTimer
				interval: 4000
				running: delegate.tape.tags.length > 1
				repeat: true

				onTriggered: {
					if(mTags.currentTag >= delegate.tape.tags.length - 1)
						mTags.currentTag = 0
					else
						mTags.currentTag++
				}
			}

			Repeater {
				id: mTags
				anchors.fill: parent
				property int currentTag: 0
				model: tags
				delegate: Rectangle {
					id: tagRect
					property bool hidden: index != mTags.currentTag

					color: Theme.backgroundColor
					//opacity: tagLabel.opacity * 0.7
					anchors {
						right: parent.right
						top: parent.top
						topMargin: 35
						rightMargin: 10
					}
					height: 30
					width: tagLabel.width + 10

					onHiddenChanged: {
						if(hidden) {
							toInvisible.start()
							rToInvisible.start()
						}
						else {
							toVisible.start()
							rToVisible.start()
						}
					}
					OpacityAnimator {
						id: rToVisible
						target: tagRect
						from: 0
						to: 0.7
						duration: 500
					}
					OpacityAnimator {
						id: rToInvisible
						target: tagRect
						from: 0.7
						to: 0
						duration: 500
					}

					Text {
						id: tagLabel
						anchors {
							verticalCenter: parent.verticalCenter
							right: parent.right
							//topMargin: 35
							rightMargin: 5
						}
						//color: Theme.backgroundColor
						text: "#" + delegate.tape.tags[index]

						OpacityAnimator {
							id: toVisible
							target: tagLabel
							from: 0
							to: 1
							duration: 500
						}
						OpacityAnimator {
							id: toInvisible
							target: tagLabel
							from: 1
							to: 0
							duration: 500
						}
					}
				}
			}

			Text {
				id: nameLbl
				anchors {
					bottom: parent.bottom
					left: parent.left
					leftMargin: 35
					bottomMargin: 20
				}

				text: name
				font.pixelSize: units.dp(24)
				style: Text.Raised
				color: Theme.backgroundColor
				styleColor: "dark grey"
			}

			onClicked: pageStack.push(Qt.resolvedUrl("MoodPage.qml"), { token: token, moodId: id })
			Component.onCompleted: console.log(images)
		}
	}

	Component.onCompleted: {
		loadMoodList()
	}
}
