SELECT q1.hospitalization_id, q1.acute_diseas, q1.strong_psychological_stress, q2.failure_to_eat_for_more_then_5_days
FROM 
(SELECT t.hospitalization_id, t.timestamp, t.strong_psychological_stress, t.acute_diseas
FROM (SELECT med_staff_diagnosis.hospitalization_id, med_staff_diagnosis.timestamp, med_staff_diagnosis.strong_psychological_stress, med_staff_diagnosis.acute_diseas,
        ROW_NUMBER() over (PARTITION BY med_staff_diagnosis.hospitalization_id ORDER BY med_staff_diagnosis.timestamp DESC) as R
    FROM med_staff_diagnosis) t
WHERE R = 1) q1
join
(SELECT t.hospitalization_id as hospitalization_id2, t.timestamp, t.failure_to_eat_for_more_then_5_days
FROM (SELECT nutrition_screening_assessment.hospitalization_id, nutrition_screening_assessment.timestamp, nutrition_screening_assessment.failure_to_eat_for_more_then_5_days,
        ROW_NUMBER() over (PARTITION BY nutrition_screening_assessment.hospitalization_id ORDER BY nutrition_screening_assessment.timestamp DESC) as R
    FROM nutrition_screening_assessment) t
WHERE R = 1) q2 on q1.hospitalization_id = q2.hospitalization_id2