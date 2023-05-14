# WHO Life Expectancy Analysis in SAS
An analysis of the Kaggle WHO life expectancy dataset<br />
by Sai Coumar<br />
Dataset: https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who
<br />
## Introduction:
Welcome to my analysis of the WHO Life Expectancy Dataset by @KUMARRAJARSHI on Kaggle! This report doesn't aim to derive substantial takeaways but rather to display the capacity of SAS in the context of data analysis and exploration. Within this report I'm going to go through the process of importing data, exploring it's features, subsetting data, visualizing data, exploring relationships, and exporting data using SAS. SAS is a very versatile and vast software, and I wanted to cover some common tasks that can be performed in SAS for data analytics. 

## Imports and previews
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
Proc contents gives us some information about the size of the dataset (2938) and the number of variables (22) as well as telling us about the variables we have available to look at. The next point of interest is looking at the maximums and minimums of some key variables. 

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

SQL was fun but to do this more programatically I used a data step and a select-when statement to subset the sorted_life_expectancy into the 3 North American Countries. I also took advantage of the data step to apply numeric and character functions to modify the data in desirable ways. and create total columns via the retain statement. The three outputted CSVs can be viewed on the repository in the table_output folder.
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




As someone with experience with both Python and R, two of SAS' most competent alternatives, I found that SAS was on par with R for the statistical analysis experience and was better than both for data transformation and manipulation. Python has a much larger community than SAS and R felt a little easier to work with when running specific statistical tests but when it comes to getting down and dirty with data manipulation, SAS reigned supreme; Finding native inbuilt procedures for specific statistical tasks was incredibly easy and SAS has a vast and detailed documentation to explore. 
