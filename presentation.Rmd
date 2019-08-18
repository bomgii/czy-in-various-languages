---
author: "Ilia Uchitel"
date: '7 августа 2019 г '
title: "Czy in Ukrainian language"
output:
  html_document:
    toc: true
    toc_depth: 3
    toc_position: right
    toc_float: yes
    smooth_scroll: false
---


---


```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)

#spoiler css code

```{css, echo=FALSE}
.spoiler {
  visibility: hidden;
}

.spoiler::before {
  visibility: visible;
  content: "Spoiler alert! Hover me to see the answer."
}

.spoiler:hover {
  visibility: visible;
}

.spoiler:hover::before {
  display: none;
}


```


#Preliminaries

##The question under investigation
  <br>
In the Ukrainian language, as in Polish, Belorussian and Russian languages, there is a particle that may optionally mark  Yes/No questions - *чи*, *czy* and *ли*, respectively.  
<br>
    &nbsp;&nbsp;– *Чи ти , Стехо , здорова ?* 'Are you good, Stecha?' [Олександр Кониський:Наймичка,1874]  <p>
Which well could have looked like:<br>
	&nbsp;&nbsp;*Ти , Стехо , здорова?*
 <br>

It may not be used with Wh-Question words ('How', 'Why' and so on):
<br><br>
&nbsp;&nbsp;– *А ви чого, дурні, радієте?*	'But why are you happy, fouls?' [Олександр Кониський:Наймичка,1874]<br>
not: <br>
  &nbsp;&nbsp;– ~~*Чи ви чого , дурні , радієте?*~~ <br>

&nbsp;*Чи*, as its counterparts in other languages in the discussion, may be also used as a disjunctive connector (as *whether ... or* in English). 
<br>
<br>
&nbsp;The definitive reasons for the use of this particle in cases when it is not obligatory are not fully clear,  however, there seem to be regional, temporal and other biases in usage. In my analysis, I would like to explore these possible interactions.


##Data used

&nbsp;For this project, I used GRAC corpus: [Maria Shvedova, Ruprecht von Waldenfels, Sergiy Yarygin, Mikhail Kruk, Andriy Rysin, Michał Woźniak (2017-2018): GRAC: General Regionally Annotated Corpus of Ukrainian. Electronic resource: Kyiv, Oslo, Jena. Available at uacorpus.org].
<br>

&nbsp;From there, I extracted questions using the following CQL-query:

`<s> []{1,15} [word =="?"]`


&nbsp;Then, I wrote a python script to extract question particles, such as *А, Чи, Невже* from the questions. A sample output: 

```{r}
library(data.table)
library(knitr)
library(kableExtra)
library(DT)
library (ggplot2)
library(plotly)


sample_q_table <- fread('questions_table_sample.csv', encoding = 'UTF-8', header = T, sep = '\t',   fill=TRUE)
kable(sample_q_table) %>%
  kable_styling() %>%
  scroll_box(width = "90%", height = "200px")

```

###Comments on the data files used 

<p>
&nbsp;Below is the information about data files that were used to perform this research: both original data file produced by a python script (extract shown above) and the summary tables used for further plots (find interactive plots below).
<br>
**Author:** The writer of a given text.<p>
**Title:** The title of a given text.<p>
**Year:** The *publication* year of a given text.<p>
**Country:** The primary country of writer's activity. As of now, not used in the analysis.<p>
**Genre:** The genre of a text. Fiction texts represent the main share of our database, while poetry is excluded from it completely. <p>
**Region:** The main regions of author's activity, as filled by creators of GRAC corpus.<p>
**Citation** The question sentence extracted from GRAC corpus (kwic). In original outcome file, there are a lot of "false" dublicates, that is, identical strings for one title of a given author that doubled due to an unindentified error in GRAC engine. However, there sometimes were "true" dublicates, that is, identical questions found in one text,  such as *Невже це так*? In our calculations, we used only unique question strings, omitting both "false" and "true" dublicates. <p>
**Qword** Type of the question string, as determinded by the python script. <p>
 &nbsp;1.QWORD - Any type of  Wh-Word (*'how', 'where', 'why'* and so on) is found in the question string. Even if another question particle (*чи*, *невже* a so on) is present there, the question is assigned to QWORD and then eliminated from our analysis.<p>
 &nbsp;2.NOQWORD - Question without any question particle (counted in our analysis). <p>
 &nbsp;3.CZY - One instance of *Чи* particle found in the question string.<p>
 &nbsp;4.2CZY - Two or more instances of *Чи* found in the question string. This usually indicates usage of *чи* as a disjunctive marker (*'or'*), cf.:<p>
  *Чи він тільки сам урятувався , чи ще хто відступив ? 'Is it only him who escaped, or someone else managed to leave' (Петро Панч, Облога ночі)*<p> As of now, this usage is completely omitted from our analysis.<p>
 &nbsp;5.HIBA, Nevzhe - Rhetorical question particles *Невже* and *Хiба*. As of August '19 they haven't been studied within our analysis yet.  They can't be used together with *чи*, that is why in our analysis we count them as "NOQWORD" instances. <p>
  &nbsp;6.A - Emphasys particle *A*, that rarely can be used together with *Невже* or *Хiба*. In our analysis it is counted as "NOQWORD". <p>
 **ALLSUM:** Sum of all not-Wh-word questions, including *2CZY* questions with two *чи*, not included in all other calculations. This parameter is used for estimating the size of book processed for question extraction.  
 
<details open>
<summary>***Find more information about the Genre shares in our database***</summary>   <br>
Table of Genre attribution of each question token (not text) in our database. This data was imported from GRAC corpus.
```{r}

#Import database
all_merged_ALL <- fread('all_merged_1308_.csv', encoding = 'UTF-8', header = T, sep = ';',   fill=TRUE)

table(all_merged_ALL[,GENRE])
barplot(height = table(all_merged_ALL[,GENRE]))
```
<br>
ACA - Academical texts. <p>
CHI - Children literature.<p>
DIA - Diaries.<p>
ETH - Ethnographical works (the only author here is *Агатангел Кримський*).<p>
FIC - Fiction<p>
HIS - Historical literature.<p>
JOU - Journalism.<p>
LET - Letters.<p>
MEM - Memoirs.<p>
PRE - Speeches. <p>

<br>

</details>
&nbsp;As shown above, the vast majority of Genres represent FIC (Fiction), so no particular stress is given to GENRE feature, even though it is quite 
<p>
<br>

### The main metrics: *czyratio* and *czyperc*. 
&nbsp;There are two types of metrics used for this analysis.
<p>
  &nbsp;First, the *ratio* of questions with *чи* (*czyratio*). It was used for plots with the writer's birthyear employed as time-axis. The formula for it is: <p>
$$\frac{CZY}{\sum{NOQWORD+HIBA + NEVZHE + A}}$$
&nbsp;CZY questions are not included in the Sum in denominator in order to amplify the results. 

<p>

  &nbsp;The second metrics use was more traditional percent of *чи*-questions - *czyperc*. This metrics was used for plots with particular book titles used for time-axis.   The formula for this metrics is:
  $$\frac{CZY}{\sum{NOQWORD+HIBA + NEVZHE + A + CZY}}$$
<p>
&nbsp;Beware that 2CZY questions, those with *чи* as disjunctive connector, are excluded from denominators in both metrics, as the semantics of this use requires the obligatory use of *чи*. 
<p>
<br>
<br>

#Overview & Hypothesis


  &nbsp;A distinctive difference is found between a group of writers born in western Ukraine and central &southeastern regions. The most noticeable divergence is observed among the authors born in late XIX-century, with a productive period in 1920-1940ies. Their works demonstrate a much higher share of questions with czy than the texts by their peers from central &southeastern Ukraine. We suppose that this is due to a Polish influence, as in Polish the cognate particle czy is very common in not Wh-word questions. <p>
  &nbsp;However, the data of writers of the previous generation (around 1850) does not differ from the observations of their peers. That is quite peculiar, as the sociolinguistic situation in western  Ukraine was different from the one in eastern regions.  <p>
  &nbsp;Regarding the writers from central Ukraine, the general downward trend is vividly illustrated by a sharp decrease of czy-questions: from a common question particle in XIXth century, to one of a more marginal state in XXth century. In my opinion, this pattern reflects the similar process in the Russian language. 
<p> 
  &nbsp;However, in works by authors from central or southeastern Ukraine we may see that this process slowed down or even ended approximately around 1940. And share of questions with *чи* started to rise gradually. The individual lifespan data of selected authors (see below) demonstrate that such a trend existed in second part of XXth century.
<p>
&nbsp;The scatterplot depicting the connection between *czyperc* in individual titles (books) and year show a quite similar to a previous one picture, which is quite expected, as this metric is mainly a proxy of the authors one.

# Results
<br>

##Datafile by writer   

```{r results = 'asis'}
writerstable <- fread('full_writerstable3_with_years_utf_8.csv', encoding = 'UTF-8', header = T, sep = ',')
  datatable(head(writerstable, n = nrow(writerstable)), options = list(pageLength = 5)) 

#kable(writerstable_after1945) %>%
#  kable_styling() %>%
#  scroll_box(width = "90%", height = "200px")

```

<details open>
<summary>The code that was used to make the table above</summary>
<br>
`giant_ukrdata_after45_notTransl_table <- as.data.frame.matrix(table (giant_ukrdata_after45[QWORD!="QWORD"&TRANSLATOR=="",QWORD,by=AUTHOR]), keep.rownames = FALSE)
`
</details>


##Plots by writer

&nbsp;Our data shows that there is a regional &  bias in use of *чи* particle. The scatterplot below depicts the  between the birthyear of the author and proportion of questions with *чи*.


```{r results= 'asis', echo = TRUE}
ggplot(writerstable[BIRTHYEAR!="NA"&BIRTHYEAR!="TRANSL"&macroreg!="NA"], aes(x=as.double(BIRTHYEAR), y=as.double(czyratio), color=macroreg)) + geom_point() + ylim(0,1) +  stat_smooth(method = 'loess') 
```

<br>
You can explore the same plot as a interactive plot with extra data (writers born outside Ukraine or undetermined region of birth).
<p>
  <details>
  <summary>***Click here to see***</summary>
```{r results= 'asis', echo = TRUE}
wgplot <- ggplot(writerstable[BIRTHYEAR!="NA"&BIRTHYEAR!="TRANSL"], aes(x=as.double(BIRTHYEAR), y=as.double(czyratio), color=macroreg)) + geom_point(aes(text=sprintf("Author:%s<br>Birthyear:%s<br>Region of birth:%s<br>macroreg:%s", rn, BIRTHYEAR, Birthreg,macroreg))) + ylim(0,1) +  stat_smooth(method = 'loess')
ggplotly(wgplot)
```
</details>
<br>
&nbsp;If we make two separate plots with a linear regression line with a cutout point of year 1900, we may see two sepate trends clearer. <p>

<details open>
<summary>***Click here to see.***</summary>
<br>Born before 1900
```{r results= 'asis', echo = TRUE}
ggplot(writerstable[BIRTHYEAR!="NA"&BIRTHYEAR!="TRANSL"&macroreg!="NA"&BIRTHYEAR<1900], aes(x=as.double(BIRTHYEAR), y=as.double(czyratio), color=macroreg)) + geom_point() + ylim(0,1) +  stat_smooth(method = 'lm') 
```
<br>Born after 1900

```{r results= 'asis', echo = TRUE}
ggplot(writerstable[BIRTHYEAR!="NA"&BIRTHYEAR!="TRANSL"&macroreg!="NA"&BIRTHYEAR>1900], aes(x=as.double(BIRTHYEAR), y=as.double(czyratio), color=macroreg)) + geom_point() + ylim(0,1) +  stat_smooth(method = 'lm') 
```

</details>

##Datafile by title

<br>
Data:
```{r results = 'asis'}
#titletable <- fread('titlestable_all_u.csv', header = T, sep = ',')
titletable <- fread('titlestable_all_u2.csv', header = T, sep = ',')
  datatable(head(titletable, n = nrow(writerstable)), options = list(pageLength = 5)) 

#kable(writerstable_after1945) %>%
#  kable_styling() %>%
#  scroll_box(width = "90%", height = "200px")

```
<details>
<summary>R code used to produce this table</summary>
`
yeartable_all_years_merged_ALL <- as.data.frame.matrix(table (all_merged_ALL[QWORD!="QWORD"&TRANSLATOR==""&QWORD!=""&YEAR!="",QWORD,by=YEAR]), keep.rownames = FALSE)

\#adding titleyear 

all_merged_ALL[, titleyear := paste(TITLE, YEAR, sep = "-") ]


yeartable_all_years_merged_ALL_titles <- as.data.frame.matrix(table (all_merged_ALL[QWORD!="QWORD"&TRANSLATOR==""&QWORD!=""&YEAR!="",QWORD,by=list(titleyear)]), keep.rownames = FALSE)
yeartable_all_years_merged_ALL_titles <- as.data.table(yeartable_all_years_merged_ALL_titles,keep.rownames = TRUE)
\#renaming columns - unifying dataset
names(yeartable_all_years_merged_ALL_titles)[names(yeartable_all_years_merged_ALL_titles) == "titileyear"] = "titleyear" 

\#by title
yeartable_all_years_merged_ALL_titles_years <- all_merged_ALL[,unique(YEAR),by=list(titleyear,AUTHOR,GENRE)]

yeartable_all_years_merged_ALL_both <- merge(yeartable_all_years_merged_ALL_titles,yeartable_all_years_merged_ALL_titles_years,by="titleyear")

\#something new
\#
fwrtbl_part <- full_writerstable3_withyears[,c("rn","BIRTHYEAR","Birthreg","macroreg")]

names(fwrtbl_part)[names(fwrtbl_part) == "rn"] = "AUTHOR" 

yeartable_all_years_merged_ALL_both2 <- merge(yeartable_all_years_merged_ALL_both,fwrtbl_part,by="AUTHOR")

titlestable_all <- yeartable_all_years_merged_ALL_both2
titlestable_all$N <- NULL

titlestable_all_u <- titlestable_all[!duplicated(titlestable_all[,c('AUTHOR','titleyear')]),]

\#SAVE such a great dataset
write.csv(titlestable_all_u, file = "titlestable_all_u2.csv", row.names = F)
titlestable_all_u <- fread ("titlestable_all_u2.csv", sep = ',')


\#adding genre
genre_table_by_title <- all_merged_ALL[,unique(titleyear),by=list(GENRE)]

names(genre_table_by_title)[names(genre_table_by_title) == "PUBYEAR"] = "titleyear" 


titlestable_all_u_bygenre <- merge(titlestable_all_u,genre_table_by_title, by="titleyear")
names(titlestable_all_u_bygenre)[names(titlestable_all_u_bygenre) == "GENRE.x"] = "GENRE" 


\#adding czyperc and correct sum - input table may be titlestable_all_u or titlestable_all_u_bygenre


titlevec_correct <-  as.vector(titlestable_all_u$titleyear)

for (tttitle in titlevec_correct){
  ttl <- titlestable_all_u[titleyear==tttitle]
  no_czy_sum <- NULL
  no_czy_sum <- sum(ttl[1,4:9])
  czyperc_ttl <- ttl[1,5]/no_czy_sum
  titlestable_all_u[titleyear==tttitle, czyperc:=czyperc_ttl]
  titlestable_all_u[titleyear==tttitle, ALLSUM:=sum(titlestable_all_u[titleyear==tttitle,3:9])]
}
\#remove antologies with several authors
titlestable_all_u_bygenre <- titlestable_all_u_bygenre[titleyear!="Свідчення очевидців Голоду. Том ІІІ-1985"]

write.csv(titlestable_all_u, "titlestable_all_u2",row.names = F)
`
</details>

##Plots by title

Interactive scatterplot showing texts  having, in total, more than 30 questions without Wh-words and written by authors born in Ukraine. 
```{r results= 'asis', echo = TRUE}
titlegplot <- ggplot(titletable[BIRTHYEAR!="NA"&BIRTHYEAR!="TRANSL"&macroreg!="NA"&ALLSUM>30], aes(x=as.double(PUBYEAR), y=as.double(czyperc), color=macroreg)) + geom_point(aes(text=sprintf("Author:%s<br>Birthyear:%s<br>macroreg:%s<br>Title: %s<br>Genre: %s", AUTHOR, BIRTHYEAR, macroreg, titleyear, GENRE))) + ylim(0,0.6) +  stat_smooth(method = 'loess')
ggplotly(titlegplot)

```

<br>
Another Interactive plot by title without regression line and with eased filter (ALLSUM>10, that is, all texts with more than 10 not-Wh-word questions) and including authors with NA in "Birthreg", mainly from outside Ukraine.

<p> *You can zoom this plot by using "Zoom" or "Box select"  tool.*
<details>
<summary>***Click here to see***</summary>
```{r}
plot_ly(titletable[BIRTHYEAR!=""&BIRTHYEAR!="TRANSL"&ALLSUM>10], x = ~ BIRTHYEAR, y = ~czyperc, color = ~macroreg, text = ~paste("Writer:",AUTHOR,"<br>Title & Publication year: ", titleyear, '<br>Region of Birth:', Birthreg, '<br>Number of questions without Wh-Words:',ALLSUM), size = ~ALLSUM, type = "scatter") 
```
</details>

##Individual scatterplots  by author.
We may investigate not the general trend over the region, but the individual authors' lifespan change of the use of *чи* particle. 
<p>
For that, we choose texts of the size larger than 30 not-Wh-word questions (ALLSUM>30) to minimize the error with calculating *czyperc*. Then, we made scatterplots for the authors who have more than 5 such texts - to be able to say something about their lifespan change. There were 22 such authors in total. The data shows that, generally, the level of questions with *чи* remains more or less constant over the lifespan of a writer.
<p>
  However, there are some notable exceptions. First of all, it is *Ivan Nechuy-Levitsky*, whose works consistently show the downward trend for *чи* particle use. The similar falling trendline is to see in works by *Ivan Karpenko-Karyi*. They both are quite similar, as they were born before 1850 (1838 and 1845, respectively) in rural communities. We may speculate that this trend reflects a general tendency of closeness to spoken language. 
<p>
  Another clear example of a lifespan change is *Oles Honchar*. His numerous works demonstrate clear upward trend, amplified by a striking example of the volumes of his diaries, dated from  1965 to 1993 which distinctly form the upward trend  for the *чи* use.

<br>
You may see all 22 individual writer scatterplots below. Note that in order to see the key for the scatterplot (author's name, Birthreg & so on) you should put your mouse over the point in the scatterplot.
<p>
<details>
<summary>***Click here to see. You may need to zoom in and than out the whole page in your browser to display the plots correctly.***</summary>
```{r}
freqtitletabl <- table(titletable[ALLSUM>30,AUTHOR])
freqtitletabl <- as.data.table(freqtitletabl)
freqtitletabl_vec <- as.vector(freqtitletabl[N>5,V1])

print(freqtitletabl_vec)

l <- htmltools::tagList()

for(f_writer in freqtitletabl_vec)
{
#print(f_writer)
#print(unique(titletable[AUTHOR==f_writer,macroreg]))
#print(unique("year_born"))
#print(unique(titletable[AUTHOR==f_writer,BIRTHYEAR]))
authorgplt <- ggplot(titletable[AUTHOR==f_writer&ALLSUM>30], aes(x=as.double(PUBYEAR), y=as.double(czyperc), color=ALLSUM)) + geom_point(aes(text=sprintf("Author:%s<br>Birthyear:%s<br>macroreg:%s<br>Title: %s<br>Genre: %s", AUTHOR, BIRTHYEAR, macroreg, titleyear, GENRE)))  + ylim(0,0.5) +  stat_smooth(method = 'lm') + scale_color_gradient(low="blue", high="red")
l[[f_writer]]  <- ggplotly(authorgplt)
}
l

```
</details>

##Plots by genre

<p>
&nbsp;The table   below demonstrates the genre distribution in our dataset. As noted above, in "Preliminaries" section, the superiority of Fiction genre and consequent lack of observations (in this case, writers active in writing books in a given genre) does not allow us to draw a definitive conclusion, however *some* genre bias is quite clear: Academical works (including Historical) and Journalistic texts are more prone to use *чи*.
```{r, echo=TRUE}
for (ggenre in c("ACA","CHI","DRA","FIC","HIS","JOU","MEM")){
  glen <- length(table(all_merged_ALL[GENRE==ggenre,AUTHOR]))
  print(paste("Number of authors in ", ggenre, " genre: ",glen,sep = ""))
}
ggplot(titletable[GENRE!="LET"&GENRE!="NA"&GENRE!="PRE"&GENRE!="DIA"&GENRE!="ETH"], aes(x=as.factor(GENRE), y=czyperc)) + geom_boxplot(outlier.shape = 19)
```