WITH monthly_revenue AS (
    SELECT
        p.user_id,
        DATE_TRUNC('month', p.payment_date)::date AS report_month,
        u.language,
        u.age,
        p.game_name,
        SUM(p.revenue_amount_usd) AS amount
    FROM project.games_payments p
    JOIN project.games_paid_users u
        ON p.user_id = u.user_id
       AND p.game_name = u.game_name
    WHERE p.revenue_amount_usd > 0
    GROUP BY 1, 2, 3, 4, 5
),

user_history AS (
    SELECT
        mr.*,
        MIN(mr.report_month) OVER (
            PARTITION BY mr.user_id, mr.game_name
        ) AS first_paid_month,
        LAG(mr.report_month) OVER (
            PARTITION BY mr.user_id, mr.game_name
            ORDER BY mr.report_month
        ) AS prev_paid_month,
        LAG(mr.amount) OVER (
            PARTITION BY mr.user_id, mr.game_name
            ORDER BY mr.report_month
        ) AS prev_amount,
        LEAD(mr.report_month) OVER (
            PARTITION BY mr.user_id, mr.game_name
            ORDER BY mr.report_month
        ) AS next_paid_month
    FROM monthly_revenue mr
)
SELECT
    *,
    -- Технічне поле: наступний місяць після оплати (місяць потенційного відтоку)
    (report_month + INTERVAL '1 month')::date AS churn_month,

    -- Класифікація типу доходу (MRR Segmentation)
    CASE
        WHEN report_month = first_paid_month THEN 'New'
        -- Якщо пройшло більше 1 місяця з попередньої оплати — це повернення
        WHEN prev_paid_month < (report_month - INTERVAL '1 month')::date THEN 'Back from Churn'
        WHEN amount > prev_amount THEN 'Expansion'
        WHEN amount < prev_amount THEN 'Contraction'
        ELSE 'Retained'
    END AS mrr_type,

    -- Колонки-метрики для Tableau (Measures)
    CASE WHEN report_month = first_paid_month THEN amount ELSE 0 END AS new_mrr,
    
    CASE 
        WHEN report_month <> first_paid_month 
        AND prev_paid_month < (report_month - INTERVAL '1 month')::date 
        THEN amount ELSE 0 
    END AS back_from_churn_revenue,

    CASE 
        WHEN next_paid_month IS NULL OR next_paid_month > (report_month + INTERVAL '1 month')::date 
        THEN amount ELSE 0 
    END AS churned_revenue,
    CASE 
        WHEN next_paid_month IS NULL OR next_paid_month > (report_month + INTERVAL '1 month')::date 
        THEN 1 ELSE 0 
    END AS churned_users
FROM user_history
ORDER BY report_month, game_name, user_id;