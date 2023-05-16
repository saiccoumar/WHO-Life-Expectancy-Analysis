# WHO Life Expectancy Analysis in SAS

<p align="center">
<img width="75%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/64dee3da-ae63-47e4-bed8-5b5d55fc00a0">
	<em>https://en.wikipedia.org/wiki/SAS_Institute</em>
</p>

An analysis of the Kaggle WHO life expectancy dataset<br />
by Sai Coumar<br />
Dataset: https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who
<br />
## Introduction:
Welcome to my analysis of the WHO Life Expectancy Dataset by @KUMARRAJARSHI on Kaggle! This report doesn't aim to derive substantial takeaways but rather to display the capacity of SAS in the context of data analysis and exploration. Within this report I'm going to go through the process of importing data, exploring it's features, subsetting data, visualizing data, exploring relationships, and exporting data using SAS. SAS is a very versatile and vast software, and I wanted to cover some common tasks that can be performed in SAS for data analytics. 

## Imports and Previews
To begin, the first thing I did was declare a library and a path variable. Declaring these at the beginning allows SAS to have quick access to it's directory to save and access files in modular units. Did I make use of this as much as I should have? Absolutely not. Would I make use of this feature if I was a government organization building massive data engineering pipelines? Probably. I tend to include this as good practice in any SAS program. 

```
libname homework base "path\homework";
%let path=\path\homework;
```

I then imported my data from kaggle using proc import and the required options for a CSV file.

```
proc import 
	datafile="\path\lifeExpectancyData.csv" 
	dbms=csv out=lifeExpectancy replace;
	guessingrows=max;
run;
```

## Preliminary Exploration
Now we have our dataset set as lifeExpectancy. We'll access our data a lot with this. To find out more about the variables in our data I ran proc contents on lifeExpectancy.

```
proc contents data=lifeExpectancy varnum;
run;
```

<p align="center">
	<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/32d1a1ce-a338-40e5-9ab6-c710a658d2cd"> <br />
	<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/e0adb1d9-e4da-4ceb-bcd0-0d3b0f5d9689"> <br />
</p>
Proc contents gives us some information about the size of the dataset (2938) and the number of variables (22) as well as telling us about the variables we have available to look at. SAS' proc contents is pretty unique in that it also gives us some information that isn't usually directly available with other statistical tools; for example proc contents tells us about the metadata of the data as well as the directory we're working in (which I've blurred out for privacy). The next point of interest is looking at the maximums and minimums of some key variables. 

```
proc means data=lifeExpectancy max min;
	var gdp population year;
run;
```

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/4a09b921-d6e7-4aa9-877c-ae2d2cc4721a"> 
</p>

Running proc means with the max and min options gives us the max and min of GDP, Population, and the year. From this we can see that the data ranges across the years 2000-2015, but the GDP and Population are setting off some massive red flags. The minimum population is 34 which makes no sense because the country with the smallest population is the Vatican city with a population of 800. The minimum GDP is only 1.68. Unless the units of GDP are not in single dollars, this doesn't add up either. This was my first sign that the data isn't particularly reliable or viable for substantial statistical conclusions about the world. Later on I realized a lot of the data didn't add up like total deaths from certain diseases in certain years. Earlier I mentioned that the purpose of the report is to explore SAS and not to use this for real world statistical takeaways and this is why. Unfortunately preprocessed data can be difficult to work with.

I decided to sort my data now and export it for later use. Sorting by country and year organized my data in a way I found useful throughout the rest of my analysis. I also exported this data and it can be viewed on the repository in the table_output folder.

```
proc sort data=lifeExpectancy out=sorted_life_expectancy; /*15d*/
	by Country descending Year;
run;

proc export data=sorted_life_expectancy
    outfile='\path\homework\sorted_life_expectancy.csv'
    dbms=CSV replace;
run;
```

I ran proc means 3 times on this sorted data to look at key statistics per country on the range of the years on the variables related to mortality, diseases, social factors, and health. These summary statistics can be viewed on the repository in the table_output folder.

