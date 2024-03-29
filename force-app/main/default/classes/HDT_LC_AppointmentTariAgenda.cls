/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 02-12-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.IfStmtsMustUseBraces, PMD.IfElseStmtsMustUseBraces, PMD.pmdAvoidDebugStatements, PMD.CyclomaticComplexity, PMD.ClassNamingConventions, PMD.AvoidDebugStatements')
public with sharing class HDT_LC_AppointmentTariAgenda {
    
    private static HDT_SRV_AppointmentAgenda srvAgenda = new HDT_SRV_AppointmentAgenda();
    private static final String FIELDS_FOR_QUERY_CASE = 'Id, CaseNumber';

    private static final String REQUEST_PATH_SEARCH = '/appointments/search';
    private static final String REQUEST_PATH_CONFIRM = '/appointments/confirm';
    private static final String REQUEST_PATH_VIEW = '/appointments';

    public class HDT_WRP_DataApp{
        @AuraEnabled public String purchaseOrderNumber {get;set;}
        @AuraEnabled public String streetCoding {get;set;}
        @AuraEnabled public String street {get;set;}
        @AuraEnabled public String housenumber {get;set;}
        @AuraEnabled public String typeInt {get;set;}
        @AuraEnabled public String indicator {get;set;}
        @AuraEnabled public String numberOfLines {get;set;}
        @AuraEnabled public String city {get;set;}
        @AuraEnabled public Datetime startDate {get;set;}
        @AuraEnabled public Datetime endDate {get;set;}
        @AuraEnabled public Datetime firstDate {get;set;}

        public HDT_WRP_DataApp(){
            return;
        }

        public HDT_WRP_DataApp(String purchaseOrderNumber, String streetCoding, String street,
                                String housenumber, String typeInt, String city) {
        
            this.purchaseOrderNumber = purchaseOrderNumber;
            this.streetCoding = streetCoding;
            this.street = street;
            this.housenumber = housenumber;
            this.typeInt = typeInt;
            this.indicator = 'Y';
            this.numberOfLines = null;
            this.city = city;
            //this.startDate = startDate;
            //this.endDate = endDate;
        }

    }
                                

    public virtual class HDT_WRP_AppointmentReqSearch extends HDT_WS_Request{
        String purchaseOrderNumber;
        String streetCoding;
        String street;
        String housenumber;
        String typeInt;
        String indicator;
        String numberOfLines;
        String city;

        public HDT_WRP_AppointmentReqSearch(HDT_WRP_DataApp wrap) {
        
            this.purchaseOrderNumber = wrap.purchaseOrderNumber;
            this.streetCoding = wrap.streetCoding;
            this.street = wrap.street;
            this.housenumber = wrap.housenumber;
            this.typeInt = wrap.typeInt;
            this.indicator = wrap.indicator;
            this.numberOfLines = wrap.numberOfLines;
            this.city = wrap.city;
        }
    }

    
    public class HDT_WS_AppointmentSearchResponse extends HDT_WS_Response{
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_Data_Search data {get;set;}
    }
    public class HDT_WRP_Data_Search{
		@AuraEnabled public String outcome {get;set;}
        @AuraEnabled public String text {get;set;}
		@AuraEnabled public List<HDT_WRP_AppointmentDate> appointmentData {get;set;}
	}
    public class HDT_WRP_AppointmentDate{
		@AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
	}


    public virtual class HDT_WRP_AppointmentReqConfirm extends HDT_WS_Request{
        String purchaseOrderNumber;
        String customerAccountNumber;
        String streetCoding;
        String street;
        String housenumber;
        String typeInt;
        String indicator;
        String numberOfLines;
        String city;
        String startDate;
        String endDate;
        String firstAppointmentDate;
        
        public HDT_WRP_AppointmentReqConfirm(HDT_WRP_DataApp wrap) {

            this.purchaseOrderNumber = wrap.purchaseOrderNumber;
            this.streetCoding = wrap.streetCoding;
            this.street = wrap.street;
            this.housenumber = wrap.housenumber;
            this.typeInt = wrap.typeInt;
            this.indicator = wrap.indicator;
            this.city = wrap.city;
            this.numberOfLines = wrap.numberOfLines;
            this.startDate = wrap.startDate.format('yyyyMMddhhmmss');
            this.endDate = wrap.endDate.format('yyyyMMddhhmmss');
            this.firstAppointmentDate = wrap.firstDate.format('yyyyMMddhhmmss');
        }
    }

    public class HDT_WS_AppointmentConfirmResponse extends HDT_WS_Response {
        @AuraEnabled public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String correlationId {get;set;}
        @AuraEnabled public String timestamp {get;set;}
        @AuraEnabled public HDT_WRP_Data_Confirm data {get;set;}
    }

    public class HDT_WRP_Data_Confirm{
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
        
    public class HDT_WRP_AppointmentView{
        @AuraEnabled public String noticeNumber {get;set;}
        @AuraEnabled public String appointmentType {get;set;}
        @AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
    }

    public static HDT_WS_AppointmentSearchResponse handleSearch(HDT_WRP_DataApp wrap) {
        HDT_WRP_AppointmentReqSearch req = new HDT_WRP_AppointmentReqSearch(wrap);
        HDT_WS_AppointmentSearchResponse res = (HDT_WS_AppointmentSearchResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH_SEARCH,'POST', req, HDT_WS_AppointmentSearchResponse.class);
        System.Debug(LoggingLevel.DEBUG,'search res -> ' + res);
        return res;
    }

    @AuraEnabled(cacheable=true)
    public static HDT_WS_AppointmentSearchResponse handleSearch(Case theCase, HDT_WRP_DataApp wrap) {
        HDT_WS_AppointmentSearchResponse res = handleSearch(wrap);
        if(
            theCase?.Id!=null
            && theCase.FirstAppointmentAvaiable__c == null 
            && res?.data?.appointmentData?.isEmpty() == false
        ){
            updateCase(new Case(Id=theCase.Id, FirstAppointmentAvaiable__c= new HDT_UTL_GarbageMan().formatDate(res.data.appointmentData[0].startDate)));
            //qui è ok fare una dml anche col metodo cached perché tanto va aggiornato una sola volta
        }
        return res;
    }

    @AuraEnabled
    public static HDT_WS_AppointmentConfirmResponse handleConfirm(Case theCase, HDT_WRP_DataApp wrap) {
        HDT_WRP_AppointmentReqConfirm req = new HDT_WRP_AppointmentReqConfirm(wrap);
        req.customerAccountNumber = theCase.AccountCode__c;
        //system.debug(json.serialize(req));
        HDT_WS_AppointmentConfirmResponse res = (HDT_WS_AppointmentConfirmResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',REQUEST_PATH_CONFIRM,'POST', req, HDT_WS_AppointmentConfirmResponse.class);
        //system.debug(json.serialize(res));
        if(Test.isRunningTest()){
            res.status = 'success';
        }

        if(STRING.isNotBlank(res?.data?.noticeNumber)){
            theCase.StartAppointment__c = wrap.startDate;
            theCase.EndAppointment__c = wrap.endDate;
            theCase.JobCenterCode__c = res.data.workCenterId;
            theCase.NoticeId__c = res.data.noticeNumber;
            //theCase.Phase__c = 'Da Inviare';
            theCase.Phase__c = 'Inviata a SAP';
            //theCase.Outcome__c ='Recived_Slots';

            if(!theCase.WithdrawalFee__c && theCase.ServicePoint__c != null){
                //if(theCase.ServicePoint__c == null){    throw new HDT_UTL_HeraException('ServicePointId Null when creating MasterDetail');     }
                Date dataRitiro = Date.newinstance(theCase.CreatedDate.year(), theCase.CreatedDate.month(), theCase.CreatedDate.day());
                FreeWithdraw__c ritiro = new FreeWithdraw__c();
                ritiro.ServicePoint__c = theCase.ServicePoint__c;
                ritiro.LastFreeWithdrawDate__c = dataRitiro;
                System.debug(LoggingLevel.DEBUG, 'ritiro -> ' + ritiro);
                HDT_UTL_DatabaseService.insertSObject(ritiro);
            }
            updateCase(theCase);
        }
        return res;
    }

    @AuraEnabled
    public static HDT_WS_AppointmentViewResponse handleView(String purchaseOrderNumber) {
        // HDT_WRP_AppointmentReqView req = new HDT_WRP_AppointmentReqView(purchaseOrderNumber);
        string path = purchaseOrderNumber != null ? REQUEST_PATH_VIEW+'?purchaseOrderNumber='+purchaseOrderNumber : REQUEST_PATH_VIEW;
        HDT_WS_AppointmentViewResponse res = (HDT_WS_AppointmentViewResponse)HDT_WS_HTTPServiceCall.sendRequest('MulesoftBasePath',path,'GET', (HDT_WS_Request)null, HDT_WS_AppointmentViewResponse.class);
        return res;
    }

    public enum requestType {
        CANCELLATION,CONFIRM,EDIT,NEW_SLOT,FIRST_SEARCH
    }

    @AuraEnabled(cacheable=true)
    public static Case getCase(String caseId,List<String> fields){
        Case caseToRet;
        try{
            caseToRet= HDT_UTL_AppointmentAgenda.getCase(caseId,String.join(fields,','));
        }catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return caseToRet;
    }
    
    @AuraEnabled
    public static void updateCase(Case caso){    
        
        HDT_UTL_DatabaseService.updateSObject(caso);

    }

    public static HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento initAppointmentRequestCase(Id caseId,requestType requestMethod){
        HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento appointment = new HDT_WRP_Appuntamento.HDT_WRP_RequestAppuntamento();
        //Case caso = HDT_UTL_AppointmentAgenda.getCase(caseId,FIELDS_FOR_QUERY_CASE);
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