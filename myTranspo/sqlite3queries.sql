
//oc_getStopRouteTimes
select 
case when c.sunday = '1' then 2 when c.saturday = '1' then 1 else 0 end dayOfWeek
, st.trip_id
, st.arrival_time
, st.stop_id
, st.stop_sequence
, c.start_date
, c.end_date
, (select IFNULL(s2.stop_name, '') from stop_times st2 inner join stops s2 on s2.stop_id = st2.stop_id WHERE st2.trip_id = st.trip_id ORDER BY st2.stop_sequence DESC LIMIT 1)  end_stop 
	from calendar c
	inner join trips t on t.service_id = c.service_id
	inner join stop_times st on st.trip_id = t.trip_id
        inner join routes r on r.route_id = t.route_id
	where '20120515' BETWEEN c.start_date AND c.end_date
	and (r.route_short_name = '94')
	and st.stop_id = 'CB910'
	and '20120515' NOT IN (SELECT cd.date FROM calendar_dates cd WHERE t.service_id = cd.service_id AND cd.exception_type = 2)
order by dayOfWeek asc, arrival_time ASC;

//oc_getStopTimes
select  
	st.trip_id
	, st.arrival_time
	, st.stop_id
	, st.stop_sequence
	, c.start_date
	, c.end_date
	, r.route_short_name
	, (select IFNULL(s2.stop_name, '') from stop_times st2 inner join stops s2 on s2.stop_id = st2.stop_id WHERE st2.trip_id = st.trip_id ORDER BY st2.stop_sequence DESC LIMIT 1) end_stop 
from calendar c
inner join trips t on t.service_id = c.service_id
inner join routes r on r.route_id = t.route_id
inner join stop_times st on st.trip_id = t.trip_id
where strftime('%Y%m%d') between c.start_date and c.end_date
and r.route_short_name IN ('95', '94', '96')
and st.stop_id = 'CB910'
and c.monday = '1'
and strftime('%Y%m%d') NOT IN (SELECT cd.date FROM calendar_dates cd WHERE t.service_id = cd.service_id AND cd.exception_type = 2)
and st.arrival_time > strftime('%H:%M:%S')
order by st.arrival_time ASC
LIMIT 40;

//oc_getTrip
select st.trip_id, st.arrival_time, st.stop_id, st.stop_sequence, s.stop_code, s.stop_name, s.stop_lat, s.stop_lon 
from stop_times st
inner join stops s on s.stop_id = st.stop_id
where st.trip_id = 22574008
order by st.stop_sequence ASC;