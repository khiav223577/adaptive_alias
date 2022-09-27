## Change Log

### [v1.1.0](https://github.com/khiav223577/adaptive_alias/compare/v1.0.0...v1.1.0) 2022/09/27
- [#22](https://github.com/khiav223577/adaptive_alias/pull/22) [Fix] creation via autosave(belongs_to) association  (@khiav223577)

### [v1.0.0](https://github.com/khiav223577/adaptive_alias/compare/v0.2.4...v1.0.0) 2022/09/22
- [#21](https://github.com/khiav223577/adaptive_alias/pull/21) [Fix] Model with ignored_columns or calling find_by directly on model class with aliased column argument will fail (@khiav223577)
- [#20](https://github.com/khiav223577/adaptive_alias/pull/20) [Fix] Problems with STI classes and models that uses same table name (@khiav223577)
- [#19](https://github.com/khiav223577/adaptive_alias/pull/19) [Fix] Rescue the error when doing direct access to target table's field (@khiav223577)

### [v0.2.4](https://github.com/khiav223577/adaptive_alias/compare/v0.2.3...v0.2.4) 2022/08/18
- [#18](https://github.com/khiav223577/adaptive_alias/pull/18) [Fix] Get model from a relation with join will not generate right query (after migration) (@khiav223577)

### [v0.2.3](https://github.com/khiav223577/adaptive_alias/compare/v0.2.2...v0.2.3) 2022/08/17
- [#17](https://github.com/khiav223577/adaptive_alias/pull/17) [Feature] Support joins (@khiav223577)
- [#16](https://github.com/khiav223577/adaptive_alias/pull/16) [Enhance] No need to clone node (@khiav223577)
- [#15](https://github.com/khiav223577/adaptive_alias/pull/15) [Test] Add test cases to test calling pluck on same model (@khiav223577)

### [v0.2.2](https://github.com/khiav223577/adaptive_alias/compare/v0.2.1...v0.2.2) 2022/08/11
- [#14](https://github.com/khiav223577/adaptive_alias/pull/14) [Fix] Fail to use backward-patch when target column has already been migrated (@khiav223577)

### [v0.2.1](https://github.com/khiav223577/adaptive_alias/compare/v0.2.0...v0.2.1) 2022/08/11
- [#13](https://github.com/khiav223577/adaptive_alias/pull/13) [Fix] Nested module include is not supported until ruby 3.0 (@khiav223577)
- [#12](https://github.com/khiav223577/adaptive_alias/pull/12) [Test] Add test cases to test column_names (@khiav223577)

### [v0.2.0](https://github.com/khiav223577/adaptive_alias/compare/v0.1.0...v0.2.0) 2022/08/05
- [#11](https://github.com/khiav223577/adaptive_alias/pull/11) [Feature] Support polymorphic (@khiav223577)
- [#10](https://github.com/khiav223577/adaptive_alias/pull/10) [Enhance] Prevent adding methods directly in class / module (@khiav223577)
- [#9](https://github.com/khiav223577/adaptive_alias/pull/9) [Enhance] Prevent changing original order of where conditions (@khiav223577)
- [#8](https://github.com/khiav223577/adaptive_alias/pull/8) [Test] Make sure we are reset to use original patch when some test cases fail (@khiav223577)
- [#7](https://github.com/khiav223577/adaptive_alias/pull/7) [Test] Add test cases to test destroy (@khiav223577)

### [v0.1.0](https://github.com/khiav223577/adaptive_alias/compare/v0.0.3...v0.1.0) 2022/08/01
- [#6](https://github.com/khiav223577/adaptive_alias/pull/6) [Feature] Deal with creating records (@khiav223577)
- [#5](https://github.com/khiav223577/adaptive_alias/pull/5) [Enhance] Prevent infinite loop if something went wrong (@khiav223577)
- [#4](https://github.com/khiav223577/adaptive_alias/pull/4) [Fix] Attributes writer method should be defined after schema changes (@khiav223577)

### [v0.0.3](https://github.com/khiav223577/adaptive_alias/compare/v0.0.2...v0.0.3) 2022/07/27
- [#3](https://github.com/khiav223577/adaptive_alias/pull/3) [Fix] Prevent calling custom column names from raising missing attributes (@khiav223577)

### [v0.0.2](https://github.com/khiav223577/adaptive_alias/compare/v0.0.1...v0.0.2) 2022/07/26
- [#2](https://github.com/khiav223577/adaptive_alias/pull/2) [Enhance] Doesn't need rails_compatibility in runtime (@khiav223577)

### v0.0.1 2022/07/22
- [#1](https://github.com/khiav223577/adaptive_alias/pull/1) [Feature] Implement adaptive_alias features (@khiav223577)
