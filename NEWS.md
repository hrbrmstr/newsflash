0.6.0
* add functions to work with the Third Eye chyron scraper archive

0.5.0
* add `top_trending()`
* add `top_trending_ranged()`

0.4.1
* add `txtplot` to `DESCRIPTION`; Fixes #2

0.4.0
* had to switch to `curl` direct calls since `httr` was being silly on large JSON results
* sub out `anytime` for `lubridate` to handle hour resolution in `top_matches`
* Handle support for new query features

0.3.0
* `top_text()` returns a tidy data frame by default

0.2.0
* Some extra helper functions

0.1.0 
* Initial release
