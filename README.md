
`newsflash` : Tools to Work with the Internet Archive and GDELT Television Explorer

Ref: <http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch>

> *"In collaboration with the Internet Archive's Television News Archive, GDELT's Television Explorer allows you to keyword search the closed captioning streams of the Archive's 6 years of American television news and explore macro-level trends in how America's television news is shaping the conversation around key societal issues. Unlike the Archive's primary Television News interface, which returns results at the level of an hour or half-hour "show," the interface here reaches inside of those six years of programming and breaks the more than one million shows into individual sentences and counts how many of those sentences contain your keyword of interest. Instead of reporting that CNN had 24 hour-long shows yesterday that mentioned Donald Trump, the interface here will count how many sentences uttered on CNN yesterday mentioned his name - a vastly more accurate metric for assessing media attention."*

The following functions are implemented:

-   `query_tv`: Issue a query to the TV Explorer

### Installation

``` r
devtools::install_github("hrbrmstr/newsflash")
```

``` r
options(width=120)
```

### Usage

``` r
library(newsflash)
library(tidyverse)
library(ggalt) # github version
library(hrbrmisc)

# current verison
packageVersion("newsflash")
```

    ## [1] '0.1.0'

``` r
orange <- query_tv("trump")
```

``` r
arrange(orange$station_histogram, value) %>% 
  mutate(station=factor(station, levels=station)) %>% 
  ggplot(aes(value, station)) +
  geom_lollipop(horizontal=TRUE, size=0.75,
                color=ggthemes::tableau_color_pal()(10)[2]) +
  scale_x_continuous(expand=c(0,0), label=scales::comma, limits=c(0,100000)) +
  labs(y=NULL, x="# Mentions",
       title="Station Histogram") +
  theme_hrbrmstr_msc(grid="X")
```

<img src="README_files/figure-markdown_github/unnamed-chunk-5-1.png" width="672" />

``` r
ggplot(orange$timeline, aes(date_start, value)) +
  geom_area(aes(group=station, fill=station), position="stack") +
  scale_x_datetime(name=NULL, expand=c(0,0)) +
  scale_y_continuous(name="# Mentions", label=scales::comma, limits=c(0, 8000), expand=c(0,0)) +
  ggthemes::scale_fill_tableau(name=NULL) +
  labs(title="Timeline") +
  theme_hrbrmstr_msc(grid="XY") +
  theme(legend.position="bottom") +
  theme(axis.text.x=element_text(hjust=c(0, 0.5, 0.5, 0.5, 0.5, 0.5)))
```

<img src="README_files/figure-markdown_github/unnamed-chunk-6-1.png" width="672" />

The following is dynamically generated from the query results. View the R Markdown to see the code.

#### FOX Business / Countdown to the Closing Bell With Liz Claman

<https://archive.org/details/FBC_20161025_190000_Countdown_to_the_Closing_Bell_With_Liz_Claman#start/3280/end/3315>

<!--html_preserve-->
<img src='https://archive.org/download/FBC_20161025_190000_Countdown_to_the_Closing_Bell_With_Liz_Claman/FBC_20161025_190000_Countdown_to_the_Closing_Bell_With_Liz_Claman.thumbs/FBC_20161025_190000_Countdown_to_the_Closing_Bell_With_Liz_Claman_000001.jpg'/><!--/html_preserve-->

> "\[cheering\] boy, this is a big crowd by the way. \[cheering\] a lot of people. this is a lot of people. 🍊. 🍊, 🍊, 🍊, 🍊."

### Test Results

``` r
library(newsflash)
library(testthat)

date()
```

    ## [1] "Wed Jan 25 22:55:49 2017"

``` r
test_dir("tests/")
```

    ## testthat results ========================================================================================================
    ## OK: 0 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ===================================================================================================================
