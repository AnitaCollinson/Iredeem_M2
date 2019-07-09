Alter
VIEW ird_reporting.Vw_Tableau_Merchant AS
    SELECT 
        ss.shipping_date AS `Shipped Date`,
        so.increment_id AS OrderNumber,
        ss.increment_id AS PONumber,
        ssi.sku AS `PO Item SKU`,
        ire.name AS Merchant,
        web.name AS Client,
        ssi.qty AS Qty,
        ssi.qty * (
					IFNULL(soi.base_price, 0) + IFNULL(soi.pc_cash_base_price, 0)
				  )
                  * IFNULL(soi.points_to_client_rate, 0)
                  * IFNULL(soi.vendor_to_client_rate, 0) AS `Item cost including markup`,
        soi.tax_percent AS TaxPercentage,

        ssi.qty * IFNULL(soi.base_cost, 0) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0) AS `Merchant selling price before tax & shipping`,
        (ssi.qty * (
					IFNULL(soi.base_price, 0) + IFNULL(soi.pc_cash_base_price, 0)
				  )
                  * IFNULL(soi.points_to_client_rate, 0)
                  * IFNULL(soi.vendor_to_client_rate, 0)
		)
        -
        (ssi.qty * IFNULL(soi.base_cost, 0) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        AS `Buying Commission`,

        ssi.qty * (IFNULL(soi.base_tax_amount, 0) / IFNULL(soi.qty_ordered, 0)) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0) AS `Points Tax`,

        ssi.qty * ((soi.pc_cash_base_tax_amount / IFNULL(soi.qty_ordered, 0)) + (soi.pc_cash_base_margin_tax_amount / IFNULL(soi.qty_ordered, 0))) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0) AS `Cash Tax`,

        (ssi.qty * (IFNULL(soi.base_tax_amount, 0) / IFNULL(soi.qty_ordered, 0)) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        +
        (ssi.qty * ((soi.pc_cash_base_tax_amount / IFNULL(soi.qty_ordered, 0)) + (soi.pc_cash_base_margin_tax_amount / IFNULL(soi.qty_ordered, 0))) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        AS Tax,

        ssi.qty * soi.base_weee_tax_applied_amount * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0) AS `Shipping cost`,
        (ssi.qty * IFNULL(soi.base_cost, 0) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        +
        ((ssi.qty * (IFNULL(soi.base_tax_amount, 0) / IFNULL(soi.qty_ordered, 0)) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        +
        (ssi.qty * ((soi.pc_cash_base_tax_amount / IFNULL(soi.qty_ordered, 0)) + (soi.pc_cash_base_margin_tax_amount / IFNULL(soi.qty_ordered, 0))) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0)))
        +
        (ssi.qty * soi.base_weee_tax_applied_amount * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        AS `Merchant Settlement Amount`,

        soi.vendor_currency AS `Merchant Currency`,

		(ssi.qty * (
					IFNULL(soi.base_price, 0) + IFNULL(soi.pc_cash_base_price, 0)
				  )
                  * IFNULL(soi.points_to_client_rate, 0)
                  * IFNULL(soi.vendor_to_client_rate, 0)
		)
        +
        (ssi.qty * soi.base_weee_tax_applied_amount * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        +
        (        (ssi.qty * (IFNULL(soi.base_tax_amount, 0) / IFNULL(soi.qty_ordered, 0)) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0))
        +
        (ssi.qty * ((soi.pc_cash_base_tax_amount / IFNULL(soi.qty_ordered, 0)) + (soi.pc_cash_base_margin_tax_amount / IFNULL(soi.qty_ordered, 0))) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0)))

        AS `Gross Order Value`,

        ssi.qty * (soi.base_discount_amount / IFNULL(soi.qty_ordered, 0)) * IFNULL(soi.points_to_client_rate, 0) * IFNULL(soi.vendor_to_client_rate, 0) AS `Discount Amount`,
        so.client_currency_code AS `Client Currency`
    FROM
        smartredeem.sales_shipment_item ssi
        JOIN smartredeem.sales_order_item soi ON ssi.order_item_id = soi.item_id
        JOIN smartredeem.sales_shipment ss ON ssi.parent_id = ss.entity_id
        JOIN smartredeem.sales_order so ON soi.order_id = so.entity_id
        LEFT JOIN smartredeem.iredeem_vendor_information ire ON ire.entity_id = ssi.vendor_id
        LEFT JOIN smartredeem.store sto ON sto.store_id = soi.store_id
        LEFT JOIN smartredeem.store_website web ON web.website_id = sto.website_id
    WHERE
        (ISNULL(soi.parent_item_id)
            AND (so.status NOT IN ('pending_payment' , 'decline_pointscash'))
            AND (ss.dropship_status IN ('1' , '7', '12'))
            AND (ire.client_managed = 0))
