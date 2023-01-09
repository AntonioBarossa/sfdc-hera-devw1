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

    /* Il Metodo Save viene chiamato nelle casistiche in cui non si esegue la Stampa Documentale */
    @AuraEnabled
    public static void save(Order orderParent){

        updateCommodityWithConsumptionAnalisi(orderParent.Id);
        Order orderParentRetreived = [SELECT Id, Phase__c, ContractSigned__c, SignMode__c, SignatureMethod__c,WasteCommodityType__c,RequestSource__c,DeliveredDocumentation__c FROM Order WHERE Id = :orderParent.Id WITH SECURITY_ENFORCED];
        String wasteCommodityType = orderParentRetreived.WasteCommodityType__c;
        String recordId = orderParent.Id;
        System.debug(orderParent);
        /**@frpanico 2022-04-29
         * Aggiunta gestione del contratto gia firmato
         */


        if('Ambiente'.equalsIgnoreCase(wasteCommodityType))
        {
            handleTariOrder(orderParentRetreived);
            return;
        } else if( 'Contratto già firmato'.equalsIgnoreCase(orderParentRetreived.SignatureMethod__c))
        {
            Order parentOrderToUpdate = new Order();
            /**@frpanico 2022-12-02 tk 929838C Date su SW Fittizio */
            List<Order> childs = [SELECT Id, SignedDate__c FROM Order WHERE ParentOrder__c = :orderParent.Id AND ProcessType__c = 'Switch in Fittizio' WITH SECURITY_ENFORCED];
            if(!childs.isEmpty())
            {
                parentOrderToUpdate.SignedDate__c = childs[0].SignedDate__c;
            }
            parentOrderToUpdate.Id = orderParent.Id;
            parentOrderToUpdate.Phase__c = 'Documentazione Gestita';
            parentOrderToUpdate.Status = 'Completed';
            HDT_UTL_DatabaseService.updateSObject(parentOrderToUpdate);
            return;
        }


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
    public static String createActivityVocalOrder(Order orderParent){

        //Aggiornamento/Esitazione CampaignMember
         Boolean isCommunity = HDT_LC_SellingWizardController.checkCommunityLogin();
         
        Order ord = [SELECT Id, Sale__r.Campaign__c, Sale__r.SalesContact__c, Sale__r.CampaignMemberId__c FROM Order WHERE Id =: orderParent.Id WITH SECURITY_ENFORCED LIMIT 1];
        Boolean campaignPresent = ord.Sale__r.Campaign__c != null;
        wrpActivityVo.isCommunity = isCommunity == true && campaignPresent == true;

        if(ord.Sale__r.CampaignMemberId__c != null){
            // CampaignMember cm = [SELECT Id, Campaign.PositiveOutcomeDefaultStatus__c 
            //                         FROM CampaignMember 
            //                         WHERE CampaignId =: ord.Sale__r.Campaign__c 
            //                         AND ContactId =: ord.Sale__r.SalesContact__c WITH SECURITY_ENFORCED LIMIT 1];
            CampaignMember cm = [SELECT Id, Campaign.PositiveOutcomeDefaultStatus__c 
            FROM CampaignMember 
            WHERE Id =: ord.Sale__r.CampaignMemberId__c WITH SECURITY_ENFORCED LIMIT 1];
            
            System.debug('ord.Sale__r.CampaignMemberId__c --> '+ord.Sale__r.CampaignMemberId__c);
            System.debug('cm --> '+cm.Id);
            String myStatus = cm.Campaign.PositiveOutcomeDefaultStatus__c;
            System.debug('PositiveOutcomeDefaultStatus__c --> '+myStatus);
            CampaignMember campaignMember = HDT_LC_CampaignsController.updateCampaignMemberStatus(cm.Id, myStatus);
            System.debug('campaignMember Status -->'+campaignMember.Status);
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
        
        return JSON.serialize(wrpActivityVo);
    }

    /* Viene chiamato quando si esegue la stampa documentale */
    @AuraEnabled
    public static void save2(Order orderParent,boolean isPlicoSend){ 

        updateCommodityWithConsumptionAnalisi(orderParent.Id);

        orderParent = [SELECT Id, Sale__r.Channel__c,  Phase__c, ContractSigned__c, SignMode__c, SignatureMethod__c FROM Order WHERE Id = :orderParent.Id WITH SECURITY_ENFORCED];

        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        List<Order> ordersToUpdate = new List<Order>();
        Boolean isOnlyAmend = false;
        for (Order childOrder : childOrders) {
            if (childOrder.ProcessType__c != null && !childOrder.ProcessType__c.containsIgnoreCase('Aggiunta Sconti o Bonus VAS')) {
                isOnlyAmend = false;
                break;
            }else {
                isOnlyAmend = true;
            }
        }
        Order orderToUpdate = new Order(
            Id = orderParent.Id
        );
        if(isOnlyAmend){
            orderToUpdate.Phase__c = 'Documentazione Gestita';
            orderToUpdate.Status = 'Completed';
        }else if(orderParent.Phase__c == 'In Lavorazione' || orderParent.Phase__c.equalsIgnoreCase('Comunicazione EngageOne KO')){
            if (orderParent.ContractSigned__c == false) {
                orderToUpdate.Phase__c = 'Documentazione da inviare';
            } else{
                orderToUpdate.Phase__c = 'Documentazione da validare';
                //   orderToUpdate.Phase__c = 'Plico da inviare'; 
            }
        }
        else if(orderParent.Phase__c == 'Registrazione validata'){
            if((orderParent.Sale__r.Channel__c == 'Telefono' || orderParent.Sale__r.Channel__c == 'Teleselling Inbound') && orderParent.SignatureMethod__c == 'Vocal Order')
            {
                orderToUpdate.SignedDate__c = Date.today();
                orderToUpdate.DocumentalPhase__c = 'Plico firmato';
            }
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
        /**@frpanico 2022-07-15
        * Gestione Accettato Digitalmente
        */
        if(orderParent.SignatureMethod__c != null && orderParent.SignatureMethod__c.equalsIgnoreCase('Accettato Digitalmente'))
        {
            orderToUpdate.Phase__c = 'Documentazione Gestita';
            orderToUpdate.Status = 'Completed';
            orderToUpdate.SignedDate__c = date.today();
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

        /*for (Order childOrd : childOrders) {
            if (childOrd.RecordType.DeveloperName == 'HDT_RT_VolturaConSwitch') {
                ordersToUpdate.add(
                    new Order(
                        Id = childOrd.Id,
                        Phase__c = childOrd.Account.RecordType.DeveloperName == 'HDT_RT_Business' ? 'Comunicazione verso Heroku' : (checkRequiredDocs(childOrd) ? 'Comunicazione verso Heroku': 'In attesa validazione')
                    )
                );
            }
        }*/

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
        if(String.isNotBlank(ord.CommodityFormula__c) && ord.CommodityFormula__c.equalsIgnoreCase('Ambiente') && String.isNotBlank(ord.ProcessType__c) && !ord.ProcessType__c.containsIgnoreCase('Modifica Tariffa')){
            check = false;
        }else if(ord.AutorizationVolturaThirdTrader__c != null || ord.CILegalRepresentative__c != null ||  ord.CIAccoutn__c != null || ord.QuickQuote__c != null || ord.ChamberCommerceRegistration__c != null || ord.Instance326__c != null || ord.DocumentLow80__c != null || ord.DocumentPackage__c != null){
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
        }else if(ord.AutorizationVolturaThirdTrader__c == null && ord.CILegalRepresentative__c == null &&  ord.CIAccoutn__c == null && ord.QuickQuote__c == null && ord.ChamberCommerceRegistration__c == null && ord.Instance326__c == null && ord.DocumentLow80__c == null && ord.DocumentPackage__c == null) {
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
    /**
    * @author NTTDATA
    * @date 11/03/2022
    * @description Check if is Only Aggiunta Bonus
    * @param String orderParentId
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean isOnlyAmend(Order orderParent){
        Boolean result = false;
        
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderParent.Id);
        
        for (Order childOrder : childOrders) {
            if ((childOrder.ProcessType__c != null && childOrder.ProcessType__c.containsIgnoreCase('Aggiunta Sconti o Bonus VAS')) || childOrder.Type.equalsIgnoreCase('Amendment')) {
                result = true;
            }else {
                result = false;
                break;
            }
        }

        return result;
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
        public Boolean isCommunity {get; set;}
    }

    @AuraEnabled
    public static String seekFraud(String recordId, Order orderParent){
        //initialization the result for no fraud, then search for fraud condition
        Map<String,Object> result = new Map<String,Object>();
        Boolean isFraud = false;
        Boolean existNoEnergy = false;
        String message = 'Nessuna frode trovata.';
        Map<String,Boolean> energyMap = new Map<String,Boolean>{
            'Energia Elettrica'=>true,
            'Gas'=>true,
            'Acqua'=>false,
            'Teleriscaldamento'=>false,
            'Ambiente'=>false
        };
        Order parentOrder = new Order();
        List<String> processList = new List<String>();

        List<Order> orderList =[SELECT Account.Category__c, CommodityFormula__c,ParentOrder__c, PhoneNumber__c, ShippingMail__c, Contact__r.HomePhone, Contact__r.Phone, Contact__r.Email, ProcessType__c, Channel__c, CustomerCategory__c
                                FROM Order WHERE Id=:recordId OR ParentOrder__c = :recordId WITH SECURITY_ENFORCED];
        
        for(Order singleOrder : orderList)
        {
            String commodity = singleOrder.CommodityFormula__c;
            if(singleOrder.ParentOrder__c == null)
            {
                parentOrder = singleOrder;
            }
            else
            {
                processList.add(singleOrder.ProcessType__c);
            }
            if(String.isNotBlank(commodity) && energyMap.get(commodity) != null && !energyMap.get(commodity) && !existNoEnergy){
                existNoEnergy = true;
            }
        }

        if(!orderList.isEmpty() && !existNoEnergy){
            List<AmministrazioneFrodi__c> ammFrodiList = [SELECT BpNumber__c FROM AmministrazioneFrodi__c WHERE (Processo__c IN :processList AND CanaleVendita__c=: parentOrder.Channel__c AND CategoriaCliente__c=: parentOrder.Account.Category__c) WITH SECURITY_ENFORCED ];
            
            if( ammFrodiList != null && !ammFrodiList.isEmpty() ){
                integer maxCount = maxInFraud(orderList[0]);
                if( /* mmFrodiList[0].BpNumber__c != null && */ maxCount >= ammFrodiList[0].BpNumber__c ){
                    //Annullamento con causale: phase annullato + causale .txt + update
                    if(orderParent != null){
                        for (Order ord : orderList) {
                            ord.phase__c = 'Annullato';
                            ord.Status = 'Annullato';
                            ord.CancellationReason__c = 'Annullato per possibile frode';
                        }
                        HDT_UTL_DatabaseService.updateSObject(orderList);
                    }else{
                        Order ord = new Order();
                        ord.Id = orderList[0].Id;
                        ord.phase__c = 'Annullato';
                        ord.CancellationReason__c = 'Annullato per possibile frode';
                        HDT_UTL_DatabaseService.updateSObject(ord);
                    }
                    system.debug( 'Ordini interessati annullati' );
                    isFraud = true;
                    message = 'Possibile frode in corso, tutti gli ordini correlati verranno annullati.';
                }
            }
        }
        result.put('isFraud', (Object)isFraud);
        result.put('message', (Object)message);
        return JSON.serialize(result);
    }

    public static integer maxInFraud(Order order){
        integer maxCount = 0;
        //telefono fisso
        if( order.Contact__r.HomePhone != null ){
            AggregateResult[] count = [SELECT Count(Id) FROM ContactPointPhone WHERE TelephoneNumber=:order.Contact__r.HomePhone WITH SECURITY_ENFORCED GROUP BY TelephoneNumber ];
            maxCount = swapMax(maxCount, count );
        }
        //cell
        if( order.PhoneNumber__c != null ){
            AggregateResult[] count = [SELECT Count(Id) FROM ContactPointPhone WHERE TelephoneNumber=:order.PhoneNumber__c WITH SECURITY_ENFORCED GROUP BY TelephoneNumber ];
            maxCount = swapMax(maxCount, count );
        }else if( order.Contact__r.Phone != null ){
            AggregateResult[] count = [SELECT Count(Id) FROM ContactPointPhone WHERE TelephoneNumber=:order.Contact__r.Phone WITH SECURITY_ENFORCED GROUP BY TelephoneNumber ];
            maxCount = swapMax(maxCount, count );
        }
        //email
        if( order.ShippingMail__c != null ){
            AggregateResult[] count = [SELECT Count(Id) FROM ContactPointEmail WHERE EmailAddress=:order.ShippingMail__c AND Type__c = 'E-mail Anagrafica' WITH SECURITY_ENFORCED GROUP BY EmailAddress ];
            maxCount = swapMax(maxCount, count );
        }else if( order.Contact__r.Email != null ){
            AggregateResult[] count = [SELECT Count(Id) FROM ContactPointEmail WHERE EmailAddress=:order.Contact__r.Email AND Type__c = 'E-mail Anagrafica' WITH SECURITY_ENFORCED GROUP BY EmailAddress ];
            maxCount = swapMax(maxCount, count );
        }
        return maxCount;
    }
    
    public static integer swapMax(integer maxCount, AggregateResult[] count ){
        if(count.size()> 0 && count[0].get('expr0') != null){
            maxCount = maxCount < (integer)count[0].get('expr0')? (integer)count[0].get('expr0') : maxCount;
        }
        return maxCount;
    }


    public static void updateCommodityWithConsumptionAnalisi(String orderParentId)
    {
        List<OrderItem> orderItems = [SELECT Id,
        OwnerAC__c,
        DwellingType__c,
        OccupantsNumber__c,
        Surface__c,
        Product2.Family,
        SBQQ__QuoteLine__c,
        Order.ServicePointCode__c,
        Order.VasSubtype__c
        FROM OrderItem
        WHERE Order.ParentOrder__c = :orderParentId AND Order.Status NOT IN ('Annullato')
        WITH SECURITY_ENFORCED];

        List<SObject> sobjToUpdate = new List<SObject>();
        /*@frpanico 2022-11-17 
        * La list di quoteLine e' necessaria per dividere i chunk
        * Salesforce ha il limite di 10 chunk
        * se ho due oggetti A e B e ordino la lista A B A B A B Salesforce li considera singoli chunk andando in errore "Not more than 10 chunks..."
        * se ordino la lista A A A A A B B B B B Salesforce li considera come due chunk
        */
        List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
        

        Map<String, Map<String,OrderItem>> podOrderItemMap = new Map<String, Map<String,OrderItem>>();
        /* Build the map that groups orderItems for ServicePointCode of the related order */
        for(OrderItem item : orderItems)
        {
            if(!podOrderItemMap.containsKey(item.Order.ServicePointCode__c))
            {
                podOrderItemMap.put(item.Order.ServicePointCode__c, new Map<String,OrderItem>());
            }
            if(item.Product2.Family != null && item.Product2.Family.equalsIgnoreCase('Offerta commerciale'))
            {
                podOrderItemMap.get(item.Order.ServicePointCode__c).put('offertaCommerciale',item);
            }
            if(item.Product2.Family != null && item.Product2.Family.equalsIgnoreCase('VAS Fatturabili') && item.Order.VasSubtype__c.equalsIgnoreCase('Analisi Consumi'))
            {
                podOrderItemMap.get(item.Order.ServicePointCode__c).put('analisiConsumi',item);
            }
        }
        /* Write on the commodity OrderItem/QuoteLine
        Consumption Analysis fields 
        */
        for(String key : podOrderItemMap.keySet())
        {
            if(podOrderItemMap.get(key).get('analisiConsumi') == null)
            {
                continue;
            }
            OrderItem offertaCommerciale = new OrderItem(Id = (String) (podOrderItemMap.get(key).get('offertaCommerciale')).get('Id'));
            SBQQ__QuoteLine__c offertaCommQl = new SBQQ__QuoteLine__c(Id =(String) (podOrderItemMap.get(key).get('offertaCommerciale')).get('SBQQ__QuoteLine__c'));
            offertaCommerciale.OwnerAC__c = (String) (podOrderItemMap.get(key).get('analisiConsumi')).get('OwnerAC__c');
            offertaCommerciale.DwellingType__c = (String) (podOrderItemMap.get(key).get('analisiConsumi')).get('DwellingType__c');
            offertaCommerciale.OccupantsNumber__c = (Decimal) (podOrderItemMap.get(key).get('analisiConsumi')).get('OccupantsNumber__c');
            offertaCommerciale.Surface__c = (Decimal) (podOrderItemMap.get(key).get('analisiConsumi')).get('Surface__c');
            offertaCommQl.OwnerAC__c = (String) (podOrderItemMap.get(key).get('analisiConsumi')).get('OwnerAC__c');
            offertaCommQl.DwellingType__c = (String) (podOrderItemMap.get(key).get('analisiConsumi')).get('DwellingType__c');
            offertaCommQl.OccupantsNumber__c = (Decimal) (podOrderItemMap.get(key).get('analisiConsumi')).get('OccupantsNumber__c');
            offertaCommQl.Surface__c = (Decimal) (podOrderItemMap.get(key).get('analisiConsumi')).get('Surface__c');

            sobjToUpdate.add(offertaCommerciale);
            quoteLineToUpdate.add(offertaCommQl);
        }
        if(!quoteLineToUpdate.isEmpty())
        {
            sobjToUpdate.addAll(quoteLineToUpdate);
        }
        if(!sobjToUpdate.isEmpty())
        {
            HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
        }

    }

    private static void handleTariOrder(Order orderParentRetreived){
        Order parentOrderToUpdate = new Order();
        parentOrderToUpdate.Id = orderParentRetreived.Id;
        if('Contratto già firmato'.equalsIgnoreCase(orderParentRetreived.SignatureMethod__c) || orderParentRetreived.RequestSource__c.equalsIgnoreCase('D\'ufficio') || orderParentRetreived.DeliveredDocumentation__c.equalsIgnoreCase('Y')){
            parentOrderToUpdate.Phase__c = 'Documentazione Gestita';
            parentOrderToUpdate.Status = 'Completed';
        }else{
            parentOrderToUpdate.Phase__c = 'Documentazione da inviare';
        }

        List<Order> ordersToUpdate = new List<Order>{parentOrderToUpdate};

        for(Order childOrd : orderQr.getChildOrdersByParentId(orderParentRetreived.Id)){
            if( 'HDT_RT_AgevolazioniAmbiente' == childOrd.RecordType.DeveloperName && childOrd.OrderReference__c != null){
                Order o = new Order(
                    Id=childOrd.Id,
                    Surface__c = childOrd.OrderReference__r.Surface__c
                );
                ordersToUpdate.add( o );
            }
        }
        orderSrv.updateRecords(ordersToUpdate);
    }

}