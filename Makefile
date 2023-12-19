all:
	@echo Targets: release

release: test
	./release.sh
	git push

release-local: test
	./release.sh --no-mirror
	git push

.PHONY: test
test:
	./test-charts
