/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021
 * @description  Classe per la gestione delle date nel processo switch in 
*/
public with sharing class HDT_UTL_SwtichInProcess {
    

    // Calcolo Data Max Ripensamento(MaxAfterthoughtDate__c)  // Solo per clienti residenziali
    public static Date getMaxAfterthoughtDate(Order order) {

        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - Channel__c: ' + order.Channel__c );
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - Market__c: ' + order.Market__c  );
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - AccountType__c: ' + order.CustomerCategory__c );
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - SignatureMode__c: ' + order.SignatureMethod__c );
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - DocumentSendingMode__c: ' + order.DocSendingMethod__c );
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - SignedDate: ' + order.SignedDate__c );

        Date signedDate = order.SignedDate__c;   
        Date maxAfterthoughtDate = null;  
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
        if(signedDate != null){
            system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - AfterthoughtDays__c: ' + (Integer)afterthoughtDays3[0].AfterthoughtDays__c );
            maxAfterthoughtDate = signedDate.addDays((Integer)afterthoughtDays3[0].AfterthoughtDays__c);                      
        }   

    
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate: ' + MaxAfterthoughtDate);
        return MaxAfterthoughtDate;

    }


    public static Date getDateSentToSii(Order order) {

        Date signedDate = order.SignedDate__c;   
        Date dateSentToSii= null;

        if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){

        

            if(signedDate != null){ 
                if(order.WizardCompletedDate__c > getMaxAfterthoughtDate(order)){
                    dateSentToSii= order.WizardCompletedDate__c;
                }else{
                    dateSentToSii= getMaxAfterthoughtDate(order).addDays(1);
                }
            }else{ 
                if(order.WizardCompletedDate__c != null){
                    dateSentToSii= order.WizardCompletedDate__c; 
                }else{
                    dateSentToSii= date.today(); 
                }
                
            }


            // if(DateSentToSII.day() < 10){
            //     dateSentToSii= DateSentToSII.addMonths(1).toStartofMonth();  
            // }else{
            //     dateSentToSii= DateSentToSII.addMonths(2).toStartofMonth();  
            // }
            
            // if (order.WaiverRightAfterthought__c == 'Si') { 
            //     dateSentToSii= order.WizardCompletedDate__c;
            // }
        
        }else{
            dateSentToSii= order.WizardCompletedDate__c;    
            /*
            La data invio richiesta al SII deve essere ricalcolata nel caso in cui il sistema riceva degli esiti di rilavorazione.  
            Alla rilavorazione, la data di invio richiesta deve assumere la data di rilavorazione della richiesta (la data di ultimo aggiornamento fase).  
            Tale ricalcolo potrà essere possibile fino all’esito di ammissibilità ok.  
            Da quel momento in poi il sistema non dovrà più ricalcolare la data invio richiesta al SII. 
            */          
        }

        system.debug('HDT_UTL_SwtichInProcess - getDateSentToSii: ' + dateSentToSII);
        return dateSentToSII;

    }

    // public static Date getActivatedDate(Order order) {
        
    //     Date DateSentToSII_tmp = getDateSentToSii(order);
    //     Date ActivatedDate_tmp = null;
    //     if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
    //         if(DateSentToSII_tmp.day() <= 10){
    //             ActivatedDate_tmp = DateSentToSII_tmp.addMonths(1).toStartofMonth();  
    //         }else{
    //             ActivatedDate_tmp = DateSentToSII_tmp.addMonths(2).toStartofMonth();  
    //         }
    //     }
    //     else{
    //         if(DateSentToSII_tmp.day() <= 10 && order.RecessNotice__c  != null){
    //             ActivatedDate_tmp = DateSentToSII_tmp.addMonths(1).toStartofMonth();  // Aggiunto in HDT_QR_Order.getRecordById
    //         }
    //         if(DateSentToSII_tmp.day() > 10 && order.RecessNotice__c  != null){
    //             ActivatedDate_tmp = DateSentToSII_tmp.addMonths(2).toStartofMonth();  // Aggiunto in HDT_QR_Order.getRecordById
    //         }  
    //     }
    //     system.debug('HDT_UTL_SwtichInProcess - getActivatedDate: ' + ActivatedDate_tmp);
    //     return ActivatedDate_tmp; 
    // }


    public static Date getEffectiveDate(Order order) {
        
        Date effectiveDateTmp = null;
        Date dateDecorrenzaTmp = null;
        String processType = PROCESSTYPEBYRRECORDTYPEMAP.get(order.RecordType.DeveloperName);

        // Inizio Questa parte è da definire con Ravicini per il campo isReseller
        // Verificare con luca
        // if(order.isReseller == true && processType == 'Switch In'){
        //     processType = processTypeMap.get('isReseller');
        // }
        // Fine Questa parte è da definire con Ravicini per il campo isReseller

        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate - OriginMarket__c: ' + order.MarketOrigin__c );
        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate - Commodity__c: ' + order.ServicePoint__r.CommoditySector__c  );
        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate - VoltageLevel__c: ' + order.VoltageLevel__c);
        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate - SupplyType__c: ' + order.SupplyType__c );
        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate - DateSentToSII: ' + getDateSentToSii(order));

        if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
            
            List<HDT_FulfillmentDateMatrix__c> afterthoughtDays = [
                                                                    SELECT ActivationDate__c 
                                                                    FROM HDT_FulfillmentDateMatrix__c 
                                                                    WHERE OriginMarket__c =: order.MarketOrigin__c   
                                                                            AND Commodity__c =: order.ServicePoint__r.CommoditySector__c   
                                                                            AND VoltageLevel__c =: order.VoltageLevel__c 
                                                                            AND ProcessType__c = :processType
                                                                            AND SupplyType__c =: order.SupplyType__c 
                                                                            AND (FulfillmentDateFrom__c <=: getDateSentToSii(order) AND FulfillmentDateTo__c >=: getDateSentToSii(order))
                                                                            WITH SECURITY_ENFORCED
                ];
            effectiveDateTmp = afterthoughtDays[0].ActivationDate__c;
        }
        else{
            if(order.RecessNotice__c != null){
                List<HDT_FulfillmentDateMatrix__c> afterthoughtDays2 = [
                SELECT ActivationDate__c 
                FROM HDT_FulfillmentDateMatrix__c 
                WHERE OriginMarket__c =: order.MarketOrigin__c 
                        AND Commodity__c =: order.ServicePoint__r.CommoditySector__c   
                        AND VoltageLevel__c =: order.VoltageLevel__c 
                        AND ProcessType__c = :processType 
                        AND SupplyType__c =: order.SupplyType__c 
                        AND (FulfillmentDateFrom__c <= :getDateSentToSii(order) AND FulfillmentDateTo__c >= :getDateSentToSii(order))
                        WITH SECURITY_ENFORCED
                ];

                effectiveDateTmp = afterthoughtDays2[0].ActivationDate__c;
            }else{
                dateDecorrenzaTmp = getDateSentToSii(order).addMonths((Integer)order.RecessNotice__c);
                effectiveDateTmp = dateDecorrenzaTmp.addMonths(1).toStartofMonth();
            }
        }    

        

        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate: ' + effectiveDateTmp);
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