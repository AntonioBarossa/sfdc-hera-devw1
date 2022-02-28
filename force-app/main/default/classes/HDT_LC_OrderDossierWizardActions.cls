/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 16/02/2021
 * @description HDT_LC_OrderDossierWizardActions.cls - Class that holds methods that are called from hdtOrderDossierWizardActions.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_OrderDossierWizardActions {
    
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    public static HDT_WRP_CreateActivityVocalOrder wrpActivityVo = new HDT_WRP_CreateActivityVocalOrder();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/02/2021
    * @description Handle "stampa" action
    * @param Order orderParent
    */
    @AuraEnabled
    public static void save(Order orderParent){ 

        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        Map<Id, Order> mapChildOrders = new Map<Id, Order>(childOrders);
        List<Order> ordersToUpdate = new List<Order>();
        
        Order orderToUpdate = new Order(
            Id = orderParent.Id
        );

          //fix CC Generazione Credential LG MB
         // orderToUpdate = HDT_LC_CanaleContattoIVRLogin.generateUsernameAndPassword(orderToUpdate);
        // if (orderParent.ContractSigned__c == false) {
                // LG Ripristino logica 18/09 FF
        if (orderParent.ContractSigned__c == false) {
            orderToUpdate.Phase__c = 'Documentazione da inviare';
        } else {
            orderToUpdate.Phase__c = 'Documentazione da validare';
             //   orderToUpdate.Phase__c = 'Plico da inviare'; 
        }
           // orderToUpdate.Phase__c = 'Documentazione da inviare';
        // } else {
         //   orderToUpdate.Phase__c = 'Plico da inviare'; 
        // }

        orderToUpdate.DocumentPackage__c = 'Richiesto';
        Map<id, Order> quoteIdsMap = new Map<id, Order>();
        Set<Id> quoteIdsDuplicates = new Set<Id>();//if quote is in this set and sp!=null, blank quote

        for (Order childOrd : childOrders) {
            if (childOrd.RecordType.DeveloperName == 'HDT_RT_VolturaConSwitch') {
                Order o = new Order(
                    Id = childOrd.Id,
                    Phase__c = childOrd.Account.RecordType.DeveloperName == 'HDT_RT_Business' ? 'Comunicazione verso Heroku' : (checkRequiredDocs(childOrd) ? 'Comunicazione verso Heroku': 'In attesa validazione')
                );
                if(quoteIdsMap.containsKey(childOrd.SBQQ__Quote__c)){
                    o.isMultipleQuoteOffer__c=true;
                    quoteIdsDuplicates.add(childOrd.SBQQ__Quote__c);
                }else{
                    quoteIdsMap.put(childOrd.SBQQ__Quote__c, childOrd);
                }
                ordersToUpdate.add( o );
            } else if(childOrd.RecordType.DeveloperName == 'HDT_RT_VAS' && mapChildOrders.get(childOrd?.OrderReference__c) != null ){
                Order o = new Order(
                    Id = childOrd.Id,
                    CreditCheckDescription__c=mapChildOrders.get(childOrd?.OrderReference__c)?.CreditCheckDescription__c,
                    IncomingCreditCheckResult__c=mapChildOrders.get(childOrd?.OrderReference__c)?.IncomingCreditCheckResult__c,
                    OutgoingCreditCheckResult__c=mapChildOrders.get(childOrd?.OrderReference__c)?.OutgoingCreditCheckResult__c                        
                );
                ordersToUpdate.add(o);//get CCheck Result from offer
            }else if(childOrd.RecordType.DeveloperName != 'HDT_RT_ScontiBonus'){
                if(quoteIdsMap.containsKey(childOrd.SBQQ__Quote__c)){
                    ordersToUpdate.add(new Order( Id = childOrd.Id, isMultipleQuoteOffer__c=true));
                    quoteIdsDuplicates.add(childOrd.SBQQ__Quote__c);
                }else{
                    quoteIdsMap.put(childOrd.SBQQ__Quote__c, childOrd);
                }
            }
        }
        
        ordersToUpdate.add(orderToUpdate);
        map<id, Order> ordersToUpdateMap = new map<id, Order>(ordersToUpdate);

        for(id quoteDuplicate : quoteIdsDuplicates){
            id ordId = quoteIdsMap.get(quoteDuplicate).Id;
            Order o = ordersToUpdateMap.get(ordId);
            if(o==null){
                o=new Order(id=ordId);
                ordersToUpdate.add(o);
            }
            o.isMultipleQuoteOffer__c=true;
        }


        //update child orders
        for (Order childOrder : childOrders) {
            if (childOrder.ComfortCallDaysDue__c != null) {//pay attention of duplicate order in list
                ordersToUpdate.add(new Order(
                    Id = childOrder.Id,
                    Phase__c = 'In attesa conferma cliente'
                ));
            }
        }

        orderSrv.updateRecords(ordersToUpdate);

    }

    @AuraEnabled
    public static HDT_WRP_CreateActivityVocalOrder createActivityVocalOrder(Order orderParent){

        //Aggiornamento CampaignMember
        Boolean isCommunity = HDT_LC_SellingWizardController.checkCommunityLogin();
        if(isCommunity){
            Order ord = [SELECT Id, Sale__r.Campaign__c, Sale__r.SalesContact__c FROM Order WHERE Id =: orderParent.Id WITH SECURITY_ENFORCED LIMIT 1];
            CampaignMember cm = [SELECT Id, Campaign.PositiveOutcomeDefaultStatus__c 
                                 FROM CampaignMember 
                                 WHERE CampaignId =: ord.Sale__r.Campaign__c 
                                 AND ContactId =: ord.Sale__r.SalesContact__c WITH SECURITY_ENFORCED LIMIT 1];
            String myStatus = cm.Campaign.PositiveOutcomeDefaultStatus__c;
            HDT_LC_CampaignsController.updateCampaignMemberStatus(cm.Id, myStatus);
            wrpActivityVo.campaignMemberStatus = myStatus;
        }

        List<Order> ordersToUpdate = new List<Order>();
        
        Order orderToUpdate = new Order(
            Id = orderParent.Id
        );
        system.debug('********DEBUGLOL:' + orderParent);
        if(orderParent.SignatureMethod__c == 'Vocal Order' && orderParent.Phase__c == 'In Lavorazione'){
            if (orderParent.ContractSigned__c == false) {
                orderToUpdate.Phase__c = 'Documentazione da inviare';
            } else {
                orderToUpdate.Phase__c = 'Documentazione da validare';
                 //   orderToUpdate.Phase__c = 'Plico da inviare'; 
            }
            ordersToUpdate.add(orderToUpdate );
            orderSrv.updateRecords(ordersToUpdate);
        }
        wrpActivityVo.orderPhase = orderToUpdate.Phase__c;
        
        return wrpActivityVo;
    }

    @AuraEnabled
    public static void save2(Order orderParent,boolean isPlicoSend){ 

        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        List<Order> ordersToUpdate = new List<Order>();
        
        Order orderToUpdate = new Order(
            Id = orderParent.Id
        );

          //fix CC Generazione Credential LG MB
        //  orderToUpdate = HDT_LC_CanaleContattoIVRLogin.generateUsernameAndPassword(orderToUpdate);
        // if (orderParent.ContractSigned__c == false) {
        //     orderToUpdate.Phase__c = 'Documentazione da inviare';
        // } else {
                // LG Ripristino logica 18/09 FF
        System.debug('********LOL:' + orderParent);
        if(orderParent.Phase__c == 'In Lavorazione'){
            if (orderParent.ContractSigned__c == false) {
                orderToUpdate.Phase__c = 'Documentazione da inviare';
            } else{
                orderToUpdate.Phase__c = 'Documentazione da validare';
                //   orderToUpdate.Phase__c = 'Plico da inviare'; 
            }
        }
        else if(orderParent.Phase__c == 'Registrazione validata'){
            orderToUpdate.Phase__c = 'Documentazione Gestita';
            orderToUpdate.status = 'Completed';
        }
        /**@frpanico 13/01/2022
         * Gestione casistica SignMode "Contratto gia Firmato"
        */
        if(orderParent.SignMode__c != null && orderParent.SignMode__c.equalsIgnoreCase('Contratto già firmato'))
        {
            orderToUpdate.Phase__c = 'Documentazione Gestita';
            orderToUpdate.status = 'Completed';
        }

        //il campo SignMode è stato utilizzato per salvare il SignatureMethod dell'ultimo invio
        orderToUpdate.SignMode__c = orderParent.SignMode__c;
      /*  if(isPlicoSend){
          //  orderToUpdate.Phase__c = 'Plico da inviare';
          orderToUpdate.Phase__c = 'Documentazione da validare';
        }
        else{
            orderToUpdate.Phase__c = 'Documentazione da validare';
        }*/
        // }

        orderToUpdate.DocumentPackage__c = 'Richiesto';

        for (Order childOrd : childOrders) {
            if (childOrd.RecordType.DeveloperName == 'HDT_RT_VolturaConSwitch') {
                ordersToUpdate.add(
                    new Order(
                        Id = childOrd.Id,
                        Phase__c = childOrd.Account.RecordType.DeveloperName == 'HDT_RT_Business' ? 'Comunicazione verso Heroku' : (checkRequiredDocs(childOrd) ? 'Comunicazione verso Heroku': 'In attesa validazione')
                    )
                );
            }
        }

        //update CampaignMember Status From Stampa
        /**@fvitiell 21/02/2022
         * Implementato e commentato, utile laddove dovesse servire
         * aggiornare alla pressione del tasto Stampa del Wizard
         */
        /*List<String> myCampaignListIds = new List<String>();
        for (Order myChildOrder : childOrders){
            Campaign myCampaign = new Campaign(
                Id = myChildOrder.Campaign__c
            );
            myCampaignListIds.add(myChildOrder.Campaign__c);
        }
        List<CampaignMember> myCampaignMemberList = [Select id, Campaign.PositiveOutcomeDefaultStatus__c from CampaignMember where CampaignId IN :myCampaignListIds WITH SECURITY_ENFORCED];
        for(myCampaignMember : myCampaignMemberList){
            String status = myCampaignMember.Campaign.PositiveOutcomeDefaultStatus__c;
            String CampaignMemberId = myCampaignMember.Id;
            HDT_LC_CampaignsController.updateCampaignMemberStatusFromStampa(CampaignMemberId, status);
        }*/
    
        ordersToUpdate.add(orderToUpdate);

        //update child orders
        /**@frpanico 04/02/2022
         * Commentato in quanto la conferma cliente va successivamente
         * Alla validazione documenti
         */
        /*
        for (Order childOrder : childOrders) {
            if (childOrder.ComfortCallDaysDue__c != null) {
                ordersToUpdate.add(new Order(
                    Id = childOrder.Id,
                    Phase__c = 'In attesa conferma cliente'
                ));
            }
        }
        */



        orderSrv.updateRecords(ordersToUpdate);

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 17/02/2021
    * @description Handle "Annulla" action
    * @param Order orderParent
    * @param String cancellationReason
    */
    @AuraEnabled
    public static void cancel(Order orderParent, String cancellationReason){
        
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        List<Order> ordersToUpdate = new List<Order>();

        //update child orders
        for (Order childOrder : childOrders) {
            ordersToUpdate.add(new Order(
                Id = childOrder.Id,
                Status = 'Annullato', //Chiuso
                Phase__c = 'Annullato',
                CancellationReason__c = cancellationReason
            ));
        }

        //update parent order
        ordersToUpdate.add(new Order(
            Id = orderParent.Id,
            Status = 'Annullato', //Chiuso
            Phase__c = 'Annullato',
            CancellationReason__c = cancellationReason
        ));

        orderSrv.updateRecords(ordersToUpdate);
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/02/2021
    * @description Check order required documents
    * @param Order ord
    * @return Boolean
    */
    public static Boolean checkRequiredDocs(Order ord){

        Boolean check = true;

        if(ord.AutorizationVolturaThirdTrader__c != null || ord.CILegalRepresentative__c != null ||  ord.CIAccoutn__c != null || ord.QuickQuote__c != null || ord.ChamberCommerceRegistration__c != null || ord.Instance326__c != null || ord.DocumentLow80__c != null || ord.DocumentPackage__c != null)
        {
           	check = true;
            if(ord.CILegalRepresentative__c != null && !'Validato'.EqualsIgnoreCase(ord.CILegalRepresentative__c)){
                check = false;
            }
            if(ord.CIAccoutn__c != null && !'Validato'.EqualsIgnoreCase(ord.CIAccoutn__c)){
                check = false;
            }
            if(ord.QuickQuote__c != null && !'Validato'.EqualsIgnoreCase(ord.QuickQuote__c)){
                check = false;
            }
            if(ord.ChamberCommerceRegistration__c != null && !'Validato'.EqualsIgnoreCase(ord.ChamberCommerceRegistration__c)){
                check = false;
            }
            if(ord.Instance326__c != null && !'Validato'.EqualsIgnoreCase(ord.Instance326__c)){
                check = false;
            }
            if(ord.DocumentLow80__c != null && !'Validato'.EqualsIgnoreCase(ord.DocumentLow80__c)){
                check = false;
            }
            if(ord.AutorizationVolturaThirdTrader__c != null && !'Validato'.EqualsIgnoreCase(ord.AutorizationVolturaThirdTrader__c)){
                check = false;
            }
            if(ord.DocumentPackage__c != null && !'Validato'.EqualsIgnoreCase(ord.DocumentPackage__c)){
                check = false;
            }
        } else if(ord.AutorizationVolturaThirdTrader__c == null && ord.CILegalRepresentative__c == null &&  ord.CIAccoutn__c == null && ord.QuickQuote__c == null && ord.ChamberCommerceRegistration__c == null && ord.Instance326__c == null && ord.DocumentLow80__c == null && ord.DocumentPackage__c == null) {
            check = true;
        }

        return check;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 16/02/2021
    * @description Check if save button should be disabled or not
    * @param String orderParentId
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean isSaveDisabled(Order orderParent){
        Boolean result = false;
        
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        
        for (Order childOrder : childOrders) {
            if (childOrder.Step__c != 20) {
                result = true;
                break;
            }
        }

        return result || orderParent.Status == 'Completed';
    }
    /*@frpanico 08/02/2022
    * Aggiunta gestione Annullamento
    * Per poter annullare gli order non devono essere in default
     */
    @AuraEnabled
    public static Boolean isCancelDisabled(Order parentOrder){
        Boolean result = false;
        List<Order> childOrders = orderQr.getChildOrdersByParentId(parentOrder.Id);
        for(Order childOrder : childOrders)
        {
            if(childOrder.RecordType.DeveloperName.equalsIgnoreCase('HDT_RT_Default'))
            {
                result = true;
                break;
            }
        }
        return result;
    }

    
    @AuraEnabled(cacheable=true)
    public static List<String> getActivePicklistValue(String objectApiName,String fieldApiName){
        List<String> activeValue = new List<String>();
        try{
            Schema.SobjectField objField = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName);
            List<Schema.PicklistEntry> pickListEntries = objField.getDescribe().getPickListValues();
            for (Schema.PicklistEntry entry : pickListEntries) {
                if (entry.isActive()) {
                    activeValue.add(entry.getValue());
                }
            }
        }catch(Exception e){

        }
        return activeValue;
    }

    public class HDT_WRP_CreateActivityVocalOrder{
        public String orderPhase {get; set;}
        public String campaignMemberStatus {get; set;}
    }

}