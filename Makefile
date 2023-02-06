all:
	@echo Targets: release

release: test
	./release.sh
	git push

.PHONY: test
test:
	./test-charts
