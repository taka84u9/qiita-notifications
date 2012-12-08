.PHONY: build

build:
	@jshint contents/js/*.js
	@lessc -x source/less/popup.less > contents/css/popup.css
	@lessc -x source/less/options.less > contents/css/options.css
	@cd contents; zip -r ../qiita-notifications.zip ./