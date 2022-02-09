/**
 * @author alessandro.picchiri@eng.it
 * @date 24/05/2021
 * @description  Classe per la gestione delle date nel processo switch in  
*/
public with sharing class HDT_UTL_SwtichInProcess {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_QR_Account accountQr = new HDT_QR_Account();

    public static Map<String,Boolean> checkAccountOrderIsResidential(List<Order> listOrder){
        List<String> accountIdList = new List<String>();
        Map<String,Boolean> mapRes = new Map<String,boolean>();
        for(Order ord : listOrder){
            accountIdList.add(ord.AccountId);
        }
        List<Account> listAccount = accountQr.getRecordsById(accountIdList,'Id,Recordtype.Developername');
        for(Account a : ListAccount){
            if(mapRes.get(a.id) == null){
                mapRes.put(a.id,a.recordtype.developername == 'HDT_RT_Residenziale');
            }
        }
        return mapRes;
    }
    // Calcolo Data Max Ripensamento(MaxAfterthoughtDate__c)  // Solo per clienti residenziali
    public static Date getMaxAfterthoughtDate(Order order) {

        Date signedDate = order.SignedDate__c;   
        Date maxAfterthoughtDate = null;
        order = orderQr.getRecordById(order.id);
        
        // Giorni di ripensamento
        List<HDT_AfterthoughtDays__mdt> afterthoughtDays3 = [SELECT AfterthoughtDays__c FROM HDT_AfterthoughtDays__mdt WHERE 
            Channel__c =: order.Channel__c AND 
            Market__c =: order.Market__c AND 
            AccountType__c =: order.CustomerCategory__c AND 
            SignatureMode__c =: order.SignatureMethod__c AND 
            DocumentSendingMode__c =: order.DocSendingMethod__c
        WITH SECURITY_ENFORCED];

        if(afterthoughtDays3.isEmpty()){
            maxAfterthoughtDate = signedDate;                      
        }
        else{
            //if(order.ProcessType__c == 'Cambio offerta'){
                // manca la logica dell'esecuzione anticipata 
            //    maxAfterthoughtDate = signedDate;     
            //}
            //else{
                maxAfterthoughtDate = signedDate.addDays((Integer)afterthoughtDays3[0].AfterthoughtDays__c);                      
            //}            
        }        
        return maxAfterthoughtDate;
    }

    public static void calculateSwitchDate(Order order){
        Date dataRipensamento = getMaxAfterthoughtDate(order);
        order.MaxAfterthoughtDate__c = dataRipensamento;
        Date dataInvioSii = getDateSentToSii(order);
        order.DateSentToSII__c = dataInvioSii;
        Date dataDecorrenza = getEffectiveDate(order);
        order.EffectiveDate__c = dataDecorrenza;
    }

    public static void calculateCambioOffertaDate(Order order){
        Date dataRipensamento = getMaxAfterthoughtDate(order);
        order.MaxAfterthoughtDate__c = dataRipensamento;
        Date dataDecorrenza = getEffectiveDate(order);
        order.EffectiveDate__c = dataDecorrenza;
    }

    // Data di invio richiesta al SII
    public static Date getDateSentToSii(Order order) {

        //13/08/2021 - gabriele.rota@webresults.it - Aggiornamento calcolo Data Invio al SII
        Date effDate = order.EffectiveDate__c; 

        order = orderQr.getRecordById(order.id);
        Date signedDate = order.SignedDate__c;   
        
        //13/08/2021 - gabriele.rota@webresults.it - Aggiornamento calcolo Data Invio al SII
        if (order.EffectiveDate__c!=null) {
            effDate = order.EffectiveDate__c;
        }

        //18/09/2021 - gabriele.rota@webresults.it - Fix Data Completamento Wizard vuota
        if (order.WizardCompletedDate__c==null) {
            order.WizardCompletedDate__c = Date.today();
        }

        Date dateSentToSii= null;
        if(signedDate != null  && order.ProcessType__c != 'Cambio Offerta'){
            if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
                // DIRITTO DI RINUNCIA DI RIPENSAMENTO
                if (order.WaiverRightAfterthought__c == 'Si') { 
                    dateSentToSii = date.today();
                }
                else if(order.IsEarlyActivation__c) {
                    //DV: aggiungo controllo su campo "Attivazione Anticipata". Se messo a true, Data invio richiesta è valorizzata con la data di completamento wizard
                    dateSentToSii = order.WizardCompletedDate__c;
                }
                else{
                    //if(order.WizardCompletedDate__c > getMaxAfterthoughtDate(order)){
                        //DV: valorizzo con la data completamento wizard a cui applico la logica del prima o dopo il 10 del mese.
                    //    dateSentToSii = order.WizardCompletedDate__c.day() < 11 ? order.WizardCompletedDate__c.addMonths(1).toStartofMonth() : order.WizardCompletedDate__c.addMonths(2).toStartofMonth();
                    //}
                    //else{
                        Date dataRipensamento = order.MaxAfterthoughtDate__c;
                        if(dataRipensamento != null){
                            dateSentToSii = dataRipensamento.addDays(1);
                        }else{
                            dateSentToSii= getMaxAfterthoughtDate(order).addDays(1);
                        }
                    //}
                }            
            }
            else{
                dateSentToSii = order.WizardCompletedDate__c;
            }
        }
        return dateSentToSII;
    } 

    // Data di decorrenza
    public static Date getEffectiveDate(Order order) {

        //17/08/2021 - gabriele.rota@webresults.it - Aggiornamento calcolo Data Decorrenza
        if (order.IsActivationDeferred__c==true) {
            return order.EffectiveDate__c;
        }

        Date effectiveDateTmp = null;
        Date dateDecorrenzaTmp = null;
        Date dateToFrom = null;
        order = orderQr.getRecordById(order.id);
        String processType = PROCESSTYPEBYRRECORDTYPEMAP.get(order.RecordType.DeveloperName);

        //// AGGIUNGERE CONTROLLO SU DOMESTICO SOLO NON DOMESTICO
        if(order.ProcessType__c == 'Cambio offerta'){
            // Per cambio offerta entrare in tabella con la data firma o la data massima di ripensamento se no esecuzione anticipata
            dateToFrom = order.SignedDate__c;
            List<FulfillmentDateMatrix__c> afterthoughtDays = [SELECT ActivationDate__c FROM FulfillmentDateMatrix__c WHERE
                    OriginMarket__c =: order.MarketOrigin__c AND 
                    Commodity__c =: order.ServicePoint__r.CommoditySector__c AND 
                    VoltageLevel__c =: order.VoltageLevel__c AND 
                    ProcessType__c = :processType AND 
                    SupplyType__c =: order.SupplyType__c AND 
                    FulfillmentDateFrom__c <=: dateToFrom AND 
                    FulfillmentDateTo__c >=: dateToFrom 
                WITH SECURITY_ENFORCED];

                if(!afterthoughtDays.isEmpty()){
                    effectiveDateTmp = afterthoughtDays[0].ActivationDate__c;
                }else {
                    effectiveDateTmp = order.SignedDate__c;
                }
        }
        else{
            //DV: Aggiungo controllo sul RT "HDT_RT_SwitchIn", in quanto per lo SwitchIn devo andarmi a prendere la Data Decorrenza (ovvero la Data invio richiesta al SII).
            if(order.IsSequanzialized__c == true || order.RecordType.DeveloperName.EqualsIgnoreCase('HDT_RT_SwitchIn')){
                dateToFrom = getDateSentToSii(order);
            }
            else{
                dateToFrom = getMaxAfterthoughtDate(order); // data max di ripensamento
            }
            // CALCOLATO DATA SU SEQUEN O NO
            if(order.Account.RecordType.DeveloperName == 'HDT_RT_Residenziale'){
               List<FulfillmentDateMatrix__c> afterthoughtDays = [SELECT ActivationDate__c FROM FulfillmentDateMatrix__c WHERE
                    OriginMarket__c =: order.MarketOrigin__c AND 
                    Commodity__c =: order.ServicePoint__r.CommoditySector__c AND 
                    VoltageLevel__c =: order.VoltageLevel__c AND 
                    ProcessType__c = :processType AND 
                    SupplyType__c =: order.SupplyType__c AND 
                    FulfillmentDateFrom__c <=: dateToFrom AND 
                    FulfillmentDateTo__c >=: dateToFrom 
                WITH SECURITY_ENFORCED];

                if(!afterthoughtDays.isEmpty()){
                    effectiveDateTmp = afterthoughtDays[0].ActivationDate__c;
                }
            }
            else{
                if(order.RecessNotice__c == null){

                    List<FulfillmentDateMatrix__c> afterthoughtDays2 = [SELECT ActivationDate__c FROM FulfillmentDateMatrix__c WHERE 
                        OriginMarket__c =: order.MarketOrigin__c AND 
                        Commodity__c =: order.ServicePoint__r.CommoditySector__c AND
                        VoltageLevel__c =: order.VoltageLevel__c AND
                        ProcessType__c = :processType AND
                        SupplyType__c =: order.SupplyType__c AND
                        FulfillmentDateFrom__c <= :dateToFrom AND
                        FulfillmentDateTo__c >= :dateToFrom
                    WITH SECURITY_ENFORCED];

                    effectiveDateTmp = afterthoughtDays2[0].ActivationDate__c;
                }
                else{
                    dateDecorrenzaTmp = dateToFrom.addMonths((Integer)order.RecessNotice__c);
                    effectiveDateTmp = dateDecorrenzaTmp.addMonths(1).toStartofMonth();
                }
            } 
        }
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