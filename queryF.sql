SELECT t.hospitalization_id, t.timestamp, t.neuropsychological
FROM (SELECT med_staff_diagnosis.hospitalization_id, med_staff_diagnosis.timestamp, med_staff_diagnosis.neuropsychological,
        ROW_NUMBER() over (PARTITION BY med_staff_diagnosis.hospitalization_id ORDER BY med_staff_diagnosis.timestamp DESC) as R
    FROM med_staff_diagnosis) t
WHERE R = 1