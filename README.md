
`newsflash` : Tools to Work with the Internet Archive and GDELT Television Explorer

Ref: <http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch>

> *"In collaboration with the Internet Archive's Television News Archive, GDELT's Television Explorer allows you to keyword search the closed captioning streams of the Archive's 6 years of American television news and explore macro-level trends in how America's television news is shaping the conversation around key societal issues. Unlike the Archive's primary Television News interface, which returns results at the level of an hour or half-hour "show," the interface here reaches inside of those six years of programming and breaks the more than one million shows into individual sentences and counts how many of those sentences contain your keyword of interest. Instead of reporting that CNN had 24 hour-long shows yesterday that mentioned Donald Trump, the interface here will count how many sentences uttered on CNN yesterday mentioned his name - a vastly more accurate metric for assessing media attention."*

An advantage of using this over the interactive selector & downloader is that you get tidy tibbles with this package, ready to use in R.

NOTE: While I don't claim that this alpha-package is anywhere near perfect, the IA/GDELT TV API coughs up blood every so often so when there are critical errors run the same query in their web interface before submitting an issue. I kept getting errors when searching all affiliate markets for the "mexican president" query that also generate errors on the web site when JSON is selected as output (it's fine on the web site if the choice is interactive browser visualizations). Submit those errors to them, not here.

NOTE: As of 2017-01-29 the API is not returning `keyword_primary` in the `query_details` field. It's not an error with this package.

The following functions are implemented:

-   `query_tv`: Issue a query to the TV Explorer
-   `top_text`: Helper function to extract the text snippets from the top matches as a tidytext-compatible tibble or plain character vector
-   `list_networks`: Helper function to identify station/network keyword and corpus date range for said market
-   `print.newsflash`: Helper print method for a nicer default text summary

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
library(ggalt)
library(hrbrthemes) # github 

