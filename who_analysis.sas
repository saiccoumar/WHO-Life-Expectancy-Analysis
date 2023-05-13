libname homework base "path\homework";
%let path=\path\homework;


/*Importing the data and reading the contents*/
proc import 
	datafile="\path\lifeExpectancyData.csv" 
	dbms=csv out=lifeExpectancy replace;
	guessingrows=max;
run;

proc contents data=lifeExpectancy varnum;
run;

/*Min/Maxes. Originally to find the range of years*/
proc means data=lifeExpectancy max min;
	var gdp population year;
run;


/*Looking at the countries in the year 2000 with some key variables*/
proc print data=lifeExpectancy; 
	var country year population Life_expectancy _hiv_aids; 
	where year=2015; 
	format Population comma10.0 life_expectancy 4.2;
run;

proc sort data=lifeExpectancy out=sorted_life_expectancy; /*15d*/
	by Country descending Year;
run;

proc print data=sorted_life_expectancy;
run;

proc export data=sorted_life_expectancy
    outfile='\path\sorted_life_expectancy.csv'
    dbms=CSV replace;
run;

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

proc export data=summary_statistics_mortality 
    outfile='\path\summary_statistics_mortality.csv'
    dbms=CSV replace;
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

proc export data=summary_statistics_disease
    outfile='\path\summary_statistics_disease.csv'
    dbms=CSV replace;
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

proc export data=summary_statistics_socialfactors
    outfile='\path\summary_statistics_social_factors.csv'
    dbms=CSV replace;
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

proc export data=summary_statistics_health
    outfile='\path\summary_statistics_social_health.csv'
    dbms=CSV replace;
run;

proc sql;
create table zambia as /*12a*/
select country, year, life_expectancy, alcohol, adult_mortality, infant_deaths, under_five_deaths 
	from lifeExpectancy
		where country='Zambia' /*12b*/
			order by year, life_expectancy; /*12c*/
quit;

proc print data=zambia;
run;

data processed_empty;
   set sorted_life_expectancy;
   array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
 run ;

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

proc print data=canada;
run;

proc export data=usa
    outfile='\path\usa.csv'
    dbms=CSV replace;
run;

proc export data=mexico
    outfile='\path\mexico.csv'
    dbms=CSV replace;
run;

proc export data=canada
    outfile='\path\canada.csv'
    dbms=CSV replace;
run;

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

proc contents data=diseases_country;
run;

proc print data=diseases_country;
	format diphtheria_total hiv_aids_total measles_total polio_total hiv_aids_total comma12.2;
run;

proc sort data=lifeExpectancy out=sorted_by_year;
	by year;
run;

proc print data=sorted_by_year;
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

proc contents data=diseases_year;
run;

proc print data=diseases_year;
	format diphtheria_total hiv_aids_total measles_total polio_total hiv_aids_total comma12.2;
run;

proc export data=diseases_country
    outfile='\path\diseases_country.csv'
    dbms=CSV replace;
run;

proc export data=diseases_year
    outfile='\path\diseases_year.csv'
    dbms=CSV replace;
run;
	
proc import 
	datafile="\path\formats.csv" 
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

proc contents data=sorted_life_expectancy;
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

proc print data=diseases_year;
run;

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

proc print data=diseases_year_summed;
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

proc print data=pie_chart;
run;

proc gchart data=pie_chart;
	pie disease / other=0  sumvar=deaths;
run;
proc gchart data=pie_chart;
	pie3d disease / other=0 value=none sumvar=deaths percent=arrow;
run;

proc corr data=sorted_life_expectancy out=correlation_matrix;
run;

proc export data=correlation_matrix
    outfile='\path\correlation_matrix.csv'
    dbms=CSV replace;
run;

proc plot data=sorted_life_expectancy;
   plot _bmi*life_expectancy="@";
   title 'BMI vs Life Expectancy';
run;




