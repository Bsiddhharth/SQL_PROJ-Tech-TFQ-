create or replace procedure pr_validate_count()
language plpgsql
as $$
declare
	v_circuits_org_cnt  INT default 77;
	v_constructors_org_cnt  INT default 211;
	v_drivers_org_cnt  INT default 857;
	v_constructor_results_org_cnt  INT default 12170;
	v_constructor_standings_org_cnt INT default 12941;
	v_driver_standings_org_cnt  INT default 33902;
	v_lap_times_org_cnt  INT default 538121;
	v_pit_stops_org_cnt  INT default 9634;
	v_qualifying_org_cnt  INT default 9575;
	v_races_org_cnt  INT default 1102;
	v_results_org_cnt  INT default 25840;
	v_seasons_org_cnt  INT default 74;
	v_sprint_results_org_cnt  INT default 120;
	v_status_org_cnt  INT default 139;

	v_circuits_cnt  INT;
	v_constructors_cnt  INT;
	v_drivers_cnt  INT;
	v_constructor_results_cnt  INT;
	v_constructor_standings_cnt INT;
	v_driver_standings_cnt  INT;
	v_lap_times_cnt  INT;
	v_pit_stops_cnt  INT;
	v_qualifying_cnt  INT;
	v_races_cnt  INT;
	v_results_cnt  INT;
	v_seasons_cnt  INT;
	v_sprint_results_cnt  INT;
	v_status_cnt  INT;

begin
	select count(1) into v_circuits_cnt from circuits;
	select count(1) into v_constructors_cnt from constructors;
	select count(1) into v_drivers_cnt from drivers;
	select count(1) into v_constructor_results_cnt  from constructor_results; 
	select count(1) into v_constructor_standings_cnt from constructor_standings;
	select count(1) into v_driver_standings_cnt  from driver_standings; 
	select count(1) into v_lap_times_cnt  from lap_times; 
	select count(1) into v_pit_stops_cnt  from pit_stops; 
	select count(1) into v_qualifying_cnt  from qualifying; 
	select count(1) into v_races_cnt  from races; 
	select count(1) into v_results_cnt  from results; 
	select count(1) into v_seasons_cnt  from seasons; 
	select count(1) into v_sprint_results_cnt  from sprint_results; 
	select count(1) into v_status_cnt  from status; 
							
	if v_circuits_cnt 				= v_circuits_org_cnt 				then raise notice 'Circuits table count is Correct!'; 				else raise warning 'Circuits table count MISMATCH!'; end if;
	if v_constructors_cnt 			= v_constructors_org_cnt 			then raise notice 'Constructors table count is Correct!'; 			else raise warning 'Constructors table count MISMATCH!'; end if;
	if v_drivers_cnt 				= v_drivers_org_cnt 				then raise notice 'Drivers table count is Correct!'; 				else raise warning 'Drivers table count MISMATCH!'; end if;
	if v_constructor_results_cnt 	= v_constructor_results_org_cnt 	then raise notice 'Constructor_results table count is Correct!'; 	else raise warning 'Constructor_results table count MISMATCH!'; end if;
	if v_constructor_standings_cnt 	= v_constructor_standings_org_cnt 	then raise notice 'Constructor_standings table count is Correct!'; 	else raise warning 'Constructor_standings table count MISMATCH!'; end if;
	if v_driver_standings_cnt 		= v_driver_standings_org_cnt 		then raise notice 'Driver_standings table count is Correct!'; 		else raise warning 'Driver_standings table count MISMATCH!'; end if;
	if v_lap_times_cnt 				= v_lap_times_org_cnt  				then raise notice 'Lap_times table count is Correct!'; 				else raise warning 'Lap_times table count MISMATCH!'; end if;
	if v_pit_stops_cnt 				= v_pit_stops_org_cnt  				then raise notice 'Pit_stops table count is Correct!'; 				else raise warning 'Pit_stops table count MISMATCH!'; end if;
	if v_qualifying_cnt 			= v_qualifying_org_cnt  			then raise notice 'Qualifying table count is Correct!'; 			else raise warning 'Qualifying table count MISMATCH!'; end if;
	if v_races_cnt 					= v_races_org_cnt  					then raise notice 'Races table count is Correct!'; 					else raise warning 'Races table count MISMATCH!'; end if;
	if v_results_cnt 				= v_results_org_cnt  				then raise notice 'Results table count is Correct!'; 				else raise warning 'Results table count MISMATCH!'; end if;
	if v_seasons_cnt 				= v_seasons_org_cnt  				then raise notice 'Seasons table count is Correct!'; 				else raise warning 'Seasons table count MISMATCH!'; end if;
	if v_sprint_results_cnt 		= v_sprint_results_org_cnt  		then raise notice 'Sprint_results table count is Correct!'; 		else raise warning 'Sprint_results table count MISMATCH!'; end if;
	if v_status_cnt 				= v_status_org_cnt  				then raise notice 'Status table count is Correct!'; 				else raise warning 'Status table count MISMATCH!'; end if;

end;
$$