public with sharing class HDT_UTL_ProcessDateManager {

    public static void calculateOrderProcessDate(List<Order> orderList){
        setMaxAfterthoughtDate(orderList);
        setDateSentToSii(orderList);
        setEffectiveDate(orderList);
    }
    public static void setMaxAfterthoughtDate(List<Order> orderList) {
		if(!orderList.isEmpty()){
			Order order = orderList[0];
			Date signedDate = order.SignedDate__c;   
			Date maxAfterthoughtDate = null;
			
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
                if(signedDate != null  && order.ProcessType__c.contains('Switch In')){
                    if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
                        // DIRITTO DI RINUNCIA DI RIPENSAMENTO
                        if (order.WaiverRightAfterthought__c == 'Si') { 
                            dateSentToSii = Date.today();
                        }
                        else if(order.IsEarlyActivation__c) {
                            dateSentToSii = order.WizardCompletedDate__c;
                        }
                        else{
                            Date dataRipensamento = order.MaxAfterthoughtDate__c;
                            if(dataRipensamento != null){
                                dateSentToSii = dataRipensamento.addDays(1);
                            }
                        }            
                    }
                    else{
                        dateSentToSii = order.WizardCompletedDate__c;
                    }
                }else {
                    break;
                }
                order.DateSentToSII__c = dateSentToSii;
            }
        }
    }

    public static void setEffectiveDate(List<Order> orderList) {
		if(!orderList.isEmpty()){
			Date dateToFrom = null;
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
			List<FulfillmentDateMatrix__c> afterthoughtDays = [SELECT ActivationDate__c,OriginMarket__c,Commodity__c,VoltageLevel__c,ProcessType__c,SupplyType__c,FulfillmentDateFrom__c,FulfillmentDateTo__c FROM FulfillmentDateMatrix__c WHERE
                OriginMarket__c IN:marketSet AND 
                Commodity__c IN:commoditySet AND 
                (VoltageLevel__c IN:voltageSet OR  VoltageLevel__c = '') AND
                ProcessType__c IN:processTypeSet AND 
                SupplyType__c IN:supplySet AND 
                FulfillmentDateTo__c >=: dateFrom 
            WITH SECURITY_ENFORCED];
			
			for(Order order : orderList){
				//CAMBIO OFFERTA DATA FIRMA - SWITCH IN DATA INVIO SII
				if(order.DocumentalProcessType__c.equalsIgnoreCase('Cambio offerta')){
					dateToFrom = order.SignedDate__c;
				}else if(order.DocumentalProcessType__c.equalsIgnoreCase('Switch In')){
					dateToFrom = order.DateSentToSII__c;
				}else if(order.EffectiveDate__c == null){
					order.EffectiveDate__c = order.SignedDate__c;
					break;
				}

				if (order.IsActivationDeferred__c==true) {
					break;
				}
				//SWITCH IN BUSINESS CON PREAVVISO DI RECESSO - DATA FIRMA + GG RECESSO + 1 MESE
				if(order.DocumentalProcessType__c.equalsIgnoreCase('Switch In') && order.ClientCategoryFormula__c != 'Famiglie' && order.RecessNotice__c != null){
					Date dateDecorrenzaTmp = dateToFrom.addMonths((Integer)order.RecessNotice__c);
                    Date effectiveDateTmp = dateDecorrenzaTmp.addMonths(1).toStartofMonth();
					order.EffectiveDate__c = effectiveDateTmp;
					break;
				}
				
				if(dateToFrom != null){
                    Boolean founded = false;
					for(FulfillmentDateMatrix__c singleRecord : afterthoughtDays){
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
