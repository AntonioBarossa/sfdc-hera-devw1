/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 06-10-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.IfStmtsMustUseBraces, PMD.IfElseStmtsMustUseBraces, PMD.pmdAvoidDebugStatements, PMD.CyclomaticComplexity, PMD.ClassNamingConventions')
public with sharing class HDT_LC_AppointmentTariAgenda {
    
    private static HDT_SRV_AppointmentAgenda srvAgenda = new HDT_SRV_AppointmentAgenda();
    private static final String FIELDS_FOR_QUERY_CASE = 'Id, CaseNumber';

    private static final String REQUEST_PATH_SEARCH = '/appointments/search';
    private static final String REQUEST_PATH_CONFIRM = '/appointments/confirm';
    private static final String REQUEST_PATH_VIEW = '/appointments';

    public virtual class HDT_WRP_AppointmentReqSearch extends HDT_WS_Request{
        String purchaseOrderNumber;
        String streetCoding;
        String street;
        String housenumber;
        String typeInt;
        String indicator;
        String numberOfLines;

        public HDT_WRP_AppointmentReqSearch(String purchaseOrderNumber, String streetCoding, String street,
                                    String housenumber, String typeInt, String indicator, String numberOfLines) {
        
            this.purchaseOrderNumber = purchaseOrderNumber;
            this.streetCoding = streetCoding;
            this.street = street;
            this.housenumber = housenumber;
            this.typeInt = typeInt;
            this.indicator = indicator;
            this.numberOfLines = numberOfLines;
        }
    }

    
    private class HDT_WS_AppointmentSearchResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_Data_Search data {get;set;}
    }
    private class HDT_WRP_Data_Search{
		@AuraEnabled public String outcome {get;set;}
        @AuraEnabled public String text {get;set;}
		@AuraEnabled public List<HDT_WRP_AppointmentDate> appointmentData {get;set;}
	}
    private class HDT_WRP_AppointmentDate{
		@AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
	}


    public virtual class HDT_WRP_AppointmentReqConfirm extends HDT_WS_Request{
        String purchaseOrderNumber;
        String streetCoding;
        String street;
        String housenumber;
        String typeInt;
        String indicator;
        String numberOfLines;
        Datetime startDate;
        Datetime endDate;
        
        public HDT_WRP_AppointmentReqConfirm(String purchaseOrderNumber, String streetCoding, String street,
                                        String housenumber, String typeInt, String indicator, String numberOfLines, Datetime startDate, Datetime endDate) {

            this.purchaseOrderNumber = purchaseOrderNumber;
            this.streetCoding = streetCoding;
            this.street = street;
            this.housenumber = housenumber;
            this.typeInt = typeInt;
            this.indicator = indicator;
            this.numberOfLines = numberOfLines;
            this.startDate = startDate;
            this.endDate = endDate;

        }
    }

    private class HDT_WS_AppointmentConfirmResponse extends HDT_WS_Response {
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_Data_Confirm data {get;set;}
    }

    private class HDT_WRP_Data_Confirm{
        @AuraEnabled public String noticeNumber {get;set;}
        @AuraEnabled public String workCenterId {get;set;}
        @AuraEnabled public String division {get;set;}
        @AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
    }

    public class HDT_WS_AppointmentViewResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public List<HDT_WRP_AppointmentView> data {get;set;}
    }
        
    private class HDT_WRP_AppointmentView{
        @AuraEnabled public String stanoticeNumbertus {get;set;}
        @AuraEnabled public String appointmentType {get;set;}
        @AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WS_AppointmentSearchResponse handleSearch(String purchaseOrderNumber, String streetCoding, String street, String housenumber,String typeInt, String indicator, String numberOfLines) {
        HDT_WRP_AppointmentReqSearch req = new HDT_WRP_AppointmentReqSearch(purchaseOrderNumber,streetCoding,street,housenumber,typeInt,indicator,numberOfLines);
        HDT_WS_AppointmentSearchResponse res = (HDT_WS_AppointmentSearchResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH_SEARCH,'POST', req, HDT_WS_AppointmentSearchResponse.class);
        System.Debug('search res -> ' + res); 
        return res;
    }

    @AuraEnabled
    public static HDT_WS_AppointmentConfirmResponse handleConfirm(Case theCase, String purchaseOrderNumber, String streetCoding, String street, String housenumber, String typeInt, String indicator, String numberOfLines, Datetime startDate, Datetime endDate) {
        HDT_WRP_AppointmentReqConfirm req = new HDT_WRP_AppointmentReqConfirm(purchaseOrderNumber,streetCoding,street,housenumber,typeInt,indicator,numberOfLines,startDate,endDate);
        HDT_WS_AppointmentConfirmResponse res = (HDT_WS_AppointmentConfirmResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH_CONFIRM,'POST', req, HDT_WS_AppointmentConfirmResponse.class);
        
        if(res.status.equalsIgnoreCase('success')){
            theCase.StartAppointment__c = startDate;
            theCase.EndAppointment__c = endDate;
            theCase.Phase__c = 'Da Inviare';
            theCase.Outcome__c ='Recived_Slots';

            if(!theCase.WithdrawalFee__c){
                Date dataRitiro = Date.newinstance(theCase.CreatedDate.year(), theCase.CreatedDate.month(), theCase.CreatedDate.day());
                FreeWithdraw__c ritiro = new FreeWithdraw__c();
                ritiro.ServicePoint__c = theCase.ServicePoint__c;
                ritiro.LastFreeWithdrawDate__c = dataRitiro;
                System.debug('ritiro -> ' + ritiro);
                HDT_UTL_DatabaseService.insertSObject(ritiro);
            }
            HDT_UTL_DatabaseService.updateSObject(theCase);
        }
        return res;
    }

    @AuraEnabled
    public static HDT_WS_AppointmentViewResponse handleView(String purchaseOrderNumber) {
        // HDT_WRP_AppointmentReqView req = new HDT_WRP_AppointmentReqView(purchaseOrderNumber);
        string path = REQUEST_PATH_VIEW+'?purchaseOrderNumber='+purchaseOrderNumber;
        HDT_WS_AppointmentViewResponse res = (HDT_WS_AppointmentViewResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',path,'GET', (HDT_WS_Request)null, HDT_WS_Response.class);
        return res;
    }

    public enum requestType {
        CANCELLATION,CONFIRM,EDIT,NEW_SLOT,FIRST_SEARCH
    }

    @AuraEnabled(cacheable=true)
    public static String getCase(String caseId,List<String> fields){
        String response = '';
        try{
            response = JSON.serialize(HDT_UTL_AppointmentAgenda.getCase(caseId,String.join(fields,',')));
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
    
    @AuraEnabled
    public static void handleNewActivityCreationAndCaseUpdate(String caseId, String caseFields, String templateName, String activityFields){    
        System.debug('caseId -> ' + caseId);
        System.debug('activityFields -> ' + JSON.deserializeUntyped(activityFields));
        System.debug('caseFields -> ' + JSON.deserializeUntyped(caseFields));

        Map<String,Object> activityObj = (Map<String,Object>)JSON.deserializeUntyped(activityFields);
        Map<String,Object> caseObj = (Map<String,Object>)JSON.deserializeUntyped(caseFields);
        
        System.debug('templateName ->' + templateName); 
        List<wrts_prcgvr__Activity__c> activitiesToInsert = null;
        
        if(templateName!=null){
            activitiesToInsert = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateNameBulk(new List<String>{caseId}, templateName);
            for(wrts_prcgvr__Activity__c activity : activitiesToInsert){
                activity.wrts_prcgvr__IsRequired__c=true;
                if(JSON.deserializeUntyped(activityFields)!= null){
                    activity.AppointmentCode__c = (String) activityObj.get('appointmentCode');
                    activity.JobCenterCode__c = (String) activityObj.get('jobCenterCode');
                    activity.SotCode__c = (String) activityObj.get('sotCode');
                    activity.StartAppointment__c = Date.parse((String) activityObj.get('startAppointment'));
                    activity.EndAppointment__c = Date.parse((String) activityObj.get('endAppointment'));
                }
            }
        }
        
        if(JSON.deserializeUntyped(caseFields)!=null){
            Case theCase = [SELECT Id FROM Case WHERE Id =:caseId];
            if(theCase!=null){
                System.debug('theCase ->' + theCase);
                if((String) caseObj.get('appointmentCode') !=null)  theCase.AppointmentCode__c = (String) caseObj.get('appointmentCode');
                if((String) caseObj.get('jobCenterCode') !=null) theCase.JobCenterCode__c = (String) caseObj.get('jobCenterCode');
                if((String) caseObj.get('sotCode') !=null) theCase.SotCode__c = (String) caseObj.get('sotCode');
                if((String) caseObj.get('startAppointment') != null) theCase.StartAppointment__c = Date.parse((String) caseObj.get('startAppointment'));
                if((String) caseObj.get('endAppointment') != null) theCase.EndAppointment__c = Date.parse((String) caseObj.get('endAppointment'));
                if((String) caseObj.get('phase') != null) theCase.Phase__c = (String) caseObj.get('phase');
                if((String) caseObj.get('note') != null) theCase.Note__c = (String) caseObj.get('note');
                if((String) caseObj.get('outcome') != null) theCase.Outcome__c = (String) caseObj.get('outcome');
                
                HDT_UTL_DatabaseService.updateSObject(theCase);
            }
        }

        if(activitiesToInsert?.size()>0){
            System.debug('activitiesToInsert.size ->' + activitiesToInsert.size());
            HDT_UTL_DatabaseService.insertSObject(activitiesToInsert);
        }
    }

    @AuraEnabled
    public static void updateCase(List<Case> cases){ 
        if(cases?.size()>0){
            System.debug('cases.size ->' + cases.size());
            HDT_UTL_DatabaseService.insertSObject(cases);
        }
    }

    public static HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento initAppointmentRequestCase(Id caseId,requestType requestMethod){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento();
        Case caso = HDT_UTL_AppointmentAgenda.getCase(caseId,FIELDS_FOR_QUERY_CASE);
        appointment.documentkey = 'test';
        appointment.rifRich = 'test';
        String modApp = 'test';
        String codApp = 'test';
        String codFlusso = '0160';
        String esito = 'test';
        //String stato = 'test';
        
        appointment.codFlusso = codFlusso;
        appointment.modApp = modApp;
        appointment.codiceApp = codApp;
        appointment.desEsitoAttivita = esito;
        appointment.self = '';
        return appointment;
    }

}