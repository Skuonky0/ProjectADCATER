SELECT t.hospitalization_id, t.timestamp, t.value
FROM (SELECT muscle_mass_measurment.hospitalization_id, muscle_mass_measurment.timestamp, muscle_mass_measurment.value,
        ROW_NUMBER() over (PARTITION BY muscle_mass_measurment.hospitalization_id ORDER BY muscle_mass_measurment.timestamp DESC) as R
    FROM muscle_mass_measurment) t
WHERE R = 1