/**
 * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
 * @date 06/02/2021
 * @description HDT_LC_ChildOrderProcessPrecheck.cls - Class that holds methods that are called from hdtChildOrderProcessPrecheck.js
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */
public inherited sharing class HDT_LC_ChildOrderProcessPrecheck {

    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_Order orderSrv = new HDT_SRV_Order();

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 06/02/2021
     * @description Get List of process options
     * @return List<Map<String,List<SObject>>>
     */
    @AuraEnabled
    public static List<Map<String,String>> getOptions(){
        List<Map<String,String>> options = new List<Map<String,String>>(); 

        List<Schema.RecordTypeInfo> recordTypes = Order.SObjectType.getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            if (recordType.getDeveloperName() != 'HDT_RT_Default' && recordType.getDeveloperName() != 'Master' && recordType.getDeveloperName() != 'HDT_RT_Default' && recordType.getDeveloperName() != 'HDT_RT_OrderDossier') {
                Map<String,String> singleOption = new Map<String,String>();
                singleOption.put('Id', recordType.getRecordTypeId());
                singleOption.put('Label', recordType.getName());
                singleOption.put('DeveloperName', recordType.getDeveloperName());
                options.add(singleOption);
            }
        }

        return options;
    }

    /**
     * @author Keltin Mesonjesi (keltin.mesonjesi@dunegroup.it)
     * @date 06/02/2021
     * @description Handle actions on "Avanti" click
     * @param orderId
     * @param String selectedProcess - selected process for child order
     * @param String deliberate
     */
    @AuraEnabled
    public static void next(String orderId, String selectedProcess, String deliberate){

        String recordTypeId = orderSrv.getRecordTypeIdByDeveloperName(selectedProcess);

        orderSrv.updateRecord(new Order(
            Id = orderId,
            RecordTypeId = recordTypeId,
            Step__c = 2,
            Deliberation__c = deliberate
        ));
    }
}
