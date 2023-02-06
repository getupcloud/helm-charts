all:
	@echo Targets: release

release:
	./release.sh
	git push

.PHONY: test
test:
	./test-charts
