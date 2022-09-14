/**
* @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
* @date 26/11/2020
* @description HDT_LC_SaleServiceContainer – Apex controller for hdtSaleServiceContainer.js component
* @history Keltin Mesonjesi – 23/11/2020 – Created class
*/
public inherited sharing class HDT_LC_SaleServiceContainer {
    private static HDT_QR_Contract contractQr = new HDT_QR_Contract();
    
    private static HDT_QR_SaleServiceItem saleServiceItemQr = new HDT_QR_SaleServiceItem();
    private static HDT_SRV_SaleServiceItem saleServiceItemSrv = new HDT_SRV_SaleServiceItem();
    private static HDT_SRV_Sale saleSrv = new HDT_SRV_Sale();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if service point for current sale account is linked to quotes that have a contract
     * @param String accountId
     * @param ServicePoint__c newServicePoint
     */
    private static Boolean isServicePointLinkedToContract(ServicePoint__c newServicePoint, String accountId) {
        
        saleServiceItemSrv.checkReadAccess('Id, Status,AccountId,ServicePoint__c ');
        List<Contract> linkedContracts = contractQr.getRecordsWithContractsByServicePointAndAccountId(newServicePoint.Id, accountId);

        return !linkedContracts.isEmpty();
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Check if field "Uso Energia" has been changed on confirmation for service point
     * @param String accountId
     * @param ServicePoint__c newServicePoint
     * @param String  oldSupplyType
     */
    private static Boolean hasUsoEnergiaChangedForEle(String accountId, ServicePoint__c newServicePoint, String oldSupplyType) {
        return isServicePointLinkedToContract(newServicePoint, accountId) && newServicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' && oldSupplyType != '' && oldSupplyType != newServicePoint.SupplyTypeTemp__c;
    }

    private static Boolean hasUsoEnergiaChangedForEle(String accountId, ServicePoint__c newServicePoint, String oldSupplyType, Boolean isTransition) {
        return (isServicePointLinkedToContract(newServicePoint, accountId) || isTransition )&& newServicePoint.RecordType.DeveloperName == 'HDT_RT_Ele' && oldSupplyType != '' && oldSupplyType != newServicePoint.SupplyTypeTemp__c;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Create tile
     * @param ServicePoint__c servicePoint
     * @param Sale__c sale
     */
    @AuraEnabled
    public static Map<String,Boolean> createSaleServiceItemTile(ServicePoint__c servicePoint, Sale__c sale, String oldSupplyType){
        
        Map<String,String> extraParams = new Map<String,String>();
        Boolean message = false;
        boolean isTransition =HDT_UTL_Sales.isTransition(ServicePoint,sale);
        List<account> acc = [ SELECT CustomerMarking__c FROM account WHERE Id=:sale.Account__c WITH SECURITY_ENFORCED];
        String regex = '^D[0-9] - .*';
        Pattern regexPattern = Pattern.compile(regex);
        /**@frpanico necessaria creazione activity
         * Caricamento manuale in Siebel
         */
        if ( isTransition && regexPattern.matcher(acc[0].CustomerMarking__c).matches() ){
            message = true;
        }
        
        if (hasUsoEnergiaChangedForEle(sale.Account__c, servicePoint, oldSupplyType,isTransition)) {
            List<Contract> linkedContracts = contractQr.getRecordsWithContractsByServicePointAndAccountId(servicePoint.Id, sale.Account__c);
            String contractReference = (linkedContracts != null && linkedContracts.size() > 0) ? String.valueOf(linkedContracts[0].id) : '';
            extraParams.put('AllowChangeUse__c', 'true');
            extraParams.put('contractReference', contractReference);
        }

        boolean isMeterRelation = (servicePoint.MeterRelation__c != null);

        saleServiceItemSrv.createRecord(servicePoint, sale, extraParams);
        //boolean isTransition =HDT_UTL_Sales.isTransition(ServicePoint,sale);
        Map<String,Boolean> result = new Map<String,Boolean>{
            'isTransition'=>isTransition,
            'message' => message,
            'isMeterRelation' => isMeterRelation
        };
        return result;

    }
    

    /**@frpanico metodo creazione activity
     * manuale
     */
    public static String siebelLoadingActivity(String recordId, String accountId, String objectType)
    {
        wrts_prcgvr__Activity__c activity = new wrts_prcgvr__Activity__c();
        activity.wrts_prcgvr__Status__c = 'Aperta';
        activity.Account__c = accountId;
        activity.ActivityStartTime__c = System.now();
        activity.Type__c = 'Caricamento Manuale Siebel';
        activity.DiscardCategory__c = 'Manuale';
        if(objectType.equalsIgnoreCase('Order'))
        {
            activity.Order__c = recordId;
        }
        else if(objectType.equalsIgnoreCase('Sale__c'))
        {
            activity.Sale__c = recordId;
        }
        HDT_UTL_DatabaseService.insertSObject(activity);
        return activity.Id != null ? activity.Id : '';
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @description Update Sale
     * @param Sale__c sale
     */
    @AuraEnabled
    public static void updateSale(Sale__c sale){
        List<SObject> sobjToUpdate = new List<SObject>();
        /**@frpanico se ci sono vendite a transitorio
         * ibride
         * Assicurarsi che tutte le vendite siano marcate a transitorio
         */
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Sale__r.Account__r.CustomerMarking__c, IsTransition__c FROM SBQQ__Quote__c WHERE Sale__c = :sale.Id WITH SECURITY_ENFORCED];
        if(!quoteList.isEmpty())
        {
            Boolean newCustomerMarking = false;
            Boolean isTransition = false;
            for(SBQQ__Quote__c quote : quoteList)
            {
                if(quote.isTransition__c)
                {
                    isTransition = true;
                    break;
                }
            }
            String regex = '^D[0-9] - .*';
            Pattern regexPattern = Pattern.compile(regex);
            if(regexPattern.matcher(quoteList[0].Sale__r.Account__r.CustomerMarking__c).matches())
            {
                newCustomerMarking = true;
            }
            if(!newCustomerMarking && isTransition)
            {
                for(SBQQ__Quote__c quote : quoteList)
                {
                    quote.IsTransition__c = true;
                    sobjToUpdate.add(quote);
                }
                sale.IsTransition__c = true;
            }
        }
        sobjToUpdate.add(sale);
        system.debug(sale.CurrentStep__c);
        HDT_UTL_DatabaseService.updateSObject(sobjToUpdate);
    }
}