```
proc means data=sorted_life_Expectancy min max median maxdec=2; 
	class country;
	ways 1; 
	var life_expectancy infant_deaths
		adult_mortality under_five_deaths;
	format maximum_var minimum_var median_var 6.2;
	output out=summary_statistics_mortality
    max=maximum_var
    min=minimum_var
    median=median_var;
run;

proc means data=sorted_life_Expectancy min max median maxdec=2; 
	class country;
	ways 1; 
	var diphtheria hepatitis_b measles polio _hiv_aids;
	format maximum_var minimum_var median_var 6.2;
	output out=summary_statistics_disease
    max=maximum_var
    min=minimum_var
    median=median_var;
run;

proc means data=sorted_life_Expectancy min max median maxdec=2; 
	class country;
	ways 1; 
	var GDP income_composition_of_resources 
		population schooling total_expenditure
		percentage_expenditure;
	format maximum_var minimum_var median_var 6.2;
	output out=summary_statistics_socialfactors
    max=maximum_var
    min=minimum_var
    median=median_var;
run;

proc means data=sorted_life_Expectancy min max median maxdec=2; 
	class country;
	ways 1; 
	var alcohol _bmi _thinness_5_9_years _thinness__1_19_years;
	format maximum_var minimum_var median_var 6.2;
	output out=summary_statistics_health
    max=maximum_var
    min=minimum_var
    median=median_var;
run;
```
## Subsetting and Manipulating Data

I was interested in using SQL within SAS and at this point I also wanted to investigate a relevant subset. I picked Zambia and looked at some variables over the course of 2000-2015 years. 
```
proc sql;
create table zambia as /*12a*/
select country, year, life_expectancy, alcohol, adult_mortality, infant_deaths, under_five_deaths 
	from lifeExpectancy
		where country='Zambia' /*12b*/
			order by year, life_expectancy; /*12c*/
quit;
```

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/776d4bab-527b-4583-bf4e-d6c951cee3f2"> 
</p>

This data is much more digestible than a wall of unprocessed data. Under-five-deaths and infant deaths noticeably declined over the course of 15 years while life expectancy increased. Adult mortality had some dramatic increases and decreases.

SQL was fun but to do this more programatically it's way easier to just use native SAS features. I used a data step and a select-when statement to subset the sorted_life_expectancy into the 3 North American Countries. I also took advantage of the data step to apply numeric and character functions to modify the data in desirable ways. and create total columns via the retain statement. The three outputted CSVs can be viewed on the repository in the table_output folder.


```

data processed_empty;
   set sorted_life_expectancy;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run;

data usa canada mexico;
	set processed_empty;
		life_expectancy = ceil(life_expectancy);
		adult_mortality = floor(adult_mortality);
		percentage_expenditure = round(percentage_expenditure,2);
		alcohol = int(alcohol);
		missing_gdp = nmiss(gdp);
		put missing_gdp=;
		missing_status = cmiss(status);
		put missing_status=;
		death_by_disease = sum(Hepatitis_B, Measles, Polio, Diphtheria, _HIV_AIDS);
		deadliest_disease_value = min(Hepatitis_B, Measles, Polio, Diphtheria, _HIV_AIDS);
		array diseases(*) Hepatitis_B Measles Polio Diphtheria _HIV_AIDS;
		deadliest_disease_index = whichn(deadliest_disease_value, of diseases(*));
		deadliest_disease = vname(diseases(deadliest_disease_index));
		keep country year life_expectancy 
		adult_mortality percentage_expenditure alcohol 
		death_by_disease deadliest_disease;
	select (country); 
		when('United States of America')
			do;
				output usa; 
			end;
		when('Canada')
			do;
				output canada;
			end;
		when('Mexico')
			do;	
				output mexico;
			end;
		otherwise 
			do;
				put country; 
				putlog "the GDP of this country is";
				put gdp; 
			end;
	end;
run;


proc export data=usa
    outfile='\path\homework\usa.csv'
    dbms=CSV replace;
run;

proc export data=mexico
    outfile='\path\homework\mexico.csv'
    dbms=CSV replace;
run;

proc export data=canada
    outfile='\path\homework\canada.csv'
    dbms=CSV replace;
run;
```

