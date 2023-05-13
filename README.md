# WHO Life Expectancy Analysis in SAS
An analysis of the Kaggle WHO life expectancy dataset<br />
by Sai Coumar<br />
Dataset: https://www.kaggle.com/datasets/kumarajarshi/life-expectancy-who
<br />
# Introduction:
Welcome to my analysis of the WHO Life Expectancy Dataset by @KUMARRAJARSHI on Kaggle! This report doesn't aim to derive substantial takeaways but rather to display the capacity of SAS in the context of data analysis and exploration. Within this report I'm going to go through the process of importing data, exploring it's features, subsetting data, visualizing data, exploring relationships, and exporting data using SAS. SAS is a very versatile and vast software, and I wanted to cover some common tasks that can be performed in SAS for data analytics. 

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

As someone with experience with both Python and R, two of SAS' most competent alternatives, I found that SAS was on par with R for the statistical analysis experience and was better than both for data transformation and manipulation. Python has a much larger community than SAS and R felt a little easier to work with when running specific statistical tests but when it comes to getting down and dirty with data manipulation, SAS reigned supreme; Finding native inbuilt procedures for specific statistical tasks was incredibly easy and SAS has a vast and detailed documentation to explore. 
