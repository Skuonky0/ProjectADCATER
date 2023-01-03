SELECT t.hospitalization_id, t.timestamp, t.level_of_mobility
FROM (SELECT mobility_measurment.hospitalization_id, mobility_measurment.timestamp, mobility_measurment.level_of_mobility,
        ROW_NUMBER() over (PARTITION BY mobility_measurment.hospitalization_id ORDER BY mobility_measurment.timestamp DESC) as R
    FROM mobility_measurment) t
WHERE R = 1