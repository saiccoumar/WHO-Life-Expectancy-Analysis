# WHO Life Expectancy Analysis in SAS
An analysis of the Kaggle WHO life expectancy dataset<br />
by Sai Coumar<br />
Dataset: https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who
<br />
# Introduction:
Welcome to my analysis of the WHO Life Expectancy Dataset by @KUMARRAJARSHI on Kaggle! This report doesn't aim to derive substantial takeaways but rather to display the capacity of SAS in the context of data analysis and exploration. Within this report I'm going to go through the process of importing data, exploring it's features, subsetting data, visualizing data, exploring relationships, and exporting data using SAS. SAS is a very versatile and vast software, and I wanted to cover some common tasks that can be performed in SAS for data analytics. 

# Imports and previews:
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
Now we have our dataset set as lifeExpectancy. We'll access our data a lot with this. To find out more about the variables in our data I ran proc contents on lifeExpectancy.
```
proc contents data=lifeExpectancy varnum;
run;
```
![proc contents output pt. 1](https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/32d1a1ce-a338-40e5-9ab6-c710a658d2cd) <br />
![proc contents output pt. 2](https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/e0adb1d9-e4da-4ceb-bcd0-0d3b0f5d9689) <br />

Proc contents gives us some information about the size of the dataset (2938) and the number of variables (22) as well as telling us about the variables we have available to look at. The next point of interest is looking at the maximums and minimums of some key variables. 
```
proc means data=lifeExpectancy max min;
	var gdp population year;
run;
```
![proc means output](https://github.com/saiccoumar/WHO-Life-Expectancy-Analysis/assets/55699636/4a09b921-d6e7-4aa9-877c-ae2d2cc4721a) <br />
Running proc means with the max and min options gives us the max and min of GDP, Population, and the year. From this we can see that the data ranges across the years 2000-2015, but the GDP and Population are setting off some massive red flags. The minimum population is 34 which makes no sense because the country with the smallest population is the Vatican city with a population of 800. The minimum GDP is only 1.68. Unless the units of GDP are not in single dollars, this doesn't add up either. This was my first sign that the data isn't particularly reliable and isn't viable for substantial statistical conclusions about the world. Later on I realized a lot of the data didn't add up like total deaths from certain diseases in certain years. Earlier I mentioned that the purpose of the report is to explore SAS and not to use this for real world statistical takeaways and this is why. Unfortunately preprocessed data can be awful to work with.


As someone with experience with both Python and R, two of SAS' most competent alternatives, I found that SAS was on par with R for the statistical analysis experience and was better than both for data transformation and manipulation. Python has a much larger community than SAS and R felt a little easier to work with when running specific statistical tests but when it comes to getting down and dirty with data manipulation, SAS reigned supreme; Finding native inbuilt procedures for specific statistical tasks was incredibly easy and SAS has a vast and detailed documentation to explore. 