SAS makes subsetting and processing the data into a narrowed scope of the original data incredibly easy and efficient. I decided to make a similar subset of the data based on diseases per country and then per year. The three outputted disease table can be viewed on the repository in the table_output folder.


```
data diseases_country;
	set sorted_life_expectancy(keep=country year diphtheria
		hepatitis_b measles polio _hiv_aids);
		by country;
		retain diphtheria_total 0;
		retain hepatitis_total 0;
		retain measles_total 0;
		retain polio_total 0;
		retain hiv_aids_total 0;
		if not missing(diphtheria) then diphtheria_total = diphtheria_total + diphtheria;
		if not missing(hepatitis_b) then hepatitis_total = hepatitis_total + hepatitis_b;
		if not missing(measles) then measles_total = measles_total + measles;
		if not missing(polio) then polio_total = polio_total + polio;
		if not missing(_hiv_aids) then hiv_aids_total = hiv_aids_total + _hiv_aids;
		if last.country then do;
			output;
			diphtheria_total=0;
			hepatitis_total=0;
			measles_total=0;
			polio_total=0;
			hiv_aids_total=0;
		end;
		drop diphtheria hepatitis_b measles polio _hiv_aids;
		format diphtheria_total hiv_aids_total measles_total polio_total hiv_aids_total comma12.2;
		keep country diphtheria_total hiv_aids_total measles_total polio_total hiv_aids_total;
run;


data diseases_year;
	set sorted_by_year(keep=country year diphtheria
		hepatitis_b measles polio _hiv_aids);
		by year;
		retain diphtheria_total 0;
		retain hepatitis_total 0;
		retain measles_total 0;
		retain polio_total 0;
		retain hiv_aids_total 0;
		if not missing(diphtheria) then diphtheria_total = diphtheria_total + diphtheria;
		if not missing(hepatitis_b) then hepatitis_total = hepatitis_total + hepatitis_b;
		if not missing(measles) then measles_total = measles_total + measles;
		if not missing(polio) then polio_total = polio_total + polio;
		if not missing(_hiv_aids) then hiv_aids_total = hiv_aids_total + _hiv_aids;
		if last.year then 
		do;
			output;
			diphtheria_total=0;
			hepatitis_total=0;
			measles_total=0;
			polio_total=0;
			hiv_aids_total=0;
		end;
		drop diphtheria hepatitis_b measles polio _hiv_aids;
		format diphtheria_total hiv_aids_total measles_total polio_total hiv_aids_total comma12.2;
		keep year diphtheria_total hiv_aids_total measles_total polio_total hiv_aids_total;
run;

proc export data=diseases_country
    outfile='\path\homework\diseases_country.csv'
    dbms=CSV replace;
run;

proc export data=diseases_year
    outfile='\path\homework\diseases_year.csv'
    dbms=CSV replace;
run;
```

Our subsetted data for diseases help us compare changes in disease death rates either geographically or chronologically. For example, when looking at disease over the years, we can see that HIV and AIDS decreased from 463 to 120.9, whereas diphtheria increased from 13,253 to 15,488-a notable pattern that might be attributed to changes in modern medicine. 

## Formatting Key Variables

Next I wanted to look at relationships between variables using a frequency table. However my data could use some formatting for convenience of interpretation. Using chatGPT I created a list of country codes to format the country names with and I imported this format table. I also hardcoded some formats for status and life expectancy. 

```
proc import 
	datafile="\path\homework\formats.csv" 
	dbms=csv out=country_code replace;
	guessingrows=max;
run;
	
proc format cntlin=country_code library=homework;
	select fmtname start label;
run;

proc format library=homework; /*22a*/
	value $abbreviatedDevelopment
		'Developed' = 'D'
		'Developing' = 'ND';
run;

proc format library=homework; /*22b*/
	value lifeLength
		low - 45 = 'low'
		45<-70='average'
		70<-high='high';
run;

options fmtsearch=(homework);
```