# current verison
packageVersion("newsflash")
```

    ## [1] '0.4.1'

See what networks & associated corpus date ranges are available:

``` r
list_networks(widget=FALSE)
```

    ## # A tibble: 53 × 3
    ##                       keyword                             network                          date_range
    ##                         <chr>                               <chr>                               <chr>
    ## 1                    NATIONAL               All National Networks (See individual networks for dates)
    ## 2                     ALJAZAM                   Aljazeera America             (8/20/2013 - 4/13/2016)
    ## 3                   BLOOMBERG                           Bloomberg             (12/5/2013 - 2/16/2017)
    ## 4                        CNBC                                CNBC              (7/2/2009 - 2/16/2017)
    ## 5                         CNN                                 CNN              (7/2/2009 - 2/16/2017)
    ## 6                         FBC                        FOX Business             (8/20/2012 - 2/16/2017)
    ## 7                    FOXNEWSW                            FOX News             (7/16/2011 - 2/16/2017)
    ## 8                       MSNBC                               MSNBC              (7/2/2009 - 2/16/2017)
    ## 9               INTERNATIONAL          All International Networks (See individual networks for dates)
    ## 10                 BBCNEWSSEG                            BBC News              (1/1/2017 - 2/15/2017)
    ## 11                  AFFNETALL              All Affiliate Networks (See individual networks for dates)
    ## 12                 AFFNET_ABC              ABC Affiliate Stations              (7/2/2009 - 2/16/2017)
    ## 13                 AFFNET_CBS              CBS Affiliate Stations              (7/2/2009 - 2/16/2017)
    ## 14                 AFFNET_FOX              FOX Affiliate Stations              (7/3/2009 - 2/16/2017)
    ## 15                AFFNET_MYTV             MYTV Affiliate Stations            (12/11/2015 - 12/2/2016)
    ## 16                 AFFNET_NBC              NBC Affiliate Stations              (7/2/2009 - 2/16/2017)
    ## 17                 AFFNET_PBS              PBS Affiliate Stations             (7/14/2010 - 2/16/2017)
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
    ## 40     AFFMARKET_Philadelphia     Philadelphia Affiliate Stations              (6/6/2014 - 2/16/2017)
    ## 41       AFFMARKET_Portsmouth       Portsmouth Affiliate Stations               (1/6/2016 - 3/9/2016)
    ## 42           AFFMARKET_Pueblo           Pueblo Affiliate Stations              (1/19/2016 - 3/9/2016)
    ## 43          AFFMARKET_Raleigh          Raleigh Affiliate Stations             (1/13/2016 - 12/2/2016)
    ## 44             AFFMARKET_Reno             Reno Affiliate Stations               (1/1/2016 - 3/2/2016)
    ## 45          AFFMARKET_Roanoke          Roanoke Affiliate Stations              (1/26/2016 - 3/1/2016)
    ## 46    AFFMARKET_San Francisco    San Francisco Affiliate Stations             (7/14/2010 - 2/16/2017)
    ## 47   AFFMARKET_Shaker Heights   Shaker Heights Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 48       AFFMARKET_Sioux City       Sioux City Affiliate Stations             (10/13/2015 - 3/2/2016)
    ## 49   AFFMARKET_St. Petersburg   St. Petersburg Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 50            AFFMARKET_Tampa            Tampa Affiliate Stations              (1/6/2016 - 12/2/2016)
    ## 51   AFFMARKET_Virginia Beach   Virginia Beach Affiliate Stations               (1/7/2016 - 3/8/2016)
    ## 52    AFFMARKET_Washington DC    Washington DC Affiliate Stations              (7/2/2009 - 2/16/2017)
    ## 53         AFFMARKET_Waterloo         Waterloo Affiliate Stations            (10/19/2015 - 12/2/2016)

Basic search:

``` r
query_tv("clinton", "email", "AFFMARKALL")
```

    ## Query:
    ##    Primary keyword: clinton 
    ##   Context keywords: email 
    ##           Stations: AFFMARKALL 
    ##         Start date: 2009-06-03 
    ##           End date: 2017-02-16 
    ## 
    ## 230,748 timeline results from 82 stations:
    ## 
    ##   +--+--------------------+------------------*-+--------------------+-------------------+------+
    ## 8 +                                          *                                             *   +
    ## 6 +                                          *                                             *   +
    ##   |              *          *       *        *                 *                           *   |
    ## 4 +   * *        *   *      *       *        *                 * *                         *   +
    ## 2 +   * *        *   *     **     * *        *  **       *     * * **   *  *         * **  *   +
    ##   |   *** **   * *   ** *****    *****   *   *******     *** * * * ***  ** ***  **   **** **   |
    ## 0 +--+*******-************************-*************************-************************-**---+
    ##      0                   20                   40                   60                  80       
    ## Legend: 
    ## 1=ABC - Boston (WCVB), 2=ABC - Boston (WMUR), 3=ABC - Cedar Rapids (KCRG), 4=ABC - Charlotte (WS
    ## OC), 5=ABC - Cincinnati (WCPO), 6=ABC - Cleveland (WEWS), 7=ABC - Colorado Springs (KRDO), 8=ABC
    ##  - Columbia (WOLO), 9=ABC - Denver (KMGH), 10=ABC - Hampton (WVEC), 11=ABC - Las Vegas (KTNV), 1
    ## 2=ABC - Lynchburg (WSET), 13=ABC - Miami (WPLG), 14=ABC - Orlando (WFTV), 15=ABC - Philadelphia 
    ## (WPVI), 16=ABC - Reno (KOLO), 17=ABC - San Francisco (KGO), 18=ABC - Sioux City (KCAU), 19=ABC -
    ##  Tampa (WFTS), 20=ABC - Washington DC (WJLA), 21=CBS - Boston (WBZ), 22=CBS - Cedar Rapids (KGAN
    ## ), 23=CBS - Charlotte (WBTV), 24=CBS - Cincinnati (WKRC), 25=CBS - Colorado Springs (KKTV), 26=C
    ## BS - Columbia (WLTX), 27=CBS - Dakota Dunes SD (KMEG), 28=CBS - Denver (KCNC), 29=CBS - Des Moin
    ## es (KCCI), 30=CBS - Las Vegas (KLAS), 31=CBS - Miami (WFOR), 32=CBS - Norfolk (WTKR), 33=CBS - O
    ## rlando (WKMG), 34=CBS - Philadelphia (KYW), 35=CBS - Raleigh (WRAL), 36=CBS - Reno (KTVN), 37=CB
    ## S - Roanoke (WDBJ), 38=CBS - San Francisco (KPIX), 39=CBS - Shaker Heights (WOIO), 40=CBS - St. 
    ## Petersburg (WTSP), 41=CBS - Washington DC (WUSA), 42=FOX - Boston (WFXT), 43=FOX - Cedar Rapids 
    ## (KFXA), 44=FOX - Cleveland (WJW), 45=FOX - Columbia (WACH), 46=FOX - Dakota Dunes SD (KPTH), 47=
    ## FOX - Denver (KDVR), 48=FOX - Des Moines (KDSM), 49=FOX - Greenville (WHNS), 50=FOX - Las Vegas 
    ## (KVVU), 51=FOX - Newport KY (WXIX), 52=FOX - Orlando (WOFL), 53=FOX - Philadelphia (WTXF), 54=FO
    ## X - Raleigh (WRAZ), 55=FOX - Roanoke (WFXR), 56=FOX - San Francisco (KTVU), 57=FOX - Tampa (WTVT
    ## ), 58=FOX - Virginia Beach (WVBT), 59=FOX - Washington DC (WTTG), 60=MYTV - Las Vegas (KSNV), 61
    ## =NBC - Boston (WHDH), 62=NBC - Charlotte (WCNC), 63=NBC - Cincinnati (WLWT), 64=NBC - Cleveland 
    ## (WKYC), 65=NBC - Columbia (WIS), 66=NBC - Daytona Beach (WESH), 67=NBC - Denver (KUSA), 68=NBC -
    ##  Des Moines (WHO), 69=NBC - Goldsboro (WNCN), 70=NBC - Greenville (WYFF), 71=NBC - Miami (WTVJ),
    ##  72=NBC - Philadelphia (WCAU), 73=NBC - Portsmouth (WAVY), 74=NBC - Pueblo (KOAA), 75=NBC - Reno
    ##  (KRNV), 76=NBC - Roanoke (WSLS), 77=NBC - San Francisco (KNTV), 78=NBC - Sioux City (KTIV), 79=
    ## NBC - Tampa (WFLA), 80=NBC - Washington DC (WRC), 81=NBC - Waterloo (KWWL), 82=PBS - San Francis
    ## co (KQED)
    ## 
    ## 2,500 top query matches from the following shows:
    ## 
    ## Source: local data frame [476 x 3]
    ## Groups: station [69]
    ## 
    ##                       station                            show     n
    ##                         <chr>                           <chr> <int>
    ## 1  PBS - San Francisco (KQED)                    PBS NewsHour   144
    ## 2         ABC - Boston (WCVB)          Newscenter 5 Eyeopener    78
    ## 3  PBS - San Francisco (KQED) Washington Week With Gwen Ifill    50
    ## 4  CBS - San Francisco (KPIX)              KPIX 5 News at 5PM    43
    ## 5  CBS - San Francisco (KPIX)              KPIX 5 News at 5AM    38
    ## 6  CBS - San Francisco (KPIX)            KPIX 5 News at 600PM    38
    ## 7  CBS - San Francisco (KPIX)              KPIX 5 News at 6AM    37
    ## 8  CBS - San Francisco (KPIX)      KPIX 5 News  Early Edition    33
    ## 9   ABC - Philadelphia (WPVI)          Action News at 1230 PM    32
    ## 10         FOX - Tampa (WTVT)         Good Day Tampa Bay  9AM    31
    ## # ... with 466 more rows

The closed-caption text snippets are returned for the "top matches" (usually max 2,500 for a broad enough search) and you can extract them from the object directly with `x$top_matches$snippet` or use `top_text(x)`:

``` r
mex <- query_tv("mexican president", filter_network="NATIONAL")
top_text(mex)
```

    ## # A tibble: 197,168 × 4
    ##    station         show           show_date   word
    ##      <chr>        <chr>              <dttm>  <chr>
    ## 1     CNBC Street Signs 2016-09-30 08:00:00      i
    ## 2     CNBC Street Signs 2016-09-30 08:00:00    had
    ## 3     CNBC Street Signs 2016-09-30 08:00:00     to
    ## 4     CNBC Street Signs 2016-09-30 08:00:00  watch
    ## 5     CNBC Street Signs 2016-09-30 08:00:00     it
    ## 6     CNBC Street Signs 2016-09-30 08:00:00      a
    ## 7     CNBC Street Signs 2016-09-30 08:00:00 couple
    ## 8     CNBC Street Signs 2016-09-30 08:00:00     of
    ## 9     CNBC Street Signs 2016-09-30 08:00:00  times
    ## 10    CNBC Street Signs 2016-09-30 08:00:00     he
    ## # ... with 197,158 more rows

``` r
head(top_text(mex, tidy=FALSE))
```

    ## [1] "i had to watch it a couple of times. he was nervous. cat got his tongue whatever. trudeau, his neighbor in canada. the mexican president."                                                                                                                                                                                                                                                     
    ## [2] "selectselected care about the middle east be at the economic ones are understated because we will not have to shift so much capital abroad, everyone wants to buy foreign oil. ashley: the other issue is security. some have been undone or completely scrapped for the current mexican president. something that will not get resolved on this summit. the mexican president will push back."
    ## [3] "walk in, hey let's get to know each other. that is all he was ever going to do. except he was not consistent. it was never discussed. mexican president."                                                                                                                                                                                                                                      
    ## [4] "i'm sorry to cut you off. thank you very much. i appreciate you joining us. pint made. former mexican president fox."                                                                                                                                                                                                                                                                          
    ## [5] "we may have to rename it. it's going to be different. in mexico you can't succeed yourself. get to know him. the new mexican president."                                                                                                                                                                                                                                                       
    ## [6] "we may have to rename it. it's going to be different. in mexico you can't succeed yourself. get to know him. the new mexican president."

You can, of course, do other things with the various bits of data returned:

``` r
orange <- query_tv("trump")
```

``` r
arrange(orange$station_histogram, value) %>% 
  mutate(station=factor(station, levels=station)) %>% 
  ggplot(aes(value, station)) +
  geom_lollipop(horizontal=TRUE, size=0.75,
                color=ggthemes::tableau_color_pal()(10)[2]) +
  scale_x_continuous(expand=c(0,0), label=scales::comma, limits=c(0,400000)) +
  labs(y=NULL, x="# Mentions",
       title="Station Histogram") +
  theme_ipsum_rc(grid="X")
