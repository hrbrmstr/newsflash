
`newsflash` : Tools to Work with the Internet Archive and GDELT Television Explorer

Ref: <http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch>

> *"In collaboration with the Internet Archive's Television News Archive, GDELT's Television Explorer allows you to keyword search the closed captioning streams of the Archive's 6 years of American television news and explore macro-level trends in how America's television news is shaping the conversation around key societal issues. Unlike the Archive's primary Television News interface, which returns results at the level of an hour or half-hour "show," the interface here reaches inside of those six years of programming and breaks the more than one million shows into individual sentences and counts how many of those sentences contain your keyword of interest. Instead of reporting that CNN had 24 hour-long shows yesterday that mentioned Donald Trump, the interface here will count how many sentences uttered on CNN yesterday mentioned his name - a vastly more accurate metric for assessing media attention."*

The following functions are implemented:

-   `query_tv`: Issue a query to the TV Explorer
-   `list_networks`: Helper function to identify station/network keyword and corpus date range for said market

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

    ## [1] '0.2.0'

See what networks & associated corpus date ranges are available:

``` r
list_networks(widget=FALSE)
```

    ## # A tibble: 53 × 3
    ##                       keyword                             network                          date_range
    ##                         <chr>                               <chr>                               <chr>
    ## 1                    NATIONAL               All National Networks (See individual networks for dates)
    ## 2                     ALJAZAM                   Aljazeera America             (8/20/2013 - 4/13/2016)
    ## 3                   BLOOMBERG                           Bloomberg             (12/5/2013 - 1/25/2017)
    ## 4                        CNBC                                CNBC              (7/2/2009 - 1/25/2017)
    ## 5                         CNN                                 CNN              (7/2/2009 - 1/25/2017)
    ## 6                         FBC                        FOX Business             (8/20/2012 - 1/25/2017)
    ## 7                    FOXNEWSW                            FOX News             (7/16/2011 - 1/24/2017)
    ## 8                       MSNBC                               MSNBC              (7/2/2009 - 1/24/2017)
    ## 9               INTERNATIONAL          All International Networks (See individual networks for dates)
    ## 10                 BBCNEWSSEG                            BBC News              (1/1/2017 - 1/25/2017)
    ## 11                  AFFNETALL              All Affiliate Networks (See individual networks for dates)
    ## 12                 AFFNET_ABC              ABC Affiliate Stations              (7/2/2009 - 1/25/2017)
    ## 13                 AFFNET_CBS              CBS Affiliate Stations              (7/2/2009 - 1/25/2017)
    ## 14                 AFFNET_FOX              FOX Affiliate Stations              (7/3/2009 - 1/25/2017)
    ## 15                AFFNET_MYTV             MYTV Affiliate Stations            (12/11/2015 - 12/2/2016)
    ## 16                 AFFNET_NBC              NBC Affiliate Stations              (7/2/2009 - 1/25/2017)
    ## 17                 AFFNET_PBS              PBS Affiliate Stations             (7/14/2010 - 1/25/2017)
    ## 18                 AFFMARKALL               All Affiliate Markets (See individual networks for dates)
    ## 19           AFFMARKET_Boston           Boston Affiliate Stations             (9/30/2015 - 12/2/2016)
    ## 20     AFFMARKET_Cedar Rapids     Cedar Rapids Affiliate Stations            (10/19/2015 - 12/2/2016)
    ## 21        AFFMARKET_Charlotte        Charlotte Affiliate Stations              (2/9/2016 - 3/23/2016)
    ## 22       AFFMARKET_Cincinnati       Cincinnati Affiliate Stations              (1/6/2016 - 3/23/2016)
    ## 23        AFFMARKET_Cleveland        Cleveland Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 24 AFFMARKET_Colorado Springs Colorado Springs Affiliate Stations              (1/19/2016 - 3/9/2016)
    ## 25         AFFMARKET_Columbia         Columbia Affiliate Stations             (12/28/2015 - 3/2/2016)
    ## 26  AFFMARKET_Dakota Dunes SD  Dakota Dunes SD Affiliate Stations             (10/13/2015 - 3/2/2016)
    ## 27    AFFMARKET_Daytona Beach    Daytona Beach Affiliate Stations              (1/6/2016 - 3/23/2016)
    ## 28           AFFMARKET_Denver           Denver Affiliate Stations              (1/1/2016 - 12/2/2016)
    ## 29       AFFMARKET_Des Moines       Des Moines Affiliate Stations             (10/14/2015 - 3/2/2016)
    ## 30           AFFMARKET_Durham           Durham Affiliate Stations             (1/13/2016 - 3/23/2016)
    ## 31        AFFMARKET_Goldsboro        Goldsboro Affiliate Stations             (1/13/2016 - 12/2/2016)
    ## 32       AFFMARKET_Greenville       Greenville Affiliate Stations             (12/28/2015 - 3/2/2016)
    ## 33          AFFMARKET_Hampton          Hampton Affiliate Stations               (1/6/2016 - 3/9/2016)
    ## 34        AFFMARKET_Las Vegas        Las Vegas Affiliate Stations            (12/11/2015 - 12/2/2016)
    ## 35        AFFMARKET_Lynchburg        Lynchburg Affiliate Stations              (1/26/2016 - 3/1/2016)
    ## 36            AFFMARKET_Miami            Miami Affiliate Stations              (1/6/2016 - 3/23/2016)
    ## 37       AFFMARKET_Newport KY       Newport KY Affiliate Stations              (1/6/2016 - 3/23/2016)
    ## 38          AFFMARKET_Norfolk          Norfolk Affiliate Stations               (1/6/2016 - 3/9/2016)
    ## 39          AFFMARKET_Orlando          Orlando Affiliate Stations              (1/6/2016 - 3/23/2016)
    ## 40     AFFMARKET_Philadelphia     Philadelphia Affiliate Stations              (6/6/2014 - 1/25/2017)
    ## 41       AFFMARKET_Portsmouth       Portsmouth Affiliate Stations               (1/6/2016 - 3/9/2016)
    ## 42           AFFMARKET_Pueblo           Pueblo Affiliate Stations              (1/19/2016 - 3/9/2016)
    ## 43          AFFMARKET_Raleigh          Raleigh Affiliate Stations             (1/13/2016 - 12/2/2016)
    ## 44             AFFMARKET_Reno             Reno Affiliate Stations               (1/1/2016 - 3/2/2016)
    ## 45          AFFMARKET_Roanoke          Roanoke Affiliate Stations              (1/26/2016 - 3/1/2016)
    ## 46    AFFMARKET_San Francisco    San Francisco Affiliate Stations             (7/14/2010 - 1/25/2017)
    ## 47   AFFMARKET_Shaker Heights   Shaker Heights Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 48       AFFMARKET_Sioux City       Sioux City Affiliate Stations             (10/13/2015 - 3/2/2016)
    ## 49   AFFMARKET_St. Petersburg   St. Petersburg Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 50            AFFMARKET_Tampa            Tampa Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 51   AFFMARKET_Virginia Beach   Virginia Beach Affiliate Stations               (1/7/2016 - 3/8/2016)
    ## 52    AFFMARKET_Washington DC    Washington DC Affiliate Stations              (7/2/2009 - 1/25/2017)
    ## 53         AFFMARKET_Waterloo         Waterloo Affiliate Stations            (10/19/2015 - 12/2/2016)

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

<img src="README_files/figure-markdown_github/unnamed-chunk-6-1.png" width="672" />

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

<img src="README_files/figure-markdown_github/unnamed-chunk-7-1.png" width="672" />

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

    ## [1] "Thu Jan 26 10:26:47 2017"

``` r
test_dir("tests/")
```

    ## testthat results ========================================================================================================
    ## OK: 0 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ===================================================================================================================
