
//oc_getStopRouteTimes
select 
case when c.sunday = '1' then 'sunday' when c.saturday = '1' then 'saturday' else 'weekday' end dayOfWeek
, st.trip_id
, st.stop_id
, (h.hour || ':' || m.minute || ':00') arrival_time
, st.stop_sequence
, t.end_stop
from stop_times st
inner join stops s on s.id = st.stop_id
inner join trips t on t.trip_id = st.trip_id
inner join routes r on r.route_id = t.route_id
inner join calendar c on c.service_id = t.service_id
left join calendar_dates cd on cd.service_id = c.service_id
inner join hours h on h.id = st.hour
inner join minutes m on m.id = st.minute
	where '20120515' BETWEEN c.start_date AND c.end_date
	and (r.route_short_name = '94')
	and s.stop_id = 'CB910'
	and (cd.exception_type IS NULL OR cd.exception_type <> 2)
order by dayOfWeek asc, arrival_time asc

//oc_getStopTimes
select  
	st.trip_id
	, (h.hour || ':' || m.minute || ':00') arrival_time
	, st.stop_id
	, st.stop_sequence
	, r.route_short_name
	, t.end_stop
from stop_times st
inner join stops s on s.id = st.stop_id
inner join trips t on t.trip_id = st.trip_id
inner join routes r on r.route_id = t.route_id
inner join calendar c on c.service_id = t.service_id
left join calendar_dates cd on cd.service_id = c.service_id
inner join hours h on h.id = st.hour
inner join minutes m on m.id = st.minute
where strftime('%Y%m%d', 'now', 'localtime') between c.start_date and c.end_date
and r.route_short_name IN ('95', '94', '96')
and s.stop_id = 'CB910'
and c.monday = '1'
and (cd.exception_type IS NULL OR cd.exception_type <> 2)
and arrival_time > strftime('%H:%M:%S', 'now', 'localtime')
order by arrival_time ASC
LIMIT 40;

//oc_getTrip
select st.trip_id, (h.hour || ':' || m.minute || ':00') arrival_time, st.stop_id, st.stop_sequence, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon 
from stop_times st
inner join stops s on s.id = st.stop_id
inner join hours h on h.id = st.hour
inner join minutes m on m.id = st.minute
where st.trip_id = 22574008
order by st.stop_sequence ASC;
