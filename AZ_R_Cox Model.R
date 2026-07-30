# Multi-state Cox model
#
# Input:  Results/df_mstate_ready.csv
# Output: Results/R_Cox_main_model_results.csv  (Table 1)
#         Results/R_Cox_success_model.csv       (SI Tables 5, 8)
#         Results/R_Cox_cif_combined.csv        (input to G_3)
#
# Clock-reset (semi-Markov) Cox model of phase transitions, stratified by phase
# of origin and by onshore/offshore environment, with all covariates interacted
# with the phase of origin and standard errors clustered on the investment.
# Part 2 fits the cause-specific model for successful transitions and its
# proportional-hazards diagnostics; part 3 derives Fine-Gray cumulative
# incidence functions; part 4 adds physical-scale controls as a robustness
# check.



###########################################################
##########       MASTER SCRIPT: COX MODEL        ##########
###########################################################

# 1. Load Required Libraries
library(survival)
library(dplyr)
library(forcats)

# Check package version (just for logging)
packageVersion("survival")

# 2. Load the dataset
df <- read.csv("Results/df_mstate_ready.csv", stringsAsFactors = FALSE)

# 3. Unified Data Cleaning (Consolidated)
df <- df %>%
  mutate(Project_Jurisdiction = trimws(Project_Jurisdiction)) %>%
  filter(
    !Infr_Type %in% c("Missing Data", ""),
    !Inv_Element_Category %in% c("Missing Data", ""),
    !Inv_Technology %in% c("Missing Data", ""),
    Project_Region != "Unknown" 
  ) %>%
  # Create a numeric dummy variable for EU
  mutate(
    is_EU = ifelse(Project_Region == "EU", 1, 0)
  ) %>%
  # Convert variables to factors
  mutate(across(
    c(from, Project_Jurisdiction, Infr_Type, Inv_Element_Category, Inv_Environment, 
      Inv_Technology, Covid19, NewDirective),
    ~ factor(as.character(.x))
  )) %>%
  # Set 'Internal' as the reference level for Project_Jurisdiction
  mutate(
    Project_Jurisdiction = if ("Internal" %in% levels(Project_Jurisdiction)) {
      relevel(Project_Jurisdiction, ref = "Internal")
    } else {
      Project_Jurisdiction
    }
  ) %>%
  # Define the multi-state event variable and a spell ID
  mutate(
    event_mstate = factor(status, 
                          levels = c(0, 1, 2), 
                          labels = c("censored", "success", "cancelled")),
    spell_id = row_number()
  )

# Verify the number of observations and events for each region
table(df$Project_Region, df$event_mstate)




nrow(df); table(df$event_mstate)
###########################################################
##### PART 1: MAIN MODEL FOR PAPER TABLE (COEFFICIENTS) ###
###########################################################

# 1. Fit the main multi-state model to extract your coefficients for the paper
cox_ts_full <- coxph(
  Surv(Duration, event_mstate) ~ strata(from, Inv_Environment) +
    from:is_EU +                     
    from:Project_Jurisdiction + 
    from:Infr_Type + 
    from:Inv_Element_Category + 
    from:Inv_Technology + 
    from:Covid19 + 
    from:NewDirective +
    cluster(Inv_index),
  data = df,
  id = spell_id,
  ties = "efron",
  model = TRUE, x = TRUE, y = TRUE
)

# Export main model results
model_summary <- as.data.frame(summary(cox_ts_full)$coefficients)
model_summary$Variable <- rownames(model_summary)
write.csv(model_summary, "Results/R_Cox_main_model_results.csv", row.names = FALSE)


###########################################################
##### PART 2: CAUSE-SPECIFIC MODELS FOR ZPH TESTS       ###
###########################################################

# Create binary event indicators for cause-specific hazard models
df$event_success <- ifelse(df$status == 1, 1, 0)

