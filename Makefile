all:
	@echo Targets: release

release:
	./release.sh
	git push
