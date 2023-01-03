SELECT t.hospitalization_id, t.timestamp, t.choice, t.last_month, t.last_3_months, t.last_6_months
FROM (SELECT weight_loss.hospitalization_id, weight_loss.choice, weight_loss.last_month, weight_loss.last_3_months, weight_loss.last_6_months, weight_loss.timestamp,
        ROW_NUMBER() over (PARTITION BY weight_loss.hospitalization_id ORDER BY weight_loss.timestamp DESC) as R
    FROM weight_loss) t
WHERE R = 1