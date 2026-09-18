*1. Модель принятия решений о сбережениях
* Логит-модель
logit high_hh_savings_to_income_2022 FinEdu1_2022 /// 
income_stability_2022 wealthbeing2_2022 ///
plan_horizon2_2022 expect5y_2022 age_2022 gender_2022 
estat ic
estat dwatson
estat classification  // таблица классификации
lsens  // ROC-кривая
*отношение шансов
logit high_hh_savings_to_income_2022 FinEdu1_2022 /// 
income_stability_2022 wealthbeing2_2022 ///
plan_horizon2_2022 expect5y_2022 age_2022 gender_2022, or
* тест ву-хаусмена
ssc install fitstat
fitstat, save
predict residuals, score
Тест Шапиро-Уилка (H0:нормальность остатков)
swilk residuals


* Пробит-модель
probit high_hh_savings_to_income_2022 FinEdu1_2022 /// 
income_stability_2022 wealthbeing2_2022 ///
plan_horizon2_2022 expect5y_2022 age_2022 gender_2022 
estat ic
estat classification  // таблица классификации
margins, dydx(*)
fitstat, diff  // для пробита
swilk residuals

*2. Модель выбора рискованных активов
* Логит-модель
logit many_loans_2022 creditcard_delay_2022 ///
reject_2022 lossjob_2022 no_unes_spending_2022 ///
marriage_2022 home_ownership_2022
 ///
wealthbeing2_2022
estat ic
estat classification  // таблица классификации
lsens  // ROC-кривая
*отношение шансов
logit many_loans_2022 creditcard_delay_2022 ///
reject_2022 lossjob_2022 no_unes_spending_2022 ///
marriage_2022 home_ownership_2022, or
* тест ву-хаусмена
ssc install fitstat
fitstat, save
predict residuals, score
Тест Шапиро-Уилка (H0:нормальность остатков)
swilk residuals


* Пробит-модель
probit many_loans_2022 creditcard_delay_2022 ///
reject_2022 lossjob_2022 no_unes_spending_2022 ///
marriage_2022 home_ownership_2022  
estat ic
estat classification  // таблица классификации
margins, dydx(*)
fitstat, diff  // для пробита
swilk residuals
hist residuals


*3. Модель
*логит
logit Save_noNPF_2022 wealthexp_2022 fixed_income_instr_2022 ///
metals_assets_2022 age_2022 Edu_2022 
estat ic
estat classification  // таблица классификации
lsens  // ROC-кривая
*отношение шансов
logit Save_noNPF_2022 wealthexp_2022 fixed_income_instr_2022 ///
metals_assets_2022 age_2022 Edu_2022, or
* тест ву-хаусмена
ssc install fitstat
fitstat, save
predict residuals, score
Тест Шапиро-Уилка (H0:нормальность остатков)
swilk residuals

* Пробит-модель
probit Save_noNPF_2022 wealthexp_2022 fixed_income_instr_2022 ///
metals_assets_2022 age_2022 Edu_2022  
estat ic
estat classification  // таблица классификации
margins, dydx(*)
fitstat, diff  // для пробита
swilk residuals
hist residuals

*4. Модель
*логит
logit equity_2022 inf_expectations2_2022 ///
attention_rates_2022 error_deposit_rates_2022 ///
optimizm_2022 lossjob_2022 
estat ic
*отношение шансов
logit equity_2022 inf_expectations2_2022 ///
attention_rates_2022 error_deposit_rates_2022 ///
optimizm_2022 lossjob_2022, or



* Пробит-модель
probit equity_2022 inf_expectations2_2022 ///
attention_rates_2022 error_deposit_rates_2022 ///
optimizm_2022 lossjob_2022  
estat ic
predict residuals, score
swilk residuals
hist residuals

*5. Модель
*логит
logit equity_2022 cb_informed_2022 attention_2022 ///
forecast_error_fx_2022 error_cpi_2022 
estat ic
*отношение шансов
logit equity_2022 cb_informed_2022 attention_2022 ///
forecast_error_fx_2022 error_cpi_2022, or


* Пробит-модель
probit equity_2022 cb_informed_2022 attention_2022 ///
forecast_error_fx_2022 error_cpi_2022  
estat ic
predict residuals, score
swilk residuals
hist residuals

*6. Модель
*логит
logit fixed_income_instr_2022 term_deposits_2022 ///
cb_informed_2022 inf_expectations2_2022 ///
expect5y_2022 
estat ic


* Пробит-модель
probit fixed_income_instr_2022 term_deposits_2022 ///
cb_informed_2022 inf_expectations2_2022 ///
expect5y_2022  
estat ic
predict residuals, score
swilk residuals
hist residuals
margins, dydx(*)
