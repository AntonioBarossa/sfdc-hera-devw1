/**
 * @author Andrei Necsulescu (andrei.necsulescu@webresults.it)
 * @date 07/09/2021
 * @description HDT_LCP_CreateDistributorApointment - Controller for hdtCreateDistributorApointmentActivity
 * @history Inserire Nome Cognome – Data Modifica – Descrizione della modifica
 */

public with sharing class HDT_LCP_CreateDistributorApointment {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_QR_Order orderQr = new HDT_QR_Order();
    private static HDT_SRV_ActivityCustom activitySrv = new HDT_SRV_ActivityCustom();
    private static HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
    
    @AuraEnabled
    public static Map<String, Object> createActivity(Id objectId){

        Map<String, Object> result = new Map<String,Object>();
        String nameDistributor = '';
        String commodity = '';
        String salesCode = '';
        String processCode = '';
        try {

            String objectType = String.valueOf(objectId.getSobjectType());

            wrts_prcgvr__Activity__c newActivity;

            HDT_SRV_AppointmentAgenda agendaSrv = new HDT_SRV_AppointmentAgenda();
            switch on objectType {
                when 'Case' {
                    
                    Case currentCase = caseQr.getRecordById(objectId);

                    newActivity = new wrts_prcgvr__Activity__c();

                    newActivity.RecordTypeId = constantsUtl.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
                    newActivity.Account__c = currentCase.AccountId;
                    newActivity.Contact__c = currentCase.ContactId;
                    newActivity.Case__c = currentCase.Id;
                    newActivity.Distributor__c = currentCase.ServicePoint__r.Distributor__c;
                    agendaSrv.setContactData(newActivity, currentCase.Contact);
                    nameDistributor = currentCase.ServicePoint__r != null ? currentCase.ServicePoint__r.distributor__r.name : currentCase.Distributor__r.Name;
                    commodity = currentCase.ServicePoint__r != null ? currentCase.ServicePoint__r.CommoditySector__c : currentCase.Commodity__c;
                    salesCode =  currentCase.SalesCompanyCode__c;
                    processCode = currentCase.CausalCode__c;
                }
                when 'Order' {

                    Order currentOrder = orderQr.getRecordById(objectId);

                    newActivity = new wrts_prcgvr__Activity__c();

                    newActivity.RecordTypeId = constantsUtl.ACTIVITYCUSTOM_RECORDTYPEID_DISTRIBUTORAPPOINTMENT;
                    newActivity.Account__c = currentOrder.AccountId;
                    newActivity.Contact__c = currentOrder.Contact__c;
                    newActivity.Order__c = currentOrder.Id;
                    newActivity.Distributor__c = currentOrder.ServicePoint__r.Distributor__c;
                    agendaSrv.setContactData(newActivity, currentOrder.Sale__r.SalesContact__r);
                    nameDistributor = currentOrder.ServicePoint__r.distributor__r.name;
                    commodity = currentOrder.ServicePoint__r.CommoditySector__c;
                    salesCode =  currentOrder.SalesCompanyCode__c;
                    processCode = currentOrder.ProcessCode__c;
                }
                when else {

                    result.put('error', true);
                    result.put('errorMessage', Label.UnsupportedObjectType);

                }
                
            }

            if (newActivity != null) {
                HDT_AppointmentSetting__mdt conf = HDT_UTL_AppointmentSetting.getAtoaFlag(processCode, nameDistributor, commodity, salesCode);
                newActivity.isAtoa__c = conf != null ? conf.Flag__c : false;
                activitySrv.createRecord(newActivity);
            }

            result.put('newActivity', newActivity);
            result.put('error', false);
            
        } catch (Exception e) {
            
            result.put('error', true);
            result.put('errorMessage', e.getMessage());
            result.put('errorStackTrace', e.getStackTraceString());

        }

        return result;
    }
}
