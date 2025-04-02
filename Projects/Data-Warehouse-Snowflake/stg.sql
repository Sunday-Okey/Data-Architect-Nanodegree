copy into covid from @my_json_stage/covid_features.json.gz file_format
=myjsonformat on_error='skip_file';

copy into BUSINESS from @my_json_stage/business.json.gz file_format
=myjsonformat on_error='skip_file';

copy into CHECKIN from @my_json_stage/checking.json.gz file_format
=myjsonformat on_error='skip_file';

copy into REVIEW from @my_json_stage/review.json.gz file_format
=myjsonformat on_error='skip_file';   

copy into tip from @my_json_stage/tip.json.gz file_format
=myjsonformat on_error='skip_file'; 

copy into USER from @my_json_stage/user.json.gz file_format
=myjsonformat on_error='skip_file';                                                                     