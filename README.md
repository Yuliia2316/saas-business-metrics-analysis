# Аналіз бізнес-метрик SaaS (Revenue & Churn)

Проєкт присвячений розрахунку ключових показників ефективності для підписної моделі (SaaS) та їх візуалізації.

## 🛠 Технології
- SQL (PostgreSQL): Розрахунок MRR, LTV та Churn Rate за допомогою віконних функцій (`LAG`, `LEAD`, `FIRST_VALUE`).
- Tableau: Побудова інтерактивного дашборда для аналізу ефективності (Efficiency Metrics).

## 📈 Ключові етапи
1. Обробка даних: написання складного запиту для сегментації доходу на New, Expansion, Contraction та Churn.
2. Аналіз метрик: розрахунок ARPPU та середнього чека у розрізі ігор та мов.
3. Візуалізація: створення дашборда для відстеження динаміки доходу в реальному часі.

## 🔗 Посилання
- https://public.tableau.com/views/SaaSRevenueMetricsChurnAnalysisDashboard/EfficiencyMetrics?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link