## Frequency Tables
With our variables formatted we can start looking relationships between variables. I decided to look at the relationship between life expectancy and status as well as the relationship between life expectancy and country. I used the options norow nocol nocum nofreq to show me only the percentage of the total elements that fit the descriptor of the column and the row (for example there were 0.65% of elements that were undeveloped and had low life expectancies)

```
proc freq data=sorted_life_expectancy;
	format life_expectancy lifeLength.;
	format status $abbreviatedDevelopment.;
	tables life_expectancy*status / norow nocol nocum nofreq;
run;
proc freq data=sorted_life_expectancy;
	format country $Countrycode.;
	format life_expectancy lifeLength.;
	tables life_expectancy*country / norow nocol nocum nofreq;
run;
```

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/6ffb9399-5948-4c27-af6f-1327390e3e93"> 
</p>

Pictured here is the frequency table of life expectancy and status. The life expectancies frequencies were skewed heavily to average and high (by my custom parameters) and more towards undeveloped countries rather than developed, and there were 10 missing elements that couldn't be used in the frequency table. The frequency table for the countries was a bit large so I couldn't fit it in a screenshot. Also notice that the elements are formatted with my custom formats lifeLength and abbreviatedDevelopment. Without these formats the frequency table would be unreadable.

## Visualizations
In order to visualize the data I used proc sgpanel. I wanted to look at histograms and box plots to view the distributions of the variables, but I didn't want to manually copy and paste proc sgpanel over and over. To programmatically use proc sgpanel I used macro variables and a do loop within a function. In SAS this is a bit of a pain and the SAS compiler doesn't play well with macro variables. If there happens to be a bug or a missing %end then I had to restart the entire SAS session to debug it. I ended up doing this 4 times for this small block of code.

```

%macro do_visualize(dsname=, varlist=, procstmt=);
	%local i varname;
	%let varcount = %sysfunc(countw(&varlist.));
	%let proccount = %sysfunc(countw(&procstmt.));
	%do j = 1 %to &proccount.;
		%do i = 1 %to &varcount.;
			%let varname = %scan(&varlist.,&i.);
			%let procname = %scan(&procstmt.,&j.);
			proc sgpanel data=sorted_life_expectancy;
 				panelby status /
    			uniscale=row;
 				&procname. &varname.;
			run;
		%end;
	%end;
%mend;

run;
%do_visualize(dsname=sorted_life_expectancy, varlist=adult_mortality alcohol diphtheria
	gdp hepatitis_b income_composition_of_resources
	life_expectancy measles polio
	population schooling total_expenditure
	_bmi _hiv_aids 
	_thinness_5_9_years _thinness__1_19_years 
	infant_deaths percentage_expenditure under_five_deaths,procstmt=histogram);
%do_visualize(dsname=sorted_life_expectancy, varlist=adult_mortality alcohol diphtheria
	gdp hepatitis_b income_composition_of_resources
	life_expectancy measles polio
	population schooling total_expenditure
	_bmi _hiv_aids 
	_thinness_5_9_years _thinness__1_19_years 
	infant_deaths percentage_expenditure under_five_deaths,procstmt=vbox);
```


<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/13b8db1b-9c40-4561-bc5c-92f049bbaccb"> 
</p>

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/82eee46f-932c-4368-a769-ded868f7878a"> 
</p>


For my plots, I chose to draw plots split based on the status of the element. Pictured above are the histogram and box plot for income_composition_of_resources as an example. Similar graphs were outputted for all variables specified in the varlist parameter of the do_visualize function. The distribution of income_composition_of_resources is evidently left-skewed and has very few outliers. 

<br />

