#Анализ производительности труда за 2011-2025 годы
library(readxl)
library(dplyr)
file = "/Users/malininka/Desktop/Работа/База данных (дашборд)/макро связь.xlsx"

# B2:L18, стр 3 - единицы измерения.
d = read_excel(file, sheet = "Лист1", range = "B2:L18")
d = as.data.frame(d[-1, ])
names(d) = c("year", "ipt", "gdp", "employment", "trade", "debt", "ruonia", "inflation", "investment", "consumption", "gov_spending")
for (i in 1:ncol(d)) d[[i]] = as.numeric(d[[i]])

#показатели к буллитам 
d$pt = d$gdp / d$employment
d$pt_growth = c(NA, 100 * diff(d$pt) / d$pt[-nrow(d)])
d$gdp_growth = c(NA, 100 * diff(d$gdp) / d$gdp[-nrow(d)])
d$employment_growth = c(NA, 100 * diff(d$employment) / d$employment[-nrow(d)])
d$investment_growth = c(NA, 100 * diff(d$investment) / d$investment[-nrow(d)])

(summary <- data.frame(
  показатель = c("ПТ в 2011", "ПТ в 2025", "Рост ПТ за период", "Среднегодовой рост ПТ", "Минимальный рост ПТ", "Максимальный рост ПТ"),
  значение = c(d$pt[1], tail(d$pt, 1), 100 * (tail(d$pt, 1) / d$pt[1] - 1), 100 * ((tail(d$pt, 1) / d$pt[1])^(1 / 14) - 1), min(d$pt_growth, na.rm = TRUE), max(d$pt_growth, na.rm = TRUE))
))

library(ggplot2)

# 
ggplot(d, aes(year, pt)) + geom_line(colour = "#1F4E79", linewidth = 1.1) + 
  geom_point(colour = "#1F4E79", size = 2) + 
  labs(title = "Производительность труда в 2011–2025 годах", y = "ВВП на одного занятого") + theme_minimal(base_size = 11)

str(d)
#декомпозиция
decomp = d %>% 
  select(year, pt_growth, gdp_growth, employment_growth) %>% 
  pivot_longer(-year, names_to = "metric", values_to = "value") %>%
  mutate(metric = recode(metric, pt_growth = "Рост ПТ", gdp_growth = "Рост ВВП", employment_growth = "Рост занятости"))

ggplot(decomp, aes(year, value, colour = metric)) + geom_hline(yintercept = 0, colour = "grey70") + geom_line(linewidth = .9, na.rm = TRUE) + geom_point(size = 1.8, na.rm = TRUE) + scale_colour_manual(values = c("Рост ПТ" = "#1F4E79", "Рост ВВП" = "#70AD47", "Рост занятости" = "#C0504D")) + labs(title = "Декомпозиция динамики производительности труда", x = NULL, y = "% к предыдущему году", colour = NULL) + theme_minimal(base_size = 11) + theme(legend.position = "bottom")

#
growth_vars = c("pt_growth", "gdp_growth", "employment_growth", "investment_growth", "consumption_growth", "gov_spending_growth", "debt_growth", "inflation_change", "ruonia_change", "trade")
screen = d %>% select(any_of(growth_vars))
(cor_tbl = tibble(
  factor = setdiff(names(screen), "pt_growth"),
  correlation_with_pt_growth = sapply(setdiff(names(screen), "pt_growth"), function(x) cor(screen$pt_growth, screen[[x]], use = "pairwise.complete.obs")),
  observations = sapply(setdiff(names(screen), "pt_growth"), function(x) sum(complete.cases(screen[, c("pt_growth", x)])))
) %>% arrange(desc(abs(correlation_with_pt_growth))))

cor_tbl %>% mutate(factor = recode(factor, gdp_growth = "Рост ВВП", employment_growth = "Рост занятости", investment_growth = "Рост инвестиций", consumption_growth = "Рост потребления", gov_spending_growth = "Рост госрасходов", debt_growth = "Рост долга", inflation_change = "Изменение инфляции", ruonia_change = "Изменение RUONIA", trade = "Торговый баланс"), factor = reorder(factor, correlation_with_pt_growth), sign = if_else(correlation_with_pt_growth >= 0, "Положительная", "Отрицательная")) %>% ggplot(aes(correlation_with_pt_growth, factor, fill = sign)) + geom_col() + geom_vline(xintercept = 0, colour = "grey40") + scale_fill_manual(values = c("Положительная" = "#1F4E79", "Отрицательная" = "#C0504D")) + labs(title = "Предварительный screening факторов", subtitle = "Корреляции годовых изменений с ростом ПТ; не причинная оценка", x = "Корреляция", y = NULL, fill = NULL) + theme_minimal(base_size = 11) + theme(legend.position = "bottom")


ccf(d$investment, d$pt) # инвест лаг 1
#
scatter = d %>% select(year, pt_growth, gdp_growth, investment_growth, employment_growth) %>% pivot_longer(-c(year, pt_growth), names_to = "factor", values_to = "value") %>% mutate(factor = recode(factor, gdp_growth = "Рост ВВП", investment_growth = "Рост инвестиций", employment_growth = "Рост занятости"))
ggplot(scatter, aes(value, pt_growth)) + geom_hline(yintercept = 0, colour = "grey80") + geom_vline(xintercept = 0, colour = "grey80") + geom_point(colour = "#1F4E79", size = 2) + geom_smooth(method = "lm", se = TRUE, colour = "#C0504D", linewidth = .7) + facet_wrap(~ factor, scales = "free_x") + labs(title = "ПТ и ключевые факторы: годовые изменения", x = "% изменения фактора", y = "% изменения ПТ") + theme_minimal(base_size = 11)


library(forecast)
#
pt_ts = ts(d$pt, start = min(d$year),frequency = 1)

acf(pt_ts) #1 лаг в MА процессе
pacf(pt_ts) # нет в AR

model <- auto.arima(pt_ts,seasonal = FALSE,stepwise = FALSE,approximation = FALSE)
summary(model)

model_01 = arima(pt_ts, order = c(0,0,1))
summary(model_01)

'ARIMA (0,1,0) 

RMSE 0.0539 < 0.0660
MAE 0.04215 < 0.05053
(MAPE 2.32% < 2.77% и MASE 0.9358 < 1.1220

Дисперсия ошибок тоже меньше, а добавление Ma не добавляет информации'

xreg = d[complete.cases(d[, c("investment", "employment", "gdp")]), ]

model_arimax <- arima(pt_ts, order = c(0,1,0),xreg = d$investment)
summary(model_arimax) 

d$invest_new = d$investment/1000000
model_arimax_1 <- arima(pt_ts, order = c(0,1,0), xreg = d$invest_new) 
summary(model_arimax_1) #регрессор на 5% уровне значим (т-ст = 2)

# Средние темпы роста инвестиций за последние 3 года
xreg_train <- as.matrix(d$invest_new)
model_arimax_1 <- Arima(pt_ts, order = c(0, 1, 0), xreg = xreg_train)

mean_inv <- mean(tail(d$invest_new, 3), na.rm = TRUE)
future_xreg <- matrix(mean_inv, nrow = 3, ncol = 1)

forecast_arimax <- forecast(model_arimax_1, h = 3, xreg = future_xreg)

plot(forecast_arimax)