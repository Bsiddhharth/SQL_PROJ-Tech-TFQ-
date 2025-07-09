

-- URL: https://www.kaggle.com/datasets/rachelczmyr/bellabeat


drop table if exists daily_activity;
create table daily_activity
(
	Customer_ID						bigint,
	Activity_Date					date,
	Day_of_Week						varchar(20),
	Total_Steps						int,
	Total_Distance					decimal,
	Tracker_Distance				decimal,
	Very_Active_Distance			decimal,
	Moderately_Active_Distance		decimal,
	Light_Active_Distance			decimal,
	Sedentary_Active_Distance		decimal,
	Very_Active_Minutes				int,
	Fairly_Active_Minutes			int,
	Lightly_Active_Minutes			int,
	Sedentary_Minutes				int,
	Calories						int
);

drop table if exists weight_log;
create table weight_log
(
	Customer_ID			bigint,
	Datetimes			timestamp,
	Day_of_Week			varchar(20),
	Dates 				date,	
	Times				time,			
	Weight_Kg			decimal,
	Weight_Pounds		decimal,
	Fat					int,
	BMI					decimal,
	Is_Manual_Report	boolean,
	Manual_Report		int,
	Log_Id				decimal
);

drop table if exists sleep_day;
create table sleep_day
(
	Customer_Id				bigint,
	Sleep_Day				date,
	Day_of_Week				varchar(20),
	Total_Sleep_Records		int,
	Total_Minutes_Asleep	int,
	Total_Time_In_Bed		int
);


select * from daily_activity;
select * from weight_log;
select * from sleep_day;


