Alter
VIEW ird_reporting.Vw_RefundsAndReturnsReport AS
    SELECT DISTINCT
so.increment_id AS OrderNumber,
ss.increment_id AS PONumnber,
sci.sku AS `PO Item SKU`,
sci.qty AS `PO Refunded Qty`,
sc.created_at AS `Refund Date`,
so.created_at AS `Order Date`,
ss.created_at AS `Shipped Date`,
sci.base_row_total + sci.base_tax_amount + (sci.base_weee_tax_applied_amount * sci.qty) - soi.base_discount_amount AS `Number of points refunded`,
sc.base_adjustment AS `Adjustment Fee`,
sc.base_grand_total AS `Grand Total Refunded`,
sc.base_to_global_rate AS `Points conversion rate to CL rate`,
        (sci.points_to_client_rate / sc.base_to_global_rate) AS `Exchange rate`,
sci.points_to_client_rate AS `Points conversion rate to client rate`,
        (sci.base_row_total + sci.base_tax_amount + (sci.base_weee_tax_applied_amount * sci.qty) - soi.base_discount_amount)
        *
sci.points_to_client_rate
        AS `Cash equivalent value of the points`,
sci.pc_cash_base_row_total_incl_tax AS `Cash Refunded`,
sw.name AS Client,
sc.client_currency_code AS Currency,
sci.qty * (sci.base_price + soi.pc_cash_base_price) * sci.points_to_client_rate AS `Item cost including markup`,
sci.qty * IFNULL(sci.base_cost, 0) * sci.points_to_client_rate AS `Merchant selling price before tax & shipping`,
        (sci.qty * (sci.base_price + soi.pc_cash_base_price) * sci.points_to_client_rate)
        -
        (sci.qty * IFNULL(sci.base_cost, 0) * sci.points_to_client_rate)
        AS `Buying Commission`,
sci.qty * sci.base_weee_tax_applied_amount * sci.points_to_client_rate AS `Shipping cost`,
        (IFNULL(sci.base_tax_amount, 0) + IFNULL(sci.pc_cash_base_tax_amount, 0)) * sci.points_to_client_rate AS Tax,
        (sci.qty * (sci.base_price + soi.pc_cash_base_price) * sci.points_to_client_rate)
        +
        (sci.qty * sci.base_weee_tax_applied_amount * sci.points_to_client_rate)
        +
        ((IFNULL(sci.base_tax_amount, 0) + IFNULL(sci.pc_cash_base_tax_amount, 0)) * sci.points_to_client_rate)
        AS `Total Amount`,
ire.name AS Merchant,
sci.qty * sci.pc_cash_base_price * sci.points_to_client_rate AS `Net Cash received`,
sci.pc_cash_margin_percent AS `Cash Margin %`,
        (
        (sci.qty * sci.pc_cash_base_margin_amount) + sci.pc_cash_base_margin_tax_amount
        ) * sci.points_to_client_rate
        AS `Cash margin Amount`,
soi.vendor_currency AS `Vendor Currency`,
        (CASE
            WHEN (ire.client_managed = 0) THEN 'No'
            WHEN (ire.client_managed = 1) THEN 'Yes'
        END) AS `client_managed`,
        NULL AS `Bank Response`,
        NULL AS OrderStatus
    FROM
        smartredeem.sales_creditmemo_item sci
        JOIN smartredeem.sales_order_item soi ON sci.order_item_id = soi.item_id
        JOIN smartredeem.sales_creditmemo sc ON sci.parent_id = sc.entity_id
        JOIN smartredeem.sales_order so ON sc.order_id = so.entity_id
        JOIN smartredeem.sales_shipment_item ssi ON sci.order_item_id = ssi.order_item_id
        JOIN smartredeem.sales_shipment ss ON ssi.parent_id = ss.entity_id
        LEFT JOIN smartredeem.iredeem_vendor_information ire ON ire.entity_id = ssi.vendor_id
        LEFT JOIN smartredeem.store st ON st.store_id = sc.store_id
        LEFT JOIN smartredeem.store_website sw ON st.website_id = sw.website_id
    WHERE
        ISNULL(soi.parent_item_id)
            AND so.status NOT IN ('pending_payment' , 'decline_pointscash')
            /*AND ire.client_managed = 0*/
