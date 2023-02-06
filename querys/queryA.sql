/* Funzione per prendere il valore maggiore di timestamp rispetto ad un id*/

/*SELECT t.hospitalization_id, t.timestamp, t.value
FROM (SELECT weight_measurment.hospitalization_id, weight_measurment.timestamp, weight_measurment.value,
        ROW_NUMBER() over (PARTITION BY weight_measurment.hospitalization_id ORDER BY weight_measurment.timestamp DESC) as R
    FROM weight_measurment) t
WHERE R = 1
ORDER BY t.hospitalization_id

SELECT t.hospitalization_id, t.timestamp, t.value
FROM (SELECT height_measurement.hospitalization_id, height_measurement.timestamp, height_measurement.value,
        ROW_NUMBER() over (PARTITION BY height_measurement.hospitalization_id ORDER BY height_measurement.timestamp DESC) as R
    FROM height_measurement) t
WHERE R = 1
ORDER BY t.hospitalization_id*/

SELECT hospitalization.id, hospitalization.age, q1.weight_value, q2.height_value
FROM hospitalization join 
(SELECT t.hospitalization_id, t.timestamp, t.weight_value
        FROM (SELECT weight_measurment.hospitalization_id, weight_measurment.timestamp, weight_measurment.value as weight_value,
            ROW_NUMBER() over (PARTITION BY weight_measurment.hospitalization_id ORDER BY weight_measurment.timestamp DESC) as R
        FROM weight_measurment) t
        WHERE R = 1) q1 on hospitalization.id = q1.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp, t.height_value
        FROM (SELECT height_measurement.hospitalization_id, height_measurement.timestamp, height_measurement.value as height_value,
            ROW_NUMBER() over (PARTITION BY height_measurement.hospitalization_id ORDER BY height_measurement.timestamp DESC) as R
        FROM height_measurement) t
        WHERE R = 1) q2 on hospitalization.id = q2.hospitalization_id