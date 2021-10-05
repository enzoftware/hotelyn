gen_code:
	flutter pub run build_runner build

test_coverage:
	flutter test --coverage --test-randomize-ordering-seed random
	genhtml coverage/lcov.info -o coverage/
	open coverage/index.html