```

<img src="README_files/figure-markdown_github/unnamed-chunk-9-1.png" width="672" />

``` r
mutate(orange$timeline, date_start=as.Date(date_start)) %>% 
  filter(date_start >= as.Date("2015-01-01")) %>% 
  ggplot(aes(date_start, value)) +
  geom_area(aes(group=station, fill=station), position="stack") +
  scale_x_date(name=NULL, expand=c(0,0)) +
  scale_y_continuous(name="# Mentions", label=scales::comma, limits=c(0, 8000), expand=c(0,0)) +
  ggthemes::scale_fill_tableau(name=NULL) +
  labs(title="Timeline") +
  theme_ipsum_rc(grid="XY") +
  theme(legend.position="bottom") +
  theme(axis.text.x=element_text(hjust=c(0, 0.5, 0.5, 0.5, 0.5, 0.5)))
```

<img src="README_files/figure-markdown_github/unnamed-chunk-10-1.png" width="672" />

The following is dynamically generated from the query results. View the R Markdown to see the code.

#### CNBC / Squawk Box

<https://archive.org/details/CNBC_20090814_100000_Squawk_Box#start/10780/end/10815>

<!--html_preserve-->
<img src='https://archive.org/download/CNBC_20090814_100000_Squawk_Box/CNBC_20090814_100000_Squawk_Box.thumbs/CNBC_20090814_100000_Squawk_Box_000001.jpg'/><!--/html_preserve-->

> "that was part of this. that was a great name, you know. phenomenal. 🍊 people. 🍊 cars."

### Test Results

``` r
library(newsflash)
library(testthat)

date()
```

    ## [1] "Mon Feb 20 10:02:25 2017"

``` r
test_dir("tests/")
```

    ## testthat results ========================================================================================================
    ## OK: 0 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ===================================================================================================================
