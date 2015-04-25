import QtQuick 2.4
import QtMultimedia 5.0
import Material 0.1
import Material.ListItems 0.1 as ListItem

Page {
	id: page
	actionBar.hidden: true
	property string token

	property var pictures: []

	Timer {
		id: timer
		interval: 5000
		running: true
		repeat: true

		onTriggered: {
			mPicture.current++
			if(mPicture.current >= pictures.length)
				mPicture.current = 0
		}
	}

	View {
		id: contPicture
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
		}
		height: 500
		elevation: 2

		Repeater {
			id: mPicture
			property int current: 0

			delegate: Image {
				id: picture
				anchors.fill: parent
				fillMode: Image.PreserveAspectCrop
				property bool hidden: index != mPicture.current

				source: pictures[index]
				Component.onCompleted: console.log("created image for", source)

				onHiddenChanged: {
					if(hidden)
						toInvisible.start()
					else
						toVisible.start()
				}

				OpacityAnimator {
					id: toVisible
					target: picture
					from: 0
					to: 1
					duration: 500
				}
				OpacityAnimator {
					id: toInvisible
					target: picture
					from: 1
					to: 0
					duration: 500
				}
			}
		}
	}

	ActionButton {
		id: switchPlay
		anchors {
			verticalCenter: contPicture.bottom
			right: parent.right
			margins: 40
		}
		width: 150
		height: 150
		focus: true

		state: player.playbackState == MediaPlayer.PlayingState ? "pause" : "play"

		states: [State {
					name: "play"
				},
				State {
					name: "pause"
				}]
		iconName: state == "play" ? "av/play_arrow" : "av/pause"

		onClicked: {
			if(state == "play") {
				player.play()
				//switchPlay.state = "pause"
			}
			else {
				player.pause()
				//switchPlay.state = "play"
			}
		}
	}

	MediaPlayer {
		id: player

		onPlaybackStateChanged: {
			if(status == MediaPlayer.EndOfMedia) {
				playlist.current++
				if(playlist.current > playlistModel.count)
					player.play()
			}
		}
	}

	Timer {
		id: positionTimer
		interval: 500
		running: player.playbackState == MediaPlayer.PlayingState
		repeat: true

		onTriggered: playlist.playPosition = player.position
	}

	ListView {
		id: playlist
		property int current: 1
		property int playPosition: 0
		onCurrentChanged: { player.source = playlistModel.get(playlist.current - 1).uri; player.play() }
		anchors {
			top: switchPlay.verticalCenter
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		clip: true

		model: ListModel { id: playlistModel }

		delegate: ListItem.Subtitled {
			id: delegate
			focus: false
			height: 153
			text: trackNumber + ". " + trackName
			subText: artist
			action: Icon {
				visible: trackNumber == playlist.current
				name: "av/play_arrow"
			}

			onClicked: {
				if(playlist.current == trackNumber && player.playbackState == MediaPlayer.PausedState)
					player.play()
				playlist.current = trackNumber
			}

			Slider {
				anchors {
					left: parent.left
					right: parent.right
					bottom: parent.bottom
					margins: 30
					bottomMargin: -15
				}
				visible: trackNumber == playlist.current
				minimumValue: 0
				maximumValue: player.duration
				value: playlist.playPosition
				onPressedChanged: player.seek(value)
			}
		}
	}

	function loadMood(id) {

	}

	Component.onCompleted: {
		loadMood(1)
		playlistModel.append({ trackNumber: 1, trackName: "Swedish Pagans", artist: "Sabaton", uri: "file:///storage/sdcard1/Music/Sabaton/2010 - The Art Of War (Re-Armed)/14 - Swedish Pagans.flac" })
		playlistModel.append({ trackNumber: 2, trackName: "Resist And Bite", artist: "Sabaton", uri: "file:///storage/sdcard1/Music/Sabaton/2014 - Heroes/07 (Sabaton) Resist And Bite.flac" })
		pictures.push("http://animalia-life.com/data_images/cat/cat2.jpg", "http://www.businessinsider.com/image/4f3433986bb3f7b67a00003c/cute-cat.jpg")
		mPicture.model = pictures.length
		player.source = playlistModel.get(playlist.current - 1).uri
		player.play()
	}
}

