/* mancano dei dati nel DB?*/
SELECT t.hospitalization_id, t.timestamp, t.decreased_food_consumtpion_recently,
    t.decreased_food_consumption_last_month, t.decresead_food_consumption_last_3_months
FROM (SELECT nutrition_screening_assessment.hospitalization_id, nutrition_screening_assessment.timestamp, nutrition_screening_assessment.decreased_food_consumtpion_recently,
    nutrition_screening_assessment.decreased_food_consumption_last_month, nutrition_screening_assessment.decresead_food_consumption_last_3_months,
        ROW_NUMBER() over (PARTITION BY nutrition_screening_assessment.hospitalization_id ORDER BY nutrition_screening_assessment.timestamp DESC) as R
    FROM nutrition_screening_assessment) t
WHERE R = 1