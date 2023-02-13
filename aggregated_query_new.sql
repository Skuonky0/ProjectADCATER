SELECT hospitalization.id, hospitalization.age, q1.weight_value, q1.weight_timestamp,
    q2.height_value, q2.height_timestamp,
    q3.choice, q3.last_month, q3.last_3_months, q3.last_6_months, q3.weight_loss_timestamp,
    q4.acute_diseas, q4.strong_psychological_stress, q4.neuropsychological, q4.med_staff_diagnosis_timestamp,
    q5.decreased_food_consumtpion_recently, q5.decreased_food_consumption_last_month, q5.decresead_food_consumption_last_3_months,
    q5.enternal_feeding, q5.failure_to_eat_for_more_then_5_days, q5.nutrition_screening_assessment_timestamp,
    q6.level_of_mobility, q6.mobility_measurment_timestamp,
    q7.muscle_mass_value, q7.muscle_mass_measurment_timestamp,
    q8.below_50_of_consumption_for_1_week, q8.poor_consumption_for_more_than_2_weeks, q8.gastro_intestinal_condition,
    q8.acute_illness_or_injury, q8.information_from_chronic_disease, q8.GLIM_assessment_timestamp
FROM hospitalization join 
(SELECT t.hospitalization_id, t.timestamp as weight_timestamp, t.weight_value
FROM (SELECT weight_measurment.hospitalization_id, weight_measurment.timestamp, weight_measurment.value as weight_value,
    ROW_NUMBER() over (PARTITION BY weight_measurment.hospitalization_id ORDER BY weight_measurment.timestamp DESC) as R
FROM weight_measurment) t
WHERE R = 1) q1 on hospitalization.id = q1.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as height_timestamp, t.height_value
FROM (SELECT height_measurement.hospitalization_id, height_measurement.timestamp, height_measurement.value as height_value,
    ROW_NUMBER() over (PARTITION BY height_measurement.hospitalization_id ORDER BY height_measurement.timestamp DESC) as R
FROM height_measurement) t
WHERE R = 1) q2 on hospitalization.id = q2.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as weight_loss_timestamp, t.choice, t.last_month, t.last_3_months, t.last_6_months
FROM (SELECT weight_loss.hospitalization_id, weight_loss.choice, weight_loss.last_month, weight_loss.last_3_months, weight_loss.last_6_months, weight_loss.timestamp,
        ROW_NUMBER() over (PARTITION BY weight_loss.hospitalization_id ORDER BY weight_loss.timestamp DESC) as R
    FROM weight_loss) t
WHERE R = 1) q3 on hospitalization.id = q3.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as med_staff_diagnosis_timestamp, t.strong_psychological_stress, t.acute_diseas, t.neuropsychological
FROM (SELECT med_staff_diagnosis.hospitalization_id, med_staff_diagnosis.timestamp, med_staff_diagnosis.strong_psychological_stress, med_staff_diagnosis.acute_diseas,
        med_staff_diagnosis.neuropsychological,
        ROW_NUMBER() over (PARTITION BY med_staff_diagnosis.hospitalization_id ORDER BY med_staff_diagnosis.timestamp DESC) as R
    FROM med_staff_diagnosis) t
WHERE R = 1) q4 on hospitalization.id = q4.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as nutrition_screening_assessment_timestamp, t.decreased_food_consumtpion_recently,
    t.decreased_food_consumption_last_month, t.decresead_food_consumption_last_3_months, t.failure_to_eat_for_more_then_5_days, t.enternal_feeding
FROM (SELECT nutrition_screening_assessment.hospitalization_id, nutrition_screening_assessment.timestamp, nutrition_screening_assessment.decreased_food_consumtpion_recently,
    nutrition_screening_assessment.decreased_food_consumption_last_month, nutrition_screening_assessment.decresead_food_consumption_last_3_months,
    nutrition_screening_assessment.failure_to_eat_for_more_then_5_days, nutrition_screening_assessment.enternal_feeding,
        ROW_NUMBER() over (PARTITION BY nutrition_screening_assessment.hospitalization_id ORDER BY nutrition_screening_assessment.timestamp DESC) as R
    FROM nutrition_screening_assessment) t
WHERE R = 1) q5 on hospitalization.id = q5.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as mobility_measurment_timestamp, t.level_of_mobility
FROM (SELECT mobility_measurment.hospitalization_id, mobility_measurment.timestamp, mobility_measurment.level_of_mobility,
        ROW_NUMBER() over (PARTITION BY mobility_measurment.hospitalization_id ORDER BY mobility_measurment.timestamp DESC) as R
    FROM mobility_measurment) t
WHERE R = 1) q6 on hospitalization.id = q6.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as muscle_mass_measurment_timestamp, t.value as muscle_mass_value
FROM (SELECT muscle_mass_measurment.hospitalization_id, muscle_mass_measurment.timestamp, muscle_mass_measurment.value,
        ROW_NUMBER() over (PARTITION BY muscle_mass_measurment.hospitalization_id ORDER BY muscle_mass_measurment.timestamp DESC) as R
    FROM muscle_mass_measurment) t
WHERE R = 1) q7 on hospitalization.id = q7.hospitalization_id
join
(SELECT t.hospitalization_id, t.timestamp as GLIM_assessment_timestamp, t.below_50_of_consumption_for_1_week, t.poor_consumption_for_more_than_2_weeks,
    t.gastro_intestinal_condition, t.acute_illness_or_injury, t.information_from_chronic_disease
FROM (SELECT GLIM_assessment.hospitalization_id, GLIM_assessment.timestamp, GLIM_assessment.below_50_of_consumption_for_1_week, GLIM_assessment.poor_consumption_for_more_than_2_weeks,
    GLIM_assessment.gastro_intestinal_condition, GLIM_assessment.acute_illness_or_injury, GLIM_assessment.information_from_chronic_disease,
        ROW_NUMBER() over (PARTITION BY GLIM_assessment.hospitalization_id ORDER BY GLIM_assessment.timestamp DESC) as R
    FROM GLIM_assessment) t
WHERE R = 1) q8 on hospitalization.id = q8.hospitalization_id
