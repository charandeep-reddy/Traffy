APP = Traffy
BUNDLE_ID = com.psydevx.traffy
BUILD_DIR = .build/release

.PHONY: all build app dmg icon clean

all: dmg

build:
	swift build -c release

app: build
	rm -rf $(APP).app
	mkdir -p $(APP).app/Contents/MacOS
	mkdir -p $(APP).app/Contents/Resources
	cp $(BUILD_DIR)/$(APP) $(APP).app/Contents/MacOS/
	cp Resources/Info.plist $(APP).app/Contents/
	cp Resources/AppIcon.icns $(APP).app/Contents/Resources/
	printf "APPL????" > $(APP).app/Contents/PkgInfo
	codesign --force --sign - $(APP).app

dmg: app
	rm -f $(APP).dmg
	rm -rf _staging
	mkdir _staging
	cp -R $(APP).app _staging/
	ln -s /Applications _staging/Applications

	hdiutil create -volname "$(APP)" -srcfolder _staging \
		-ov -format UDZO -fs HFS+ $(APP).dmg

	rm -rf _staging
	@echo "DMG created: $(APP).dmg"

icon:
	swift IconGenerator.swift
	mkdir -p Resources/AppIcon.iconset
	cp Resources/app-icon-1024.png Resources/AppIcon.iconset/icon_512x512@2x.png
	sips -z 16 16 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_16x16.png > /dev/null 2>&1
	sips -z 32 32 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_16x16@2x.png > /dev/null 2>&1
	sips -z 32 32 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_32x32.png > /dev/null 2>&1
	sips -z 64 64 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_32x32@2x.png > /dev/null 2>&1
	sips -z 128 128 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_128x128.png > /dev/null 2>&1
	sips -z 256 256 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_128x128@2x.png > /dev/null 2>&1
	sips -z 256 256 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_256x256.png > /dev/null 2>&1
	sips -z 512 512 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_256x256@2x.png > /dev/null 2>&1
	sips -z 512 512 Resources/app-icon-1024.png --out Resources/AppIcon.iconset/icon_512x512.png > /dev/null 2>&1
	iconutil -c icns Resources/AppIcon.iconset -o Resources/AppIcon.icns
	rm -rf Resources/AppIcon.iconset Resources/app-icon-1024.png
	@echo "Icon created: Resources/AppIcon.icns"

clean:
	rm -rf .build *.app *.dmg
