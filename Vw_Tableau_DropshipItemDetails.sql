Alter
VIEW ird_reporting.Vw_Tableau_DropshipItemDetails AS
    SELECT DISTINCT
        soi.qty_refunded AS `Refunded Qty`,
        (ssi.qty * ((soi.row_total / soi.qty_ordered) + (soi.tax_amount / soi.qty_ordered) + soi.weee_tax_applied_amount - (soi.discount_amount / soi.qty_ordered)))
        -
        (soi.amount_refunded + soi.tax_refunded + (soi.weee_tax_applied_amount * soi.qty_refunded) - soi.discount_refunded) AS `PO Net Total`,

        (
         soi.pc_cash_base_amount_refunded + 
         soi.pc_cash_base_tax_refunded + 
        (so.pc_cash_base_margin_amount_refunded * soi.qty_refunded) + 
         so.pc_cash_base_margin_tax_amount_refunded
        ) *
         sci.points_to_client_rate
        AS `Refunded Amount Cash`,

        (ssi.qty - soi.qty_refunded) AS `Net Quantity`,
        so.increment_id AS OrderNumber,
        NULL AS `OE Number`,
        NULL AS `Partner Ref`,
        NULL AS `Shipping Address`,
        so.member_id AS CIN,
        so.created_at AS `Order Date`,
        so.status AS `Order Status`,
        NULL AS `Order Type`,
        ss.increment_id AS PONumber,
        ss.created_at AS PODate,
        ss.dropship_status AS `PO Status`,
        ire.name AS Vendor,
        ssi.sku AS `PO Item SKU`,
        soi.product_options AS `PO Item Pricing Option`,
        ssi.name AS `PO Item Name`,
        NULL AS `eVoucher Code`,
        soi.original_price AS `PO Item Original Price`,
        ssi.price AS `PO Item Price`,
        soi.pc_cash_base_price AS `PO Item Price Cash`,
        soi.discount_amount AS `PO Item Discount`,
        IFNULL(soi.base_cost, 0) AS `PO Item Cost`,
        ssi.qty AS `PO Item Qty`,
        soi.amount_refunded + soi.tax_refunded + (soi.weee_tax_applied_amount * soi.qty_refunded) - soi.discount_refunded AS `Refunded Amount`,
        sc.adjustment AS `Adjustment Fee`,
        so.total_refunded AS `Grand Total Refunded`,
        soi.qty_refunded AS Refunded,
        (ssi.qty * (soi.tax_amount / soi.qty_ordered)) AS `PO Item Tax`,
        ssi.qty * ((soi.row_total / soi.qty_ordered) + (soi.tax_amount / soi.qty_ordered) + soi.weee_tax_applied_amount - (soi.discount_amount / soi.qty_ordered)) AS `PO Item Row Total`,
        soi.points_to_client_rate AS `Points To Client Rate`,
        ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate AS `PO Row Total Cash`,
        IFNULL(ssi.qty, 0) * IFNULL(soi.base_cost, 0) * soi.points_to_client_rate AS `Cost Client Rate`,
        ssi.qty * soi.base_weee_tax_applied_amount * soi.points_to_client_rate AS `Shipping Client Rate`,
        ssi.qty * (
                   (soi.base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
				  ) 
                  * soi.points_to_client_rate
                  AS `Tax Client Rate`,

        (ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate)
        -
        (IFNULL(ssi.qty, 0) * IFNULL(soi.base_cost, 0) * soi.points_to_client_rate)
        -
        (ssi.qty * soi.base_weee_tax_applied_amount * soi.points_to_client_rate)
        -
        (
        ssi.qty * (
                   (soi.base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
				  ) 
                  * soi.points_to_client_rate
        )
        AS `Buying Margin Total Client Rate`,

        (sci.pc_cash_base_row_total_incl_tax * soi.points_to_client_rate) / 
        (
         (
          ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate
         )
        *
		 (
			  (
                ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate)
				-
				(IFNULL(ssi.qty, 0) * IFNULL(soi.base_cost, 0) * soi.points_to_client_rate)
				-
				(ssi.qty * soi.base_weee_tax_applied_amount * soi.points_to_client_rate)
				-
				(
				ssi.qty * (
						   (soi.base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
						  ) 
						  * soi.points_to_client_rate
			  )
		 )
        )
        AS `Buying Margin Cash Client Rate`,

        (
				(ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate)
				-
				(IFNULL(ssi.qty, 0) * IFNULL(soi.base_cost, 0) * soi.points_to_client_rate)
				-
				(ssi.qty * soi.base_weee_tax_applied_amount * soi.points_to_client_rate)
				-
				(
				ssi.qty * (
						   (soi.base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
						  ) 
						  * soi.points_to_client_rate
				)
        )
        -
        (
				(sci.pc_cash_base_row_total_incl_tax * soi.points_to_client_rate) / 
				(
				 (
				  ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate
				 )
				*
				 (
					  (
						ssi.qty * (soi.pc_cash_base_price + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + soi.pc_cash_base_margin_amount + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)) * soi.points_to_client_rate)
						-
						(IFNULL(ssi.qty, 0) * IFNULL(soi.base_cost, 0) * soi.points_to_client_rate)
						-
						(ssi.qty * soi.base_weee_tax_applied_amount * soi.points_to_client_rate)
						-
						(
						ssi.qty * (
								   (soi.base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_tax_amount / soi.qty_ordered) + (soi.pc_cash_base_margin_tax_amount / soi.qty_ordered)
								  ) 
								  * soi.points_to_client_rate
					  )
				 )
				)
        )
        AS `Buying Margin Points Client Rate`

    FROM
        smartredeem.sales_shipment_item ssi
        JOIN smartredeem.sales_order_item soi ON ssi.order_item_id = soi.item_id
        JOIN smartredeem.sales_order so ON soi.order_id = so.entity_id
        JOIN smartredeem.sales_creditmemo sc ON so.entity_id = sc.order_id
        JOIN smartredeem.sales_shipment ss ON ssi.parent_id = ss.entity_id
        JOIN smartredeem.sales_creditmemo_item sci ON sci.order_item_id = ssi.order_item_id
        JOIN smartredeem.sales_order_address soa ON so.shipping_address_id = soa.entity_id
        LEFT JOIN smartredeem.iredeem_vendor_information ire ON ire.entity_id = ssi.vendor_id
    WHERE
        (ISNULL(soi.parent_item_id)
            AND (so.status NOT IN ('pending_payment' , 'decline_pointscash'))
            /*AND (ire.client_managed = 0)*/)