These distributions were useful for checking normality assumptions for statistical tests, but to build a visual narrative I did some processing on the yearly disease fatalities subset of the data. I used retain statements and an explicit output statements to get the total deaths by disease and then converted the wide table of disease death counts to a narrow one with multiple explicit output statements. Converting a table from wide to narrow is apparently a pretty common thing people do in SAS. 

```

data diseases_year_summed;
	set diseases_year;
		by year;
		retain diphtheria_sum 0;
		retain measles_sum 0;
		retain polio_sum 0;
		retain hiv_aids_sum 0;
		diphtheria_sum + diphtheria_total;
		measles_sum + measles_total;
		polio_sum+polio_total;
		hiv_aids_sum + hiv_aids_total;
		drop diphtheria_total measles_total polio_total hiv_aids_total;
		if (year=2015) then output;
run;

data pie_chart(keep=disease deaths);
	set diseases_year_summed;
	disease = 'diphtheria';
	deaths = diphtheria_sum;
	output;
	disease = 'measles';
	deaths = measles_sum;
	output;
	disease = 'polio';
	deaths = polio_sum;
	output;
	disease = 'hiv_aids';
	deaths = hiv_aids_sum;
	output;
run;
```

I then made pie charts using this processed data. I made two for convenience: one labeled with the disease and their counts in 2d and one that only had percentages in 3d. 

```
proc gchart data=pie_chart;
	pie disease / other=0  sumvar=deaths;
run;

proc gchart data=pie_chart;
	pie3d disease / other=0 value=none sumvar=deaths percent=arrow;
run;
```

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/a0ed3b14-928b-47c7-9e52-54c1b4d507a4"> 
</p>

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/7245fec0-dffd-47f4-977b-5eaa1fa69a0e"> 
</p>

Measles deaths far outnumber any other disease over this 15 year time span. 

<br />
## Correlations
Throughout this report I've been looking at indicators for relationships but now it's time to look at some statistical correlations. SAS makes this super easy with the proc corr feature to allow us to look at the pearson coefficients. 

```
proc corr data=sorted_life_expectancy out=correlation_matrix;
run;
```


<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/bff0d44f-dfdc-467d-97d5-8c7be6556c24"> 
</p>

This table shows the pearson correlation coefficient between any two variables. This table is pretty large with (num variables)^2 elements so you can look for yourself as a CSV table. It also shows some simple statistics. I noticed that Life Expectancy and BMI had a relatively large pearson coefficient indicating that there's a somewhat strong positive linear relationship between the two variables. Finally we can plot this to see the relationship visually. 
```
proc plot data=sorted_life_expectancy;
   plot _bmi*life_expectancy="@";
   title 'BMI vs Life Expectancy';
run;
```

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/c06a5e65-5296-429b-a77b-36d5da383dd4"> 
</p>

<p align="center">
<img width="50%" height="auto" src="https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/7a726d71-6a4c-48bb-9fc4-8de4f2d24069"> 
</p>

A fun thing about SAS plots are that by default they plot with alphabetical characters ranking concentration. I set this to the @ character because the lexigraphic rankings were too confusing to me. As you can (vaguely) see the graph has a linear relationship. With the default setting of lexigraphic ordering to rank concentration of frequency the letter A (representing 1 observations of an element) shows up farther away from where the data is concentrated and letters like F (representing multiple observations of an element) are closer to the middle of where the data is concentrated. This makes sense because elements that have a higher margin of error are less frequent than elements with a lower margin and are less likely to stray away from where the regression line would be. 
<br />
<br />
## Conclusion
With that, my report on using SAS for a statistical investigation is concluded. There's plenty more to do with it and plenty of statistical tests that I didn't run, but hopefully I covered the essentials of using SAS for statistical analyses.
<br />

As someone with experience with both Python and R, two of SAS' most competent alternatives, I found that SAS was on par with R for the statistical analysis experience and was better than both for data transformation and manipulation. Python has a much larger community than SAS and R felt a little easier to work with when running specific statistical tests but when it comes to getting down and dirty with data manipulation, SAS reigned supreme. 