# Fit the Cox model explicitly for the 'success' transition
cox_success <- coxph(
  Surv(Duration, event_success) ~ strata(from, Inv_Environment) +
    from:is_EU + from:Project_Jurisdiction + from:Infr_Type + 
    from:Inv_Element_Category + from:Inv_Technology + from:Covid19 + from:NewDirective +
    cluster(Inv_index),
  data = df, id = spell_id, ties = "efron", model = TRUE, x = TRUE, y = TRUE
)

# Print the full summary for the 'success' transition model
print("--- SUMMARY: SUCCESS TRANSITION ---")
print(summary(cox_success))

# Optional: Export these cause-specific results to CSV files for your appendix
summary_success_df <- as.data.frame(summary(cox_success)$coefficients)
summary_success_df$Variable <- rownames(summary_success_df)
write.csv(summary_success_df, "Results/R_Cox_success_model.csv", row.names = FALSE)

# Print diagnostics explicitly avoiding the multi-state bug
print("--- ZPH TEST: SUCCESS ---")
print(cox.zph(cox_success))


###########################################################
###########################################################
##### PART 3: FINE-GRAY TRUE CIF EXTRACTION (FOR PLOTS) ###
###########################################################
###########################################################



get_mode <- function(x) {
  ux <- unique(na.omit(x))
  ux[which.max(tabulate(match(x, ux)))]
}

vars_to_simulate <- c(
  "is_EU", "Project_Jurisdiction", "Infr_Type", 
  "Inv_Element_Category", "Inv_Environment", "Inv_Technology", 
  "Covid19", "NewDirective"
)

from_levels <- levels(df$from)
target_events <- c("success", "cancelled") 
all_simulations <- data.frame()

for (target_var in vars_to_simulate) {
  
  var_levels <- if(is.factor(df[[target_var]])) levels(df[[target_var]]) else sort(unique(df[[target_var]]))
  
  for (st in from_levels) {
    df_sub <- subset(df, from == st)
    if(nrow(df_sub) == 0) next
    
    for (evt in target_events) {
      if (!(evt %in% df_sub$event_mstate)) next
      
      # 1. Fine-Gray data con la variabile standard (corregge l'errore precedente)
      fg_data <- finegray(
        Surv(Duration, event_mstate) ~ is_EU + Project_Jurisdiction + 
          Infr_Type + Inv_Element_Category + Inv_Environment + 
          Inv_Technology + Covid19 + NewDirective, 
        data = df_sub, etype = evt
      )
      
      # 2. Fit del modello mantenendo lo strata() per isolare l'effetto dell'ambiente
      cox_fg <- coxph(
        Surv(fgstart, fgstop, fgstatus) ~ is_EU + Project_Jurisdiction + 
          Infr_Type + Inv_Element_Category + strata(Inv_Environment) + 
          Inv_Technology + Covid19 + NewDirective, 
        data = fg_data, 
        weight = fgwt,
        ties = "efron"
      ) 
      
      for (lev in var_levels) {
        
        # 3. Baseline bilanciata per le predizioni
        sim_row <- data.frame(
          is_EU = as.numeric(get_mode(df$is_EU)),
          Project_Jurisdiction = factor(get_mode(df$Project_Jurisdiction), levels = levels(df$Project_Jurisdiction)),
          Infr_Type = factor(get_mode(df$Infr_Type), levels = levels(df$Infr_Type)),
          Inv_Element_Category = factor(get_mode(df$Inv_Element_Category), levels = levels(df$Inv_Element_Category)),
          Inv_Environment = factor(get_mode(df$Inv_Environment), levels = levels(df$Inv_Environment)),
          Inv_Technology = factor(get_mode(df$Inv_Technology), levels = levels(df$Inv_Technology)),
          Covid19 = factor(get_mode(df$Covid19), levels = levels(df$Covid19)),
          NewDirective = factor(get_mode(df$NewDirective), levels = levels(df$NewDirective))
        )
        
        if (is.factor(df[[target_var]])) {
          sim_row[[target_var]] <- factor(lev, levels = levels(df[[target_var]]))
        } else {
          sim_row[[target_var]] <- as.numeric(lev)
        }
        
        # 4. Calcolo della curva sopravvivenza / incidenza
        fit <- survfit(cox_fg, newdata = sim_row)
        
        # 5. Salvataggio dei risultati per il plot in Python
        temp_df <- data.frame(
          Time = fit$time,
          Starting_State = st,
          Event_Type = evt,         
          Variable_Analyzed = target_var,
          Level_Value = lev,
          Prob_Event = 1 - fit$surv, 
          Lower_Event = 1 - fit$upper, 
          Upper_Event = 1 - fit$lower  
        )
        
        all_simulations <- rbind(all_simulations, temp_df)
      }
    }
  }
}

