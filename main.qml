import QtQuick 2.4
import Material 0.1

ApplicationWindow {
	id: app
	visible: true

	theme {
		primaryColor: Palette.colors["cyan"]["500"]
		primaryDarkColor: Palette.colors["cyan"]["700"]
		accentColor: Palette.colors["grey"]["500"]
	}

	initialPage: LoginPage {
		id: loginp
		visible: true
		onLogin: { main.token = loginp.token; app.initialPage = main; main.visible = true; }
	}

	MainPage {
		id: main
		visible: false
	}
}
