DECLARE @PythonScript NVARCHAR(MAX) 
SET @PythonScript  =N'
import pandas as pd

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


print("-------------------------------")
for i in data.iterrows():
    j = i[1]
    print(j["id"])
    #questionA
    weight = int(j["weight_value"])
    BMI = weight/(j["height_value"]**2)
    AAnswers = AQuestion(BMI, j["age"])
    print(AAnswers)
    #questionB
    unintentional_weight_loss = int(j["choice"])
    unintentional_weight_loss_time = "d"
    if(unintentional_weight_loss == 0):
        if(j["last_6_months"] == 1): unintentional_weight_loss_time = "c"
        elif(j["last_3_months"] == 1): unintentional_weight_loss_time = "b"
        elif(j["last_month"] == 1): unintentional_weight_loss_time = "a"
        unintentional_weight_loss = 12
    BAnswers = BQuestion(unintentional_weight_loss, unintentional_weight_loss_time, weight)
    print(BAnswers)
    #questionC
    acute_diseas = j["acute_diseas"]
    psychological_stress = j["strong_psychological_stress"]
    no_nutritional = j["failure_to_eat_for_more_then_5_days"]
    CAnswers = CQuestion(acute_diseas, psychological_stress, no_nutritional)
    #questionD
    recently = j["decreased_food_consumtpion_recently"]
    month = j["decreased_food_consumption_last_month"]
    months3 = j["decresead_food_consumption_last_3_months"]
    if(recently or month or months3):
        print(months3)
    #OutputDataSet = InputDataSet

    mytextvariable = pandas.Series(["hello", " ", "world"]);
    OutputDataSet = pd.DataFrame(mytextvariable);'