# Esporta il file definitivo
write.csv(all_simulations, "Results/R_Cox_cif_combined.csv", row.names = FALSE)
print("True CIF extracted successfully. Ready for Python!")




################################################################
##### Model 2 # FEATURE ENGINEERING (Capacity & Length)    #####
################################################################

med_cap <- median(df$Capacity_MW[df$Capacity_MW > 0], na.rm = TRUE)
med_len <- median(df$Inv_Line_Length_km[df$Inv_Line_Length_km > 0], na.rm = TRUE)

df <- df %>%
  mutate(
    Capacity_Cat = case_when(
      is.na(Capacity_MW)     ~ "Missing",
      Capacity_MW <= 0       ~ "Zero",
      Capacity_MW <= med_cap ~ "Low",
      TRUE                   ~ "High"),
    Length_Cat = case_when(
      is.na(Inv_Line_Length_km)     ~ "Missing",
      Inv_Line_Length_km <= 0       ~ "Zero",
      Inv_Line_Length_km <= med_len ~ "Short",
      TRUE                          ~ "Long"),
    # riferimenti su livelli ben popolati
    Capacity_Cat = relevel(factor(Capacity_Cat), ref = "High"),
    Length_Cat   = relevel(factor(Length_Cat),   ref = "Long")
  )

# Robustness sul rischio cause-specific 'success' (come la Table 1),
# scala fisica come effetti principali, niente element category (collineare con Length=Zero)
cox_robust <- coxph(
  Surv(Duration, event_success) ~ strata(from, Inv_Environment) +
    from:is_EU + from:Project_Jurisdiction +
    from:Infr_Type + from:Inv_Technology +
    from:Covid19 + from:NewDirective +
    Capacity_Cat + Length_Cat +
    cluster(Inv_index),
  data = df, id = spell_id, ties = "efron"
)
summary(cox_robust)     # n deve restare 1082, niente coef infiniti

cox.zph(cox_robust)



### Test ###
############

# opzione A: LRT sui modelli NON clusterizzati (il test di nested è sulla verosimiglianza,
# che non dipende dagli SE robusti; il clustering serve agli SE, non al LRT)
cox_base_nc <- coxph(Surv(Duration, event_success) ~ strata(from, Inv_Environment) +
                       from:is_EU + from:Project_Jurisdiction + from:Infr_Type +
                       from:Inv_Technology + from:Covid19 + from:NewDirective,
                     data = df, id = spell_id, ties = "efron")

cox_robust_nc <- coxph(Surv(Duration, event_success) ~ strata(from, Inv_Environment) +
                         from:is_EU + from:Project_Jurisdiction + from:Infr_Type +
                         from:Inv_Technology + from:Covid19 + from:NewDirective +
                         Capacity_Cat + Length_Cat,
                       data = df, id = spell_id, ties = "efron")

anova(cox_base_nc, cox_robust_nc)   # H0: capacity+length non aggiungono nulla


# opzione B: Wald test robusto congiunto sui soli termini fisici (usa gli SE clusterizzati)
library(car)
linearHypothesis(cox_robust,
                 c("Capacity_CatLow=0","Capacity_CatMissing=0","Capacity_CatZero=0",
                   "Length_CatMissing=0","Length_CatShort=0","Length_CatZero=0"))



#################################
##### Info about the session ####
#################################
sessionInfo()




