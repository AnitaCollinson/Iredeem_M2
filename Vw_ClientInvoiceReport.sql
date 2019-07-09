alter
VIEW ird_reporting.Vw_ClientInvoiceReport AS
    SELECT DISTINCT
so.increment_id AS OrderNumber,
ss.increment_id AS PONumber,
ssi.sku AS `PO Item SKU`,
so.created_at AS `Order Date`,
web.name AS Client,
ssi.qty AS Qty,
dc.iso2_code AS ISO2_Code,
dc.iso3_code AS ISO3_Code,
ssi.qty * ((soi.base_row_total / soi.qty_ordered) + (soi.base_tax_amount / soi.qty_ordered) + soi.base_weee_tax_applied_amount - (soi.base_discount_amount / soi.qty_ordered)) AS `Number of points redeemed`,
so.base_to_global_rate AS `Points conversion rate to CL rate`,
soi.points_to_client_rate / so.base_to_global_rate AS `Exchange rate`,
soi.points_to_client_rate AS `Points conversion rate to client rate`,
        (ssi.qty * ((soi.base_row_total / soi.qty_ordered) + (soi.base_tax_amount / soi.qty_ordered) + soi.base_weee_tax_applied_amount - (soi.base_discount_amount / soi.qty_ordered))) * soi.points_to_client_rate AS `Cash equivalent value of the points`,
ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate AS `Net Cash received`,

        ((ssi.qty * ((soi.base_row_total / soi.qty_ordered) + (soi.base_tax_amount / soi.qty_ordered) + soi.base_weee_tax_applied_amount - (soi.base_discount_amount / soi.qty_ordered))) * soi.points_to_client_rate)
        +
        (ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate)
        AS `Gross Retail Value`,

soi.pc_cash_margin_percent AS `Cash Margin %`,

ssi.qty * 
				(soi.pc_cash_base_margin_amount + 
												(soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
				) * soi.points_to_client_rate AS `Cash margin Amount`,

        (ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate)
        +
        (ssi.qty * 
				(soi.pc_cash_base_margin_amount + 
												(soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
				) * soi.points_to_client_rate
		) AS `Total Cash Received`,

ssi.qty * (soi.base_discount_amount / soi.qty_ordered) * soi.points_to_client_rate AS `Discount Amount`,
so.client_currency_code AS Currency,

        (CASE
            WHEN (VI.client_managed = 0) THEN 'No'
            WHEN (VI.client_managed = 1) THEN 'Yes'
        END) AS `client_managed`,
        Null AS `Bank Response`
    FROM
smartredeem.sales_shipment_item ssi
        JOIN smartredeem.sales_order_item soi ON ssi.order_item_id = soi.item_id
        JOIN smartredeem.sales_shipment ss ON ssi.parent_id = ss.entity_id
        JOIN smartredeem.sales_order so ON soi.order_id = so.entity_id
        LEFT JOIN smartredeem.store sto ON sto.store_id = soi.store_id
        LEFT JOIN smartredeem.store_website web ON web.website_id = sto.website_id
        LEFT JOIN smartredeem.iredeem_vendor_information VI ON VI.entity_id = ssi.vendor_id
        LEFT JOIN smartredeem.sales_order_address soa ON soa.entity_id = ssi.entity_id
        LEFT JOIN smartredeem.directory_country dc ON dc.country_id = soa.country_id
    WHERE
ISNULL(soi.parent_item_id)
            AND so.status NOT IN ('pending_payment' , 'decline_pointscash')
