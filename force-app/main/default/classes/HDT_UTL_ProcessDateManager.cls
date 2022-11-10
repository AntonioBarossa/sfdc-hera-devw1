public with sharing class HDT_UTL_ProcessDateManager {

	@AuraEnabled
	public static Boolean isAfterthoughtDaysZero(Order order){
		try {
			
			List<HDT_AfterthoughtDays__mdt> afterthoughtDays = [SELECT AfterthoughtDays__c FROM HDT_AfterthoughtDays__mdt WHERE 
			Channel__c =: order.Channel__c AND 
			Market__c =: order.Market__c AND 
			AccountType__c =: order.CustomerCategory__c AND 
			SignatureMode__c =: order.SignatureMethod__c AND 
			DocumentSendingMode__c =: order.DocSendingMethod__c
			WITH SECURITY_ENFORCED];

			return ( afterthoughtDays[0].AfterthoughtDays__c == 0 );

		} catch (Exception e) {
			return false;
		}
	}

    public static void calculateOrderProcessDate(List<Order> orderList){
		List<Order> nonDomOrderList = new List<Order>();
		List<Order> domOrderList = new List<Order>();
		for(Order order : orderList){
			if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale' || (order.RecessNotice__c == null || (order.RecessNotice__c != null && order.RecessNotice__c == 0))){
				domOrderList.add(order);
			}else {
				nonDomOrderList.add(order);
			}
		}
		if(!domOrderList.isEmpty()){
			setMaxAfterthoughtDate(orderList);
			setDateSentToSii(orderList);
			setEffectiveDate(orderList);
		}
        if(!nonDomOrderList.isEmpty()){
			handleBusinessDate(orderList);
		}
    }
    public static void setMaxAfterthoughtDate(List<Order> orderList) {
		if(!orderList.isEmpty()){
			Order order = orderList[0];
			Date signedDate = order.SignedDate__c;   
			Date maxAfterthoughtDate = null;
			Set<String> processToCalculate = new Set<String>{'SWITCH IN', 'CAMBIO OFFERTA'};
			
			// Giorni di ripensamento
			List<HDT_AfterthoughtDays__mdt> afterthoughtDays = [SELECT AfterthoughtDays__c FROM HDT_AfterthoughtDays__mdt WHERE 
				Channel__c =: order.Channel__c AND 
				Market__c =: order.Market__c AND 
				AccountType__c =: order.CustomerCategory__c AND 
				SignatureMode__c =: order.SignatureMethod__c AND 
				DocumentSendingMode__c =: order.DocSendingMethod__c
			WITH SECURITY_ENFORCED];

			if(afterthoughtDays.isEmpty() && signedDate != null){
				maxAfterthoughtDate = signedDate;                      
			}
			else if(signedDate != null){
				maxAfterthoughtDate = signedDate.addDays((Integer)afterthoughtDays[0].AfterthoughtDays__c);                              
			}
			if(maxAfterthoughtDate != null){
				for(Order singleOrder : orderList){
					if(processToCalculate.contains(singleOrder.DocumentalProcessType__c?.toUpperCase()))
					singleOrder.MaxAfterthoughtDate__c = maxAfterthoughtDate;
				}
			}
		}
    }

    public static void setDateSentToSii(List<Order> orderList) {
        if(!orderList.isEmpty()){
            for(Order order : orderList){
                Date signedDate = order.SignedDate__c;
                if (order.WizardCompletedDate__c==null) {
                    order.WizardCompletedDate__c = Date.today();
                }
    
                Date dateSentToSii= null;
                if(signedDate != null  && order.ProcessType__c != null &&  order.ProcessType__c.containsIgnoreCase('Switch In')){
                    //if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
                        // DIRITTO DI RINUNCIA DI RIPENSAMENTO
                        if (order.WaiverRightAfterthought__c == 'Si') { 
                            dateSentToSii = Date.today();
                        }
                        else if(order.IsEarlyActivation__c) {
                            dateSentToSii = order.WizardCompletedDate__c;
                        }
                        else{
                            Date dataRipensamento = order.MaxAfterthoughtDate__c;
                            if(dataRipensamento != null && order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale' ){
								if(dataRipensamento > Date.Today()){
									dateSentToSii = dataRipensamento.addDays(1);
								}else if(dataRipensamento < Date.Today()){
									dateSentToSii = Date.today();
								}
								else {
									dateSentToSii = dataRipensamento;
								}
                            }else {
								dateSentToSii = Date.today();
							}
                        }            
                    //}
                }else {
                    continue;
                }
				if(dateSentToSii != null){
					order.DateSentToSII__c = dateSentToSii;
				}
            }
        }
    }
	public static void setEffectiveDateBusiness(List<Order> orderList){
		for(Order order : orderList){
			Date signDate = order.SignedDate__c;
			if(!order.IsActivationDeferred__c){
				if(order.DocumentalProcessType__c.equalsIgnoreCase('Switch In') && order.ClientCategoryFormula__c != 'Famiglie'){
					if (order.RecessNotice__c == null) {
						order.RecessNotice__c = 0;
					}
					Date dateDecorrenzaTmp = signDate.addMonths((Integer)order.RecessNotice__c);
					Date effectiveDateTmp = dateDecorrenzaTmp.addMonths(1).toStartofMonth();
					order.EffectiveDate__c = effectiveDateTmp;
				}
			}
		}
	}
	public static void setDateSentToSiiBusiness(List<Order> orderList){
		List<FulfillmentDateMatrix__c> dateMatrix = getFulfillmentDate(orderList);
		Date dateToFrom;
		for(Order order : orderList){
			//CAMBIO OFFERTA DATA FIRMA - SWITCH IN DATA INVIO SII
			if(order.DocumentalProcessType__c.equalsIgnoreCase('Switch In')){
				dateToFrom = order.EffectiveDate__c;
			}else if(order.EffectiveDate__c == null){
				continue;
			}else {
				continue;
			}
			if(!order.IsActivationDeferred__c){
				order.DateSentToSII__c = order.WizardCompletedDate__c != null? order.WizardCompletedDate__c:Date.today();
			}else if(dateToFrom != null){
				Boolean founded = false;
				for(FulfillmentDateMatrix__c singleRecord : dateMatrix){
						founded = false;
						if(order.CommodityFormula__c != null && 'Gas'.equalsIgnoreCase(order.CommodityFormula__c)){
							if(
								singleRecord.OriginMarket__c.equalsIgnoreCase(order.MarketOrigin__c) &&
								singleRecord.Commodity__c.equalsIgnoreCase(order.CommodityFormula__c) &&	
								singleRecord.ProcessType__c.equalsIgnoreCase(order.DocumentalProcessType__c) &&	
								singleRecord.SupplyType__c.equalsIgnoreCase(order.SupplyType__c) &&	
								singleRecord.ActivationDate__c == dateToFrom
							){
								founded = true;
							}else {
								founded = false; 
							}
						}
						else if(order.CommodityFormula__c != null && 'Energia Elettrica'.equalsIgnoreCase(order.CommodityFormula__c)){
							if(
								singleRecord.OriginMarket__c.equalsIgnoreCase(order.MarketOrigin__c) &&
								singleRecord.Commodity__c.equalsIgnoreCase(order.CommodityFormula__c) &&	
								singleRecord.ProcessType__c.equalsIgnoreCase(order.DocumentalProcessType__c) &&	
								singleRecord.SupplyType__c.equalsIgnoreCase(order.SupplyType__c) &&
								singleRecord.VoltageLevel__c != null && singleRecord.VoltageLevel__c.equalsIgnoreCase(order.VoltageLevel__c) &&	
								singleRecord.ActivationDate__c == dateToFrom
							){
								founded = true;
							}else {
								founded = false; 
							}
						}
						if(founded){
							Date targetDate = singleRecord.FulfillmentDateFrom__c;
							Integer preavviso = order.RecessNotice__c != null? (Integer)order.RecessNotice__c:0;
							Integer month = 1 - preavviso;
							Date siiDate = targetDate.addMonths(month).toStartofMonth();
							order.DateSentToSII__c = siiDate;
							break;
						}
					}
				}
		}
	}
	public static void handleBusinessDate(List<Order> orderList){
		if(!orderList.isEmpty()){
			setMaxAfterthoughtDate(orderList);
			setEffectiveDateBusiness(orderList);
			setDateSentToSiiBusiness(orderList);
		}
	}

	private static List<FulfillmentDateMatrix__c> getFulfillmentDate(List<Order> orderList){
		Set<String> marketSet = new Set<String>();
		Set<String> commoditySet = new Set<String>();
		Set<String> voltageSet = new Set<String>();
		Set<String> processTypeSet = new Set<String>();
		Set<String> supplySet = new Set<String>();
		Date nowDate = Date.today();
		Date dateFrom = Date.newInstance(nowDate.year(),01,01);
		for(Order order : orderList){
			marketSet.add(order.MarketOrigin__c);
			commoditySet.add(order.CommodityFormula__c);
			voltageSet.add(order.VoltageLevel__c);
			processTypeSet.add(order.DocumentalProcessType__c);
			supplySet.add(order.SupplyType__c);
		}
		List<FulfillmentDateMatrix__c> matrixDate = [SELECT ActivationDate__c,OriginMarket__c,Commodity__c,VoltageLevel__c,ProcessType__c,SupplyType__c,FulfillmentDateFrom__c,FulfillmentDateTo__c FROM FulfillmentDateMatrix__c WHERE
			OriginMarket__c IN:marketSet AND 
			Commodity__c IN:commoditySet AND 
			(VoltageLevel__c IN:voltageSet OR  VoltageLevel__c = '') AND
			ProcessType__c IN:processTypeSet AND 
			SupplyType__c IN:supplySet AND 
			FulfillmentDateTo__c >=: dateFrom 
		WITH SECURITY_ENFORCED];
		
		return matrixDate;
	}
    public static void setEffectiveDate(List<Order> orderList) {
		if(!orderList.isEmpty()){
			Date dateToFrom = null;
			List<FulfillmentDateMatrix__c> dateMatrix = getFulfillmentDate(orderList);
			
			for(Order order : orderList){
				//CAMBIO OFFERTA DATA FIRMA - SWITCH IN DATA INVIO SII
				if(order.DocumentalProcessType__c != null && order.DocumentalProcessType__c.equalsIgnoreCase('Cambio offerta')){
					dateToFrom = order.SignedDate__c;
				}else if(order.DocumentalProcessType__c != null && order.DocumentalProcessType__c.equalsIgnoreCase('Switch In')){
					dateToFrom = order.DateSentToSII__c;
				}else if(order.EffectiveDate__c == null){
					order.EffectiveDate__c = order.SignedDate__c;
					continue;
				}

				if (order.IsActivationDeferred__c==true) {
					continue;
				}
				
				if( order.SignedDate__c != null && ( order.DocumentalProcessType__c.equalsIgnoreCase('Voltura') || order.DocumentalProcessType__c.equalsIgnoreCase('Voltura con autolettura') ) ){
					order.EffectiveDate__c = order.SignedDate__c.addDays(3);
				}

				if(dateToFrom != null){
                    Boolean founded = false;
					for(FulfillmentDateMatrix__c singleRecord : dateMatrix){
                            founded = false;
							if(order.CommodityFormula__c != null && 'Gas'.equalsIgnoreCase(order.CommodityFormula__c)){
								if(
									singleRecord.OriginMarket__c.equalsIgnoreCase(order.MarketOrigin__c) &&
									singleRecord.Commodity__c.equalsIgnoreCase(order.CommodityFormula__c) &&	
									singleRecord.ProcessType__c.equalsIgnoreCase(order.DocumentalProcessType__c) &&	
									singleRecord.SupplyType__c.equalsIgnoreCase(order.SupplyType__c) &&	
									singleRecord.FulfillmentDateFrom__c <= 	dateToFrom &&
									singleRecord.FulfillmentDateTo__c >= dateToFrom
								){
									order.EffectiveDate__c = singleRecord.ActivationDate__c;
									order.AttributesCatalogDesc__c = 'Calcolata Data Order Gas il ' + Date.today() + 'con il seguente valore: ' + singleRecord.ActivationDate__c + ' Record utilizzato ' + singleRecord.Id;
                                    founded = true;
								}else {
                                    founded = false; 
                                }
							}
							else if(order.CommodityFormula__c != null && 'Energia Elettrica'.equalsIgnoreCase(order.CommodityFormula__c)){
								if(
									singleRecord.OriginMarket__c.equalsIgnoreCase(order.MarketOrigin__c) &&
									singleRecord.Commodity__c.equalsIgnoreCase(order.CommodityFormula__c) &&	
									singleRecord.ProcessType__c.equalsIgnoreCase(order.DocumentalProcessType__c) &&	
									singleRecord.SupplyType__c.equalsIgnoreCase(order.SupplyType__c) &&
									singleRecord.VoltageLevel__c != null && singleRecord.VoltageLevel__c.equalsIgnoreCase(order.VoltageLevel__c) &&	
									singleRecord.FulfillmentDateFrom__c <= 	dateToFrom &&
									singleRecord.FulfillmentDateTo__c >= 	dateToFrom
								){
									order.EffectiveDate__c = singleRecord.ActivationDate__c;
									order.AttributesCatalogDesc__c = 'Calcolata Data Order Ele il ' + Date.today() + ' con il seguente valore: ' + singleRecord.ActivationDate__c + ' Record utilizzato ' + singleRecord.Id;
                                    founded = true;
								}else {
                                    founded = false; 
                                }
							}
                            if(founded){
                                System.debug(order.EffectiveDate__c + ' ' + singleRecord);
                                break;
                            }
						}
					}
				}
		}
    }
}
