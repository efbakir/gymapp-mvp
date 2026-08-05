# Unit 2.1 migration fixture

`Unit-v2.1.store` is a populated SwiftData store generated from the pre-progression model schema at commit `b61aaa8`. Those model files are byte-identical to tag `v2.1-build58`.

The fixture contains one split, one routine, one exercise, one completed workout, and three working sets. `ProgressionPersistenceTests` copies it before each migration test; the bundled fixture is never opened in place.
