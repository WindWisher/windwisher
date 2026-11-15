#!/usr/bin/env python3
"""Export observed standard FIT activity metrics; no jump inference or cloud writes."""
import argparse
from collections import Counter
from datetime import datetime
import hashlib
import json
from pathlib import Path

import fitdecode


def extract(path):
    sessions=[]
    records=[]
    counts=Counter()
    developer_count=0
    with fitdecode.FitReader(path,check_crc=fitdecode.CrcCheck.RAISE) as reader:
        for frame in reader:
            if not isinstance(frame,fitdecode.records.FitDataMessage):
                continue
            counts[frame.name]+=1
            values={field.name:field.value for field in frame.fields}
            if frame.name=='developer_data_id':
                developer_count+=1
            if frame.name=='session':
                sessions.append(values)
            if frame.name=='record':
                record={}
                for field,target in [('timestamp','timestamp'),('distance','distance_m'),
                                     ('heart_rate','heart_rate_bpm'),('temperature','temperature_c')]:
                    if values.get(field) is not None:
                        record[target]=values[field]
                for enhanced,legacy,target in [('enhanced_speed','speed','speed_m_s'),
                                                ('enhanced_altitude','altitude','altitude_m')]:
                    value=values.get(enhanced)
                    if value is None:
                        value=values.get(legacy)
                    if value is not None:
                        record[target]=value
                for field,target in [('position_lat','latitude_deg'),('position_long','longitude_deg')]:
                    if values.get(field) is not None:
                        record[target]=values[field]*180/(2**31)
                records.append(record)
    if len(sessions)!=1:
        raise ValueError('Expected exactly one FIT session; multi-session mapping is not implemented')
    session=sessions[0]
    summary={}
    for field in ['start_time','total_elapsed_time','total_timer_time','total_distance',
                  'enhanced_avg_speed','enhanced_max_speed','avg_speed','max_speed',
                  'avg_heart_rate','max_heart_rate','total_ascent','total_descent',
                  'sport','sub_sport','sport_profile_name']:
        if session.get(field) is not None:
            summary[field]=session[field]
    return dict(export_schema='windwisher-garmin-fit-research-v1',
        source=dict(file_name=path.name,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                    decoder='fitdecode',crc_check='RAISE',developer_id_messages=developer_count),
        summary_fit_fields=summary,records=records,message_counts=dict(counts),
        jump_metrics_status='NOT_EXTRACTED',
        limitations=['Local research export, not Canonical Session v1 or production import.',
                     'Unknown and developer fields are not interpreted; original FIT remains authoritative.',
                     'Altitude is not jump height; absent values are not replaced with zero.'])


def json_default(value):
    if isinstance(value,datetime):
        return value.isoformat()
    raise TypeError(type(value).__name__)


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('fit',type=Path)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args()
    if args.out.exists():
        parser.error('Output already exists; choose a new path')
    result=extract(args.fit)
    args.out.parent.mkdir(parents=True,exist_ok=True)
    with args.out.open('x',encoding='utf-8') as handle:
        json.dump(result,handle,default=json_default,allow_nan=False)
    print(f'Exported {len(result["records"])} records; jump metrics not inferred.')
