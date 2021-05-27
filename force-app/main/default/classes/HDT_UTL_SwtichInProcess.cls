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

        Date SignedDate = order.SignedDate__c;   
        Date MaxAfterthoughtDate = null;  
        List<HDT_AfterthoughtDays__mdt> AfterthoughtDays3 = [ // Giorni di ripensamento
                                                                SELECT AfterthoughtDays__c 
                                                                FROM HDT_AfterthoughtDays__mdt 
                                                                WHERE Channel__c =: order.Channel__c 
                                                                        AND Market__c =: order.Market__c
                                                                        AND AccountType__c =: order.CustomerCategory__c  
                                                                        AND SignatureMode__c =: order.SignatureMethod__c 
                                                                        AND DocumentSendingMode__c =: order.DocSendingMethod__c 
                                                            ];            
        if(SignedDate != null){
            system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate - AfterthoughtDays__c: ' + (Integer)AfterthoughtDays3[0].AfterthoughtDays__c );
            MaxAfterthoughtDate = SignedDate.addDays((Integer)AfterthoughtDays3[0].AfterthoughtDays__c);                      
        }   

    
        system.debug('HDT_UTL_SwtichInProcess - getMaxAfterthoughtDate: ' + MaxAfterthoughtDate);
        return MaxAfterthoughtDate;

    }


    public static Date getDateSentToSII(Order order) {

        Date SignedDate = order.SignedDate__c;   
        Date DateSentToSII = null;

        if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){

        

            if(SignedDate != null){ 
                if(order.WizardCompletedDate__c > getMaxAfterthoughtDate(order)){
                    DateSentToSII = order.WizardCompletedDate__c;
                }else{
                    DateSentToSII = getMaxAfterthoughtDate(order).addDays(1);
                }
            }else{ 
                DateSentToSII = order.WizardCompletedDate__c;            
            }

            if(DateSentToSII.day() < 10){
                DateSentToSII = DateSentToSII.addMonths(1).toStartofMonth();  
            }else{
                DateSentToSII = DateSentToSII.addMonths(2).toStartofMonth();  
            }
            
            // if (order.WaiverRightAfterthought__c == 'Si') { 
            //     DateSentToSII = order.WizardCompletedDate__c;
            // }
        
        }else{
            DateSentToSII = order.WizardCompletedDate__c;    
            /*
            La data invio richiesta al SII deve essere ricalcolata nel caso in cui il sistema riceva degli esiti di rilavorazione.  
            Alla rilavorazione, la data di invio richiesta deve assumere la data di rilavorazione della richiesta (la data di ultimo aggiornamento fase).  
            Tale ricalcolo potrà essere possibile fino all’esito di ammissibilità ok.  
            Da quel momento in poi il sistema non dovrà più ricalcolare la data invio richiesta al SII. 
            */          
        }

        system.debug('HDT_UTL_SwtichInProcess - getDateSentToSII: ' + DateSentToSII);
        return DateSentToSII;

    }

    // public static Date getActivatedDate(Order order) {
        
    //     Date DateSentToSII_tmp = getDateSentToSII(order);
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
        
        Date EffectiveDate_tmp = null;
        Date DateDecorrenzaTmp = null;
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
        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate - DateSentToSII: ' + getDateSentToSII(order));

        if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
            
            List<HDT_FulfillmentDateMatrix__c> AfterthoughtDays = [
                                                                    SELECT ActivationDate__c 
                                                                    FROM HDT_FulfillmentDateMatrix__c 
                                                                    WHERE OriginMarket__c =: order.MarketOrigin__c   
                                                                            AND Commodity__c =: order.ServicePoint__r.CommoditySector__c   
                                                                            AND VoltageLevel__c =: order.VoltageLevel__c 
                                                                            AND ProcessType__c = :processType
                                                                            AND SupplyType__c =: order.SupplyType__c 
                                                                            AND (FulfillmentDateFrom__c <=: getDateSentToSII(order) AND FulfillmentDateTo__c >=: getDateSentToSII(order))
                ];
            EffectiveDate_tmp = AfterthoughtDays[0].ActivationDate__c;
        }
        else{
            if(order.RecessNotice__c != null){
                List<HDT_FulfillmentDateMatrix__c> AfterthoughtDays2 = [
                SELECT ActivationDate__c 
                FROM HDT_FulfillmentDateMatrix__c 
                WHERE OriginMarket__c =: order.MarketOrigin__c 
                        AND Commodity__c =: order.ServicePoint__r.CommoditySector__c   
                        AND VoltageLevel__c =: order.VoltageLevel__c 
                        AND ProcessType__c = :processType 
                        AND SupplyType__c =: order.SupplyType__c 
                        AND (FulfillmentDateFrom__c <= :getDateSentToSII(order) AND FulfillmentDateTo__c >= :getDateSentToSII(order))
                ];

                EffectiveDate_tmp = AfterthoughtDays2[0].ActivationDate__c;
            }else{
                DateDecorrenzaTmp = getDateSentToSII(order).addMonths((Integer)order.RecessNotice__c);
                EffectiveDate_tmp = DateDecorrenzaTmp.addMonths(1).toStartofMonth();
            }
        }    

        

        system.debug('HDT_UTL_SwtichInProcess - getEffectiveDate: ' + EffectiveDate_tmp);
        return EffectiveDate_tmp;
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