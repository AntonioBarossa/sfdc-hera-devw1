/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 13/01/2021
* @description Apex controller hdtOrderDossierWizardSignature component
* @history Keltin Mesonjesi – 13/01/2021 – Created class
*/
public inherited sharing class HDT_LC_OrderDossierWizardSignature {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();
    private static HDT_QR_Contact contactQr = new HDT_QR_Contact();
    private static HDT_SRV_Contact contactSrv = new HDT_SRV_Contact();

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 15/01/2021
    * @description Handle controller initial data fetch
    * @param String orderParentId
    * @param String accountId
    * @return Map<String,Object>
    */
    @AuraEnabled
    public static Map<String,Object> controllerInit(String orderParentId, String accountId){
        Map<String,Object> result = new Map<String,Object>();

        contactSrv.checkReadAccess('Email');
        List<Contact> primaryContact = contactQr.getPrimaryContactByAccount(accountId);
        String primaryContactEmail = primaryContact.isEmpty() ? '' : primaryContact[0].Email;
        result.put('primaryContactEmail', primaryContactEmail);

        orderSrv.checkReadAccess('BillingProfile__c,BillingProfile__r.InvoicingCityCode__c,BillingProfile__r.InvoicingCountry__c,BillingProfile__r.InvoicingPlace__c,BillingProfile__r.InvoicingPostalCode__c,BillingProfile__r.InvoicingProvince__c,BillingProfile__r.InvoicingStreetName__c,BillingProfile__r.InvoicingStreetNumber__c,BillingProfile__r.InvoicingStreetNumberExtension__c');
        List<Order>ordChildList = orderQr.getChildOrdersByParentId(orderParentId);
        result.put('ordChildList', ordChildList);

        return result;
    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/02/2021
    * @description Handle next action on signature section
    * @param Order orderUpdates
    */
    @AuraEnabled
    public static void next(Order orderUpdates){
        List<Order> childOrders = orderQr.getChildOrdersByParentId(orderUpdates.Id);
        List<Order> ordersToUpdate = new List<Order>();
        Map<String,Object> objMap = orderUpdates.getPopulatedFieldsAsMap();
        Map<Id,Order> changeSignatureOrdersToUpdate = new Map<Id,Order>();
        Map<Id,Order> changeSignatureOldOrders = new Map<Id,Order>();

        for (Order childOrder : childOrders) {
            Order childOrderToUpdate = new Order(
                Id = childOrder.Id
            );

            for (String key : objMap.keySet()) {
                if (key != 'Id') {
                    childOrderToUpdate.put(key, objMap.get(key));
                }
                if(key == 'RelatedPractice__c'){
                    orderUpdates.RelatedPractice__c = (String)objMap.get(key);
                }
            }
            checkSignatureMethod(childOrderToUpdate, childOrder);
            try{
                if ((String.isNotBlank(childOrderToUpdate.DocSendingMethod__c) && !childOrderToUpdate.DocSendingMethod__c.equalsIgnoreCase(childOrder.DocSendingMethod__c)) 
                || (String.isNotBlank(childOrderToUpdate.SignatureMethod__c) && !childOrderToUpdate.SignatureMethod__c.equalsIgnoreCase(childOrder.SignatureMethod__c))){
                    changeSignatureOrdersToUpdate.put(childOrderToUpdate.Id,childOrderToUpdate);
                    changeSignatureOldOrders.put(childOrder.Id,childOrder);
                    continue;
                }
            }catch (Exception e){
                system.debug('ChangeSignature exception: ' + e.getMessage());
            }
            system.debug('childOrderToUpdate: ' + childOrderToUpdate);
            ordersToUpdate.add(childOrderToUpdate);
        }

        orderUpdates.Step__c = 2; //update order parent step
        ordersToUpdate.add(orderUpdates); //add order parent to list

        if(orderUpdates.ContractSigned__c != null && orderUpdates.ContractSigned__c){

            for (Order o : ordersToUpdate) {
                o.SignatureMethod__c = 'Cartacea'; //updates parent and child
                o.DocSendingMethod__c = 'Stampa Cartacea'; //updates parent and child
            }

        }

        updateQualityCall(ordersToUpdate, changeSignatureOrdersToUpdate, changeSignatureOldOrders);

        system.debug('childOrdersToUpdate before update: ' + ordersToUpdate);
        orderSrv.updateRecords(ordersToUpdate);
        system.debug('childOrdersToUpdate after update: ' + ordersToUpdate);
    }

    private static void checkSignatureMethod(Order newOrder, Order oldOrder){

        switch on oldOrder.RecordType.DeveloperName {
            when 'HDT_RT_SwitchIn' {
                if(oldOrder.Account.RecordType.DeveloperName == 'HDT_RT_Business'){
                    if(oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && !newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        if (oldOrder.VolturaThirdTrader__c == true) {
                            newOrder.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }
                        newOrder.CILegalRepresentative__c = 'Richiesto';
                    }
                    else if(!oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        if (oldOrder.VolturaThirdTrader__c == true) {
                            newOrder.AutorizationVolturaThirdTrader__c = '';
                        }
                        newOrder.CILegalRepresentative__c = '';
                    }
                }
                else{
                    if(oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && !newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        if (oldOrder.VolturaThirdTrader__c == true) {
                            newOrder.AutorizationVolturaThirdTrader__c = 'Richiesto';
                        }
                        newOrder.CIAccoutn__c = 'Richiesto';
                    }
                    else if(!oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        if (oldOrder.VolturaThirdTrader__c == true) {
                            newOrder.AutorizationVolturaThirdTrader__c = '';
                        }
                        newOrder.CIAccoutn__c = '';
                    }
                }
                
            }
            when 'HDT_RT_VolturaConSwitch' {

                if(oldOrder.Account.RecordType.DeveloperName == 'HDT_RT_Business'){

                    if(oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && !newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        newOrder.CILegalRepresentative__c = '';
                    }
                    else if(!oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        newOrder.CILegalRepresentative__c = 'Richiesto';
                    }
                }
                else {
                    if(oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && !newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        newOrder.CIAccoutn__c = '';
                    }
                    else if(!oldOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order') && newOrder.SignatureMethod__c.equalsIgnoreCase('Vocal Order')){
                        newOrder.CIAccoutn__c = 'Richiesto';
                    }
                }
            }
        }

    }

    /**
    * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
    * @date 05/02/2021
    * @description Handle "modifica" action on signature section
    * @param String orderParentId
    */
    @AuraEnabled
    public static void edit(String orderParentId){
        orderSrv.updateRecord(new Order(
            Id = orderParentId,
            Step__c = 1
        ));
    }

    private static void updateQualityCall(List<Order> ordersToUpdate,Map<Id,Order> newOrderMap,Map<Id,Order> oldOrderMap){
        if (newOrderMap.isEmpty()){
            return;
        }
        List<Order> ordersToWork = new List<Order>();
        List<Order> ordersVasToWork= new List<Order>();
        for (Id orderId : oldOrderMap.keySet()){
            Order oldOrder = oldOrderMap.get(orderId);
            //La prima volta che eseguo questo metodo, gli ordini sono in HDT_RT_Default. Quindi vengono saltati perché il calcolo della comfort/quality verrà eseguito direttamente nel wizard.
            if ('HDT_RT_Default'.equalsIgnoreCase(oldOrder.RecordType.DeveloperName)||'HDT_RT_OrderDossier'.equalsIgnoreCase(oldOrder.RecordType.DeveloperName)){
                ordersToUpdate.add(newOrderMap.get(orderId));
                continue;
            }
            if ('HDT_RT_VAS'.equalsIgnoreCase(oldOrder.RecordType.DeveloperName)){
                ordersVasToWork.add(oldOrder);
                continue;
            }
            ordersToWork.add(oldOrder);       
        }

        if (ordersToWork.isEmpty() && ordersVasToWork.isEmpty()){
            return;
        }
        
        workOrders(ordersToUpdate,ordersToWork,newOrderMap);
        workOrders(ordersToUpdate,ordersVasToWork,newOrderMap);
    }


    private static List<ComfortQualityCall__c> executeQuery(List<Order> orders,String signatureMethod,String docSendingMethod){
        
        Set<String> channel = new Set<String>();
        Set<String> recordType = new Set<String>();
        Set<String> customerCategory = new Set<String>();
        Set<String> marketOrigin = new Set<String>();
        Boolean isVas = false;
        for (Order ord : orders){
            populateSetString(channel, ord.Channel__c);
            populateSetString(customerCategory, ord.CustomerCategory__c);
            if ('HDT_RT_VAS'.equalsIgnoreCase(ord.RecordType.DeveloperName)){
                isVas = true;
                continue;
            }
            populateSetString(marketOrigin, ord.MarketOrigin__c);
            populateSetString(recordType, ord.RecordType.DeveloperName);            
        }
        if (isVas){
            return [SELECT
            Id,
            ComfortEnabled__c,
            QualityEnabled__c,
            Process__c,
            Channel__c,
            MarketType__c,
            CustomerType__c,
            DaysComfort__c,
            UniqueQuality__c,
            ComfortDocSendingChannel__c,
            QualitySignatureMethod__c,
            ComfortSignatureMethod__c
            FROM ComfortQualityCall__c
            WHERE Process__c = 'HDT_RT_Vas' //text
            AND Channel__c IN :channel //text
            AND CustomerType__c IN :customerCategory //text
            AND (QualitySignatureMethod__c = :signatureMethod
                OR ComfortSignatureMethod__c = :signatureMethod
                OR ComfortDocSendingChannel__c = :docSendingMethod)
            WITH SECURITY_ENFORCED];
        }
        return [SELECT
        Id,
        ComfortEnabled__c,
        QualityEnabled__c,
        Process__c,
        Channel__c,
        MarketType__c,
        CustomerType__c,
        DaysComfort__c,
        UniqueQuality__c,
        ComfortDocSendingChannel__c,
        QualitySignatureMethod__c,
        ComfortSignatureMethod__c
        FROM ComfortQualityCall__c
        WHERE Process__c IN :recordtype //text
        AND Channel__c IN :channel //text
        AND CustomerType__c IN :customerCategory //text
        AND MarketType__c IN :marketOrigin //picklist
        AND (ComfortSignatureMethod__c = :signatureMethod 
            OR QualitySignatureMethod__c = :signatureMethod)
        WITH SECURITY_ENFORCED];

    }

    private static void workOrders(List<Order> ordersToUpdate,List<Order> oldOrders,Map<Id,Order> newOrderMap){
        if (oldOrders.isEmpty()){
            return;
        }
        String signatureMethod = String.isNotBlank(newOrderMap.values()[0].SignatureMethod__c) ? newOrderMap.values()[0].SignatureMethod__c :  oldOrders[0].SignatureMethod__c;
        String docSendingMethod = String.isNotBlank(newOrderMap.values()[0].DocSendingMethod__c) ? newOrderMap.values()[0].DocSendingMethod__c :  oldOrders[0].DocSendingMethod__c;

        List<ComfortQualityCall__c> myComfortQualityList = executeQuery(oldOrders,signatureMethod,docSendingMethod);
        Integer numberChild = ordersToUpdate.size() + newOrderMap.keySet().size() -1;
        for (Order oldOrder : oldOrders){
            List<ComfortQualityCall__c> comfortQualityList = new List<ComfortQualityCall__c>();
            Order orderForQuery = oldOrder.clone();
            orderForQuery.SignatureMethod__c = signatureMethod;
            orderForQuery.DocSendingMethod__c = docSendingMethod;
            comfortQualityList = getComfortQualityCall(orderForQuery,myComfortQualityList);
            Order newOrder = newOrderMap.get(oldOrder.Id);
            if (comfortQualityList.isEmpty()){
                newOrder.QualityCall__c = false;
                newOrder.QualityCallUnique__c = false;
                newOrder.ComfortCallDaysDue__c = null;
                newOrder.DateComfortCall__c = null;
                ordersToUpdate.add(newOrder);
                continue;
            }

            ComfortQualityCall__c comforQualityRes = new ComfortQualityCall__c();
            newOrder.QualityCall__c = true;
            newOrder.ComfortCallDaysDue__c = null;
            newOrder.DateComfortCall__c = null;
            newOrder.QualityCallUnique__c = numberChild > 1;

            if (comfortQualityList.size() > 1) {
                for (ComfortQualityCall__c cqc : comfortQualityList) {
                    if(cqc.ComfortEnabled__c && cqc.ComfortSignatureMethod__c == signatureMethod && cqc.ComfortDocSendingChannel__c == docSendingMethod){
                        comforQualityRes = cqc;
                        break;
                    }
                    else if (cqc.QualityEnabled__c && cqc.QualitySignatureMethod__c == signatureMethod) {
                        comforQualityRes = cqc;
                        break;
                    }
                }
            }
            else {
                comforQualityRes = comfortQualityList[0];
            }
            System.debug('@@@@@comforQualityRes ' + comforQualityRes);
            if (comforQualityRes.ComfortEnabled__c) {
                newOrder.ComfortCallDaysDue__c = comforQualityRes.DaysComfort__c;
                newOrder.DateComfortCall__c = Date.today();
            }
            ordersToUpdate.add(newOrder);
        }
    }

    private static void populateSetString(Set<String> queryValue, String value){
        if (String.isNotBlank(value)){
            queryValue.add(value);
        }
    }

    private static List<ComfortQualityCall__c> getComfortQualityCall(Order o, List<ComfortQualityCall__c> comfortQualityCall){
        List<ComfortQualityCall__c> response = new List<ComfortQualityCall__c>();
        for (ComfortQualityCall__c cqc : comfortQualityCall){
            System.debug(LoggingLevel.DEBUG, '@@@@@cqc ' + JSON.serialize(cqc));
            if (
                (
                    'HDT_RT_VAS'.equalsIgnoreCase(o.RecordType.Developername) 
                    && 'HDT_RT_VAS'.equalsIgnoreCase(cqc.Process__c)
                    && (String.isNotBlank(o.Channel__c) && o.Channel__c.equalsIgnoreCase(cqc.Channel__c))
                    && (String.isNotBlank(o.CustomerCategory__c) && o.CustomerCategory__c.equalsIgnoreCase(cqc.CustomerType__c))
                    && (
                        (String.isNotBlank(o.SignatureMethod__c) && o.SignatureMethod__c.equalsIgnoreCase(cqc.QualitySignatureMethod__c))
                        || (String.isNotBlank(o.SignatureMethod__c) && o.SignatureMethod__c.equalsIgnoreCase(cqc.ComfortSignatureMethod__c))
                        || (String.isNotBlank(o.DocSendingMethod__c) && o.DocSendingMethod__c.equalsIgnoreCase(cqc.ComfortDocSendingChannel__c))
                    )
                )
            ||
                (
                    !'HDT_RT_VAS'.equalsIgnoreCase(o.RecordType.Developername)
                    &&(String.isNotBlank(o.RecordType.DeveloperName) && o.RecordType.DeveloperName.equalsIgnoreCase(cqc.Process__c))
                    && (String.isNotBlank(o.Channel__c) && o.Channel__c.equalsIgnoreCase(cqc.Channel__c))
                    && (String.isNotBlank(o.CustomerCategory__c) && o.CustomerCategory__c.equalsIgnoreCase(cqc.CustomerType__c))
                    && (String.isNotBlank(o.MarketOrigin__c) && o.MarketOrigin__c.equalsIgnoreCase(cqc.MarketType__c))
                    && (
                        (String.isNotBlank(o.SignatureMethod__c) && o.SignatureMethod__c.equalsIgnoreCase(cqc.ComfortSignatureMethod__c))
                        || (String.isNotBlank(o.SignatureMethod__c) && o.SignatureMethod__c.equalsIgnoreCase(cqc.QualitySignatureMethod__c))
                    )
                )
            ){
                response.add(cqc);
            }
        }
        return response;
    }

}