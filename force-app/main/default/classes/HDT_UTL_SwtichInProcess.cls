/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021
 * @description  Classe per la gestione delle date nel processo switch in 
*/
public with sharing class HDT_UTL_SwtichInProcess {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();

    // Calcolo Data Max Ripensamento(MaxAfterthoughtDate__c)  // Solo per clienti residenziali
    public static Date getMaxAfterthoughtDate(Order order) {

        order = orderQr.getRecordById(order.id);
        
        Date signedDate = order.SignedDate__c;   
        Date maxAfterthoughtDate = null;         

        if(order.Channel__c == null){
            system.debug('Impossibile calcolare Data Max Ripensamento per mancanza di Channel');
        }
        if(order.Market__c == null){
            system.debug('Impossibile calcolare Data Max Ripensamento per mancanza di Market');
        }
        if(order.CustomerCategory__c == null){
            system.debug('Impossibile calcolare Data Max Ripensamento per mancanza di CustomerCategory__c');
        }
        if(order.SignatureMethod__c == null){
            system.debug('Impossibile calcolare Data Max Ripensamento per mancanza di SignatureMethod__c');
        }
        if(order.DocSendingMethod__c == null){
            system.debug('Impossibile calcolare Data Max Ripensamento per mancanza di DocSendingMethod__c');
        }
        if(order.SignedDate__c == null){
            system.debug('Impossibile calcolare Data Max Ripensamento per mancanza di SignedDate__c');
        }

        List<HDT_AfterthoughtDays__mdt> afterthoughtDays3 = [ // Giorni di ripensamento
                                                                SELECT AfterthoughtDays__c 
                                                                FROM HDT_AfterthoughtDays__mdt 
                                                                WHERE Channel__c =: order.Channel__c 
                                                                        AND Market__c =: order.Market__c
                                                                        AND AccountType__c =: order.CustomerCategory__c  
                                                                        AND SignatureMode__c =: order.SignatureMethod__c 
                                                                        AND DocumentSendingMode__c =: order.DocSendingMethod__c 
                                                                        WITH SECURITY_ENFORCED
                                                            ];     

        system.debug('Query Data Max Ripensamento: SELECT AfterthoughtDays__c FROM HDT_AfterthoughtDays__mdt WHERE Channel__c = ' + order.Channel__c + ' AND Market__c = ' + order.Market__c +' AND AccountType__c = ' + order.CustomerCategory__c + ' AND SignatureMode__c = ' + order.SignatureMethod__c + 'AND DocumentSendingMode__c = ' + order.DocSendingMethod__c);
        if(afterthoughtDays3.isEmpty()){
            maxAfterthoughtDate = signedDate;                      
        }else{
            if(order.ProcessType__c == 'Cambio offerta'){
                // manca la logica dell'esecuzione anticipata 
                maxAfterthoughtDate = signedDate;            
            }else{
                maxAfterthoughtDate = signedDate.addDays((Integer)afterthoughtDays3[0].AfterthoughtDays__c);                      
            }            
        }        
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate: ' + maxAfterthoughtDate);
        return maxAfterthoughtDate;

    }

    // Data di invio richiesta al SII
    public static Date getDateSentToSii(Order order) {

        order = orderQr.getRecordById(order.id);

        Date signedDate = order.SignedDate__c;   
        Date dateSentToSii= null;
        if(signedDate != null  && order.ProcessType__c != 'Cambio Offerta'){
            if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){

                // DIRITTO DI RINUNCIA DI RIPENSAMENTO
                if (order.WaiverRightAfterthought__c == 'Si') { 
                    dateSentToSii = date.today();
                }else{                    
                    if(order.WizardCompletedDate__c >= getMaxAfterthoughtDate(order)){
                        dateSentToSii= order.WizardCompletedDate__c;
                    }else{
                        dateSentToSii= getMaxAfterthoughtDate(order).addDays(1);
                    }                    
                }
            
            }else{
                dateSentToSii = Date.valueOf(date.today());      
                
                /*
                La data invio richiesta al SII deve essere ricalcolata nel caso in cui il sistema riceva degli esiti di rilavorazione.  
                Alla rilavorazione, la data di invio richiesta deve assumere la data di rilavorazione della richiesta (la data di ultimo aggiornamento fase).  
                Tale ricalcolo potrà essere possibile fino all’esito di ammissibilità ok.  
                Da quel momento in poi il sistema non dovrà più ricalcolare la data invio richiesta al SII. 
                */          
            }
        }
        
        system.debug('HDT_UTL_SwtichInProcess - getDateSentToSii: ' + dateSentToSII);
        return dateSentToSII;

    }

    // Data di decorrenza
    public static Date getEffectiveDate(Order order) {

        Date effectiveDateTmp = null;
        Date dateDecorrenzaTmp = null;
        String processType = PROCESSTYPEBYRRECORDTYPEMAP.get(order.RecordType.DeveloperName);
        order = orderQr.getRecordById(order.id);
        Date dateToFrom = null;
        if(order.ProcessType__c == 'Cambio offerta'){
            dateToFrom = order.SignedDate__c; // Per cambio offerta entrare in tabella con la data firma o la data massima di ripensamento se no esecuzione anticipata
        }else{
            dateToFrom = getDateSentToSii(order);
        }
        
        
        if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
            system.debug('SELECT ActivationDate__c FROM HDT_FulfillmentDateMatrix__c WHERE OriginMarket__c = ' + order.MarketOrigin__c + ' AND Commodity__c = ' + order.ServicePoint__r.CommoditySector__c + ' AND VoltageLevel__c = ' + order.VoltageLevel__c + '  AND ProcessType__c = ' + processType + ' AND SupplyType__c = ' + order.SupplyType__c + ' AND (FulfillmentDateFrom__c <= ' + dateToFrom + ' AND FulfillmentDateTo__c >= ' + dateToFrom + ' )');
            List<HDT_FulfillmentDateMatrix__c> afterthoughtDays = [
                                                                    SELECT ActivationDate__c 
                                                                    FROM HDT_FulfillmentDateMatrix__c 
                                                                    WHERE OriginMarket__c =: order.MarketOrigin__c   
                                                                            AND Commodity__c =: order.ServicePoint__r.CommoditySector__c   
                                                                            AND VoltageLevel__c =: order.VoltageLevel__c 
                                                                            AND ProcessType__c = :processType
                                                                            AND SupplyType__c =: order.SupplyType__c 
                                                                            AND (FulfillmentDateFrom__c <=: dateToFrom AND FulfillmentDateTo__c >=: dateToFrom)
                                                                            WITH SECURITY_ENFORCED
                ];
            if(!afterthoughtDays.isEmpty()){
                effectiveDateTmp = afterthoughtDays[0].ActivationDate__c;
            }else{
                system.debug('Non sono state trovate occorrenze nella tabella di calcolo della data di adempimento');
            }
        }
        else{
            if(order.RecessNotice__c == null){
                
                List<HDT_FulfillmentDateMatrix__c> afterthoughtDays2 = [
                SELECT ActivationDate__c 
                FROM HDT_FulfillmentDateMatrix__c 
                WHERE OriginMarket__c =: order.MarketOrigin__c 
                        AND Commodity__c =: order.ServicePoint__r.CommoditySector__c   
                        AND VoltageLevel__c =: order.VoltageLevel__c 
                        AND ProcessType__c = :processType 
                        AND SupplyType__c =: order.SupplyType__c 
                        AND (FulfillmentDateFrom__c <= :dateToFrom AND FulfillmentDateTo__c >= :dateToFrom)
                        WITH SECURITY_ENFORCED
                ];

                effectiveDateTmp = afterthoughtDays2[0].ActivationDate__c;
            }else{
                dateDecorrenzaTmp = dateToFrom.addMonths((Integer)order.RecessNotice__c);
                effectiveDateTmp = dateDecorrenzaTmp.addMonths(1).toStartofMonth();
            }
        } 

        system.debug('Data di decorrenza: ' + effectiveDateTmp);
        return effectiveDateTmp;
    }


    // verifica con luca cambio offerta
    public static final Map<String,String> PROCESSTYPEBYRRECORDTYPEMAP = new Map<String,String>{  
        'HDT_RT_OrderDossier' => '',
        'HDT_RT_Subentro' => '',
        'HDT_RT_Default' => '',
        'HDT_RT_Voltura' => '',
        'HDT_RT_SwitchIn' => 'Switch In',
        'isReseller' => 'Switch In Reseller',
        'HDT_RT_ScontiBonus' => '',
        'HDT_RT_VAS' => ''
    };
    
}