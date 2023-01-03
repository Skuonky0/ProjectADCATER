SELECT t.hospitalization_id, t.timestamp, t.below_50_of_consumption_for_1_week, t.poor_consumption_for_more_than_2_weeks,
    t.gastro_intestinal_condition, t.acute_illness_or_injury, t.information_from_chronic_disease
FROM (SELECT GLIM_assessment.hospitalization_id, GLIM_assessment.timestamp, GLIM_assessment.below_50_of_consumption_for_1_week, GLIM_assessment.poor_consumption_for_more_than_2_weeks,
    GLIM_assessment.gastro_intestinal_condition, GLIM_assessment.acute_illness_or_injury, GLIM_assessment.information_from_chronic_disease,
        ROW_NUMBER() over (PARTITION BY GLIM_assessment.hospitalization_id ORDER BY GLIM_assessment.timestamp DESC) as R
    FROM GLIM_assessment) t
WHERE R = 1