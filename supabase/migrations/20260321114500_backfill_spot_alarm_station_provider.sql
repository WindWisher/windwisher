update public.spot_alarms
set station_provider = case
  when station_key like 'avamet:%' then 'AVAMET'
  when station_key like 'inforatge:%' then 'INFORATGE'
  when station_key like 'aiguablanca:%' then 'AIGUABLANCA'
  else 'AEMET'
end
where coalesce(station_provider, '') = '';
