/* query aggregata */

SELECT w1.id, w1.age, w1.weight_value, w1.height_value, w2.choice, w2.last_month, w2.last_3_months, w2.last_6_months, w3.acute_diseas,
    w3.strong_psychological_stress, w3.failure_to_eat_for_more_then_5_days, w4.decreased_food_consumtpion_recently, w4.decreased_food_consumption_last_month,
    w4.decresead_food_consumption_last_3_months, w5.level_of_mobility, w6.neuropsychological, w7.muscle_mass_value,
    w8.below_50_of_consumption_for_1_week, w8.poor_consumption_for_more_than_2_weeks, w8.gastro_intestinal_condition, w8.acute_illness_or_injury,
    w8.information_from_chronic_disease
FROM (SELECT hospitalization.id, hospitalization.age, q1.weight_value, q2.height_value
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
        WHERE R = 1) q2 on hospitalization.id = q2.hospitalization_id) w1
join
(SELECT t.hospitalization_id, t.timestamp, t.choice, t.last_month, t.last_3_months, t.last_6_months
FROM (SELECT weight_loss.hospitalization_id, weight_loss.choice, weight_loss.last_month, weight_loss.last_3_months, weight_loss.last_6_months, weight_loss.timestamp,
        ROW_NUMBER() over (PARTITION BY weight_loss.hospitalization_id ORDER BY weight_loss.timestamp DESC) as R
    FROM weight_loss) t
WHERE R = 1) w2 on w1.id = w2.hospitalization_id
join
(SELECT q1.hospitalization_id, q1.acute_diseas, q1.strong_psychological_stress, q2.failure_to_eat_for_more_then_5_days
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
WHERE R = 1) q2 on q1.hospitalization_id = q2.hospitalization_id2) w3 on w1.id = w3.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp, t.decreased_food_consumtpion_recently,
    t.decreased_food_consumption_last_month, t.decresead_food_consumption_last_3_months
FROM (SELECT nutrition_screening_assessment.hospitalization_id, nutrition_screening_assessment.timestamp, nutrition_screening_assessment.decreased_food_consumtpion_recently,
    nutrition_screening_assessment.decreased_food_consumption_last_month, nutrition_screening_assessment.decresead_food_consumption_last_3_months,
        ROW_NUMBER() over (PARTITION BY nutrition_screening_assessment.hospitalization_id ORDER BY nutrition_screening_assessment.timestamp DESC) as R
    FROM nutrition_screening_assessment) t
WHERE R = 1) w4 on w1.id = w4.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp, t.level_of_mobility
FROM (SELECT mobility_measurment.hospitalization_id, mobility_measurment.timestamp, mobility_measurment.level_of_mobility,
        ROW_NUMBER() over (PARTITION BY mobility_measurment.hospitalization_id ORDER BY mobility_measurment.timestamp DESC) as R
    FROM mobility_measurment) t
WHERE R = 1) w5 on w1.id = w5.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp, t.neuropsychological
FROM (SELECT med_staff_diagnosis.hospitalization_id, med_staff_diagnosis.timestamp, med_staff_diagnosis.neuropsychological,
        ROW_NUMBER() over (PARTITION BY med_staff_diagnosis.hospitalization_id ORDER BY med_staff_diagnosis.timestamp DESC) as R
    FROM med_staff_diagnosis) t
WHERE R = 1) w6 on w1.id = w6.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp, t.value as muscle_mass_value
FROM (SELECT muscle_mass_measurment.hospitalization_id, muscle_mass_measurment.timestamp, muscle_mass_measurment.value,
        ROW_NUMBER() over (PARTITION BY muscle_mass_measurment.hospitalization_id ORDER BY muscle_mass_measurment.timestamp DESC) as R
    FROM muscle_mass_measurment) t
WHERE R = 1) w7 on w1.id = w7.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp, t.below_50_of_consumption_for_1_week, t.poor_consumption_for_more_than_2_weeks,
    t.gastro_intestinal_condition, t.acute_illness_or_injury, t.information_from_chronic_disease
FROM (SELECT GLIM_assessment.hospitalization_id, GLIM_assessment.timestamp, GLIM_assessment.below_50_of_consumption_for_1_week, GLIM_assessment.poor_consumption_for_more_than_2_weeks,
    GLIM_assessment.gastro_intestinal_condition, GLIM_assessment.acute_illness_or_injury, GLIM_assessment.information_from_chronic_disease,
        ROW_NUMBER() over (PARTITION BY GLIM_assessment.hospitalization_id ORDER BY GLIM_assessment.timestamp DESC) as R
    FROM GLIM_assessment) t
WHERE R = 1) w8 on w1.id = w8.hospitalization_id