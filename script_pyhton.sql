CREATE OR ALTER PROCEDURE assessment
AS
BEGIN

EXECUTE sp_execute_external_script @language = N'Python'
    , @script = N'
import pandas as pd
import datetime as dt

data = InputDataSet

def AQuestion(BMI, age):
    # For MUST screening: 
    # BMI>20=0
    # BMI18.5-20=1
    # BMI<18.5=2
    MUST = -1
    if BMI > 20:
        MUST = 0
    elif BMI >= 20 and BMI < 18.5:
        MUST = 1
    elif BMI <= 18.5:
        MUST = 2


    # For MNA-SF:
    # BMI<19 = 0 
    # BMI 19-less than 21=1
    # BMI 21-less than 23=2
    # BMI 23 or more=3
    MNA_SF = -1
    if BMI < 19:
        MNA_SF = 0
    elif BMI >= 19 and BMI < 21:
        MNA_SF = 1
    elif BMI >= 21 and BMI < 23:
        MNA_SF = 2
    elif BMI >= 23:
        MNA_SF = 3


    # <20 if <70 years or <22 if 70 years and above= Stage 1 (Group ‘Phenotypic”)
    # <18.5 if 70 years or <20 if 70 years and above = Stage 2 (Group “Phenotypic”)
    # ERROR Note that the two sets can overlaps for example: 19.5 BMI e 69 di eta
    # Who is the winner???
    GLIM = -1
    if (BMI < 20 and age < 70) or (BMI < 22 and age >= 70):
        GLIM = 1
    elif (BMI < 18.5 and age < 70) or (BMI < 20 and age >= 70):
        GLIM = 2
    #print("MUST = ", MUST,"MNA-SF = ", MNA_SF,"GLIM = ", GLIM)

    return {"MUST":MUST, "MNA_SF":MNA_SF, "GLIM":GLIM}

def BQuestion(unintentional_weight_loss, unintentional_weight_loss_time, weight):
    #is the percentage based on the patient weight? (Assuming Yes for now)
    percentage = (weight/unintentional_weight_loss)*100


    #For MUST screening:
    #If  last 3-6 months, (%, the system will calculate)
    #<5% = 0
    #5-10%=1
    #>10%=2
    MUST = 0
    if unintentional_weight_loss_time == "b" or unintentional_weight_loss_time == "c" or unintentional_weight_loss_time == "d":
        if percentage < 5:
            MUST = 0
        if percentage >=5 and percentage < 10:
            MUST = 1
        if percentage >= 10:
            MUST = 2

    MNA_SF=0
    #Not completely clear cannot cover every case
    #For MNA-SF:
    #If last 3 months (kg):
    #>3 kg =0
    #Doesn’t know=1
    #1-3 kg=2
    #No weight loss=3
   
    if unintentional_weight_loss_time == "b" and unintentional_weight_loss > 3:
        MNA_SF = 0
    elif unintentional_weight_loss_time == "e":
        MNA_SF = 1
    elif unintentional_weight_loss > 1 and unintentional_weight_loss < 3:
        MNA_SF = 2
    elif unintentional_weight_loss == 0:
        MNA_SF = 0

    #For SNAQ (kg):
    #>6 kg in the last 6 months=3
    #>3 kg in the last 1 month=2
    SNAQ = 0
    if unintentional_weight_loss > 6 and unintentional_weight_loss_time == "c":
        SNAQ = 3
    elif unintentional_weight_loss > 3 and unintentional_weight_loss_time == "a":
        SNAQ = 2


    #For GLIM:
    #5-10% within the past 6 months or 10-20% beyond 6 months=Stage 1 (Group “Phenotypic”)
    #>10% within the past 6 months or >20% beyond 6 months =Stage 2 (Group ”Phenotypic”)
    GLIM = 0
    if (percentage > 5 and percentage < 10 and unintentional_weight_loss_time == "c") or (percentage >= 10 and percentage < 20 and unintentional_weight_loss_time == "d"):
        GLIM = 1
    elif (percentage > 10 and unintentional_weight_loss_time == "c") or (percentage >= 20 and unintentional_weight_loss_time == "d"):
        GLIM = 2

    return {"MUST": MUST, "MNA_SF":MNA_SF, "SNAQ":SNAQ, "GLIM":GLIM}

def CQuestion(acute_disease, psychological_stress, no_nutritional):
    MUST = 0
    if acute_disease and no_nutritional:
        MUST = 2
        
    MNA_SF = 0
    if acute_disease or psychological_stress:
        MNA_SF = 0
    if not acute_disease or not psychological_stress:
        MNA_SF = 2
    
    return {"MUST":MUST, "MNA_SF":MNA_SF}
    
def DQuestion(food_intake_declined, food_intake_declined_time, food_decrease):

    SNAQ = 0
    if food_intake_declined and food_intake_declined_time == "b":
        SNAQ = 1
    
    return {"MNA_SF":food_decrease, "SNAQ":SNAQ}

def EQuestion(mobility):
    return {"MNA_SF":mobility}

def FQuestion(neuropsychological_problems):
    return {"MNA_SF":neuropsychological_problems}

def GQuestion(supplement_drinks):
    return {"SNAQ":supplement_drinks}

def HQuestion(muscle_mass):
    return {"GLIM":muscle_mass}

def IQuestion(condition_a,condition_b,condition_c,condition_d,condition_e):
    return {"a":condition_a,"b":condition_b,"c":condition_c,"d":condition_d,"e":condition_e}


id = []
must = []
mnasf = []
snaq = []
glim = []

must_txt = []
mnasf_txt = []
snaq_txt = []
glim_txt = []

date = []

weight_timestamp = []
height_timestamp = []
weight_loss_timestamp = []
med_staff_diagnosis_timestamp = []
nutrition_screening_assessment_timestamp = []
mobility_measurment_timestamp = []
muscle_mass_measurment_timestamp = []
GLIM_assessment_timestamp = []

print("-------------------------------")
time = dt.datetime.now()
for i in data.iterrows():
    j = i[1]
    print(j["id"])
    
    #timestamps
    weight_timestamp.append(j["weight_timestamp"])
    height_timestamp.append(j["height_timestamp"])
    weight_loss_timestamp.append(j["weight_loss_timestamp"])
    med_staff_diagnosis_timestamp.append(j["med_staff_diagnosis_timestamp"])
    nutrition_screening_assessment_timestamp.append(j["nutrition_screening_assessment_timestamp"])
    mobility_measurment_timestamp.append(j["mobility_measurment_timestamp"])
    muscle_mass_measurment_timestamp.append(j["muscle_mass_measurment_timestamp"])
    GLIM_assessment_timestamp.append(j["GLIM_assessment_timestamp"])
    
    #questionA
    weight = float(j["weight_value"])
    BMI = weight/(j["height_value"]**2)
    AAnswers = AQuestion(BMI, j["age"])
    print("A", AAnswers)

    #questionB
    unintentional_weight_loss = int(j["choice"])
    unintentional_weight_loss_time = "d"
    if(unintentional_weight_loss == 0):
        if(j["last_6_months"] == 1): unintentional_weight_loss_time = "c"
        elif(j["last_3_months"] == 1): unintentional_weight_loss_time = "b"
        elif(j["last_month"] == 1): unintentional_weight_loss_time = "a"
        unintentional_weight_loss = 12
    BAnswers = BQuestion(unintentional_weight_loss, unintentional_weight_loss_time, weight)
    print("B", BAnswers)

    #questionC
    acute_diseas = j["acute_diseas"]
    psychological_stress = j["strong_psychological_stress"]
    no_nutritional = j["failure_to_eat_for_more_then_5_days"]
    CAnswers = CQuestion(acute_diseas, psychological_stress, no_nutritional)
    print("C", CAnswers)

    #questionD
    recently = j["decreased_food_consumtpion_recently"]
    month = j["decreased_food_consumption_last_month"]
    months3 = j["decresead_food_consumption_last_3_months"]
    food_decrease = 0
    food_intake_declined = 0
    if(recently or month or months3):
        food_intake_declined = 1
        if(months3):
            food_intake_declined_time = "a"
            #modifica food_decrease
        elif(month): food_intake_declined_time = "b"
        elif(recently): food_intake_declined_time = "c"
    DAnswers = DQuestion(food_intake_declined, food_intake_declined_time, food_decrease)
    print("D", DAnswers)

    #questionE
    mobility_val = j["level_of_mobility"]
    mobility = 0
    if(mobility_val == "Bed or chair bound (0)"):
        mobility = 0
    elif(mobility_val == "Able to get out of bed/chair but does not go out"):
        mobility = 1
    elif(mobility_val == "Goes Out (2)"):
        mobility = 2
    EAnswers = EQuestion(mobility)
    print("E", EAnswers)

    #questionF
    neuropsychological_problems = int(j["neuropsychological"])
    FAnswers = FQuestion(neuropsychological_problems)
    print("F", FAnswers)

    #questionG
    #supplement_drinks = int(j["enterenternal_feeding"])
    #GAnswers = GQuestion(supplement_drinks)
    GAnswers = GQuestion(2)

    #questionH
    muscle_mass = j["muscle_mass_value"]
    muscle_mass_val = j["level_of_mobility"]
    muscle_mass = 0
    if(muscle_mass_val == "Bigger then 22 cm (No deficit)"):
        muscle_mass = 0
    elif(muscle_mass_val == "Between 21-22 cm (Mild to moderate deficit)"):
        muscle_mass = 1
    elif(muscle_mass_val == "Lower then 21 cm (Severe deficit)"):
        muscle_mass = 2
    HAnswers = HQuestion(muscle_mass)
    print("H", HAnswers)

    #questionI
    condition_a = int(j["below_50_of_consumption_for_1_week"])
    condition_b = int(j["poor_consumption_for_more_than_2_weeks"])
    condition_c = int(j["gastro_intestinal_condition"])
    condition_d = int(j["acute_illness_or_injury"])
    condition_e = int(j["information_from_chronic_disease"])
    IAnswers = IQuestion(condition_a,condition_b,condition_c,condition_d,condition_e)
    print("I", IAnswers)

    print("FINAL SCORE REPORT")

    MUST_score = AAnswers["MUST"] + BAnswers["MUST"] + CAnswers["MUST"]
    print("MUST:",MUST_score)
    must_out = ""
    if MUST_score == 0:
        must_out = "Low Risk"
    if MUST_score == 1:
        must_out = "Medium Risk"
    if MUST_score > 1:
        must_out = "High Risk"
    print(must_out)
    must_txt.append(must_out)
    print()

    MNA_SF_score = AAnswers["MNA_SF"] + BAnswers["MNA_SF"] + CAnswers["MNA_SF"] + DAnswers["MNA_SF"] + EAnswers["MNA_SF"] + FAnswers["MNA_SF"]
    print("MNA-SF:",MNA_SF_score)
    mnasf_out = ""
    if MNA_SF_score <=14 and MNA_SF_score>=12:
        mnasf_out = "Normal Nutrition"
    if MNA_SF_score <=12 and MNA_SF_score>=8:
        mnasf_out = "At Risk of malnutrition"
    if MNA_SF_score <=7 and MNA_SF_score>=0:
        mnasf_out = "Malnourished"
    print(mnasf_out)
    mnasf_txt.append(mnasf_out)
    print()

    SNAQ_score = BAnswers["SNAQ"] + DAnswers["SNAQ"] + GAnswers["SNAQ"]
    print("SNAQ:",SNAQ_score)
    snaq_out = ""
    if SNAQ_score>=0 and SNAQ_score<=1:
        snaq_out = "No Intervantion"
    if SNAQ_score == 2:
        snaq_out = "Moderately malnourished; nutrition intervention"
    if SNAQ_score >=3:
        snaq_out = "Severely malnourished; nutritional intervention and treatment"
    print(snaq_out)
    snaq_txt.append(snaq_out)
    print()

    #Not Clear
    GLIM_score = 0
    glim_out = ""
    if AAnswers["GLIM"] == 2 or BAnswers["GLIM"] == 2 or HAnswers["GLIM"] == 2:
        GLIM_score = 2
    elif AAnswers["GLIM"] == 1 or BAnswers["GLIM"] == 1 or HAnswers["GLIM"] == 1:
        GLIM_score = 1
    if GLIM_score>0 and IAnswers["a"] or IAnswers["b"] or IAnswers["c"] or IAnswers["d"] or IAnswers["e"]:
        glim_out = "Malnutirtion Diagnosis"
    print(glim_out)
    glim_txt.append(glim_out)
    print()

    id.append(j["id"])
    must.append(MUST_score)
    mnasf.append(MNA_SF_score)
    snaq.append(SNAQ_score)
    glim.append(GLIM_score)

    date.append(time)
dataout = pd.DataFrame({"Id": id, "MUST": must, "MUST outcome": must_out,
    "MNA-SF": mnasf, "MNA-SF outcome": mnasf_out,
    "SNAQ": snaq, "SNAQ outcome": snaq_out,
    "GLIM": glim, "GLIM outcome": glim_out,
    "datetime": date,
    "weight_timestamp" : weight_timestamp,
    "height_timestamp" : height_timestamp,
    "weight_loss_timestamp" : weight_loss_timestamp,
    "med_staff_diagnosis_timestamp" : med_staff_diagnosis_timestamp,
    "nutrition_screening_assessment_timestamp" : nutrition_screening_assessment_timestamp,
    "mobility_measurment_timestamp" : mobility_measurment_timestamp,
    "muscle_mass_measurment_timestamp" : muscle_mass_measurment_timestamp,
    "GLIM_assessment_timestamp" : GLIM_assessment_timestamp
    })
print(dataout)
OutputDataSet = dataout;'
    , @input_data_1 = N'
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

'
WITH RESULT SETS((hospitalization_id INT, MUST_score INT, MUST_outcome VARCHAR(255),
    MNA_SF_score INT, MNA_SF_outcome VARCHAR(255),
    SNAQ_score INT, SNAQ_outcome VARCHAR(255),
    GLIM_score INT, GLIM_outcome VARCHAR(255),
    datetime datetime,
    weight_timestamp datetime,
    height_timestamp datetime,
    weight_loss_timestamp datetime,
    med_staff_diagnosis_timestamp datetime,
    nutrition_screening_assessment_timestamp datetime,
    mobility_measurment_timestamp datetime,
    muscle_mass_measurment_timestamp datetime,
    GLIM_assessment_timestamp datetime
    ));

END;
GO

INSERT INTO result_nutrition_assessment
EXECUTE assessment
GO