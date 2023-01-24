/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 13-01-2023
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidDebugStatements, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList')
@RestResource(urlMapping='/rifiutologo/*')
global with sharing class HDT_WS_GarbageMan {
  
    private static HDT_UTL_GarbageMan utlGarbage = new HDT_UTL_GarbageMan();
    private static HDT_QR_Account qrAccount = new HDT_QR_Account();

    //public HDT_WS_GarbageMan(){}
    
    private class HDT_WRP_WasteDisposalRequest extends HDT_WS_Request{

        private String phoneNumber {get;set;}
        private String fiscalCode {get;set;}
        private String clientTypology {get;set;}
        private String contactName {get;set;}
        private String streetCode {get;set;}
        private String city {get;set;}
        private String street {get;set;}
        private String streetNumber {get;set;}
        private String typeInt {get;set;}
        private String requestCode {get;set;}
        private String materialDescription {get;set;}
    }

    global class HDT_WRP_WasteDisposalResponse extends HDT_WS_Response{

        private List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        private String requestInCharge {get;set;}
        private Datetime createdDate {get;set;}
        private String requestCode {get;set;}
        private String codeRds {get;set;}

        global HDT_WRP_WasteDisposalResponse(){
            return;
        }

        public HDT_WRP_WasteDisposalResponse(String requestInCharge, Datetime createdDate, String requestCode, String codeRds){
            this.requestInCharge = requestInCharge;
            this.createdDate = createdDate;
            this.requestCode = requestCode;
            this.codeRds = codeRds;
        }
    }

    @HttpPost
    global static HDT_WRP_WasteDisposalResponse handleWasteDisposalFromApp(){
        
        String body = RestContext.request.requestBody.toString();
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_GarbageMan input body: ' + body);

        HDT_WRP_WasteDisposalRequest request = (HDT_WRP_WasteDisposalRequest) JSON.deserialize(body,HDT_WRP_WasteDisposalRequest.Class);
        
        try{
            if(STRING.isBlank(request.requestCode)){    throw new HDT_UTL_HeraException('wasterCode blank');    }
            Account account;
            List<Account> accounts = qrAccount.getAccountByFiscalCode(request.fiscalCode);
            if(!accounts.isEmpty()){
                account = accounts[0];
            }
            
            Case theCase = utlGarbage.initCase(account);
            theCase.WasterCode__c = request.requestCode;
            theCase.description = request.materialDescription;

            theCase.TypeOperation__c = request.typeInt;
            theCase.MaterialDescription__c = request.materialDescription;
            theCase.Description = request.materialDescription;
            theCase.AlternativeAddress__c = request.city + request.street + request.streetNumber + request.streetCode;
            theCase.InvoicingCity__c = request.city;
            theCase.InvoicingStreetName__c =request.street;
            theCase.InvoicingStreetNumber__c = request.streetNumber;
            theCase.InvoicingStreetCode__c = request.streetCode;
            theCase.InvoicingCountry__c = 'Italia';
            theCase.PhoneNumber__c = getPhoneNumber(request, account);

            Database.SaveResult isCaseInserted = Database.insert(theCase, false);
            if (isCaseInserted.isSuccess()){
                if(!Test.isRunningTest())    HDT_SRV_GarbageMan.scheduleAppointment(theCase.Id);
                Case insertedCase = utlGarbage.getCurrentCase(theCase.Id)[0];
                return new HDT_WRP_WasteDisposalResponse('Y',insertedCase.CreatedDate, request.requestCode, insertedCase.Id);
            }else{
                for(Database.Error err : isCaseInserted.getErrors()) {
                    System.debug(LoggingLevel.ERROR, 'The following error has occurred.');                    
                    System.debug(LoggingLevel.ERROR, err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(LoggingLevel.ERROR, 'Case fields that affected this error: ' + err.getFields());
                }
            }

        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'HDT_WS_GarbageMan Error ' + e.getMessage());
            RestContext.response.statusCode=400;
            RestContext.response.headers.put('Content-Type', 'application/json');
        }

        return new HDT_WRP_WasteDisposalResponse('N',null, request.requestCode, null);
    }

    private static String getPhoneNumber(HDT_WRP_WasteDisposalRequest request, Account acc){
        if(STRING.isNotBlank(request.phoneNumber))  return request.phoneNumber;
        if(STRING.isNotBlank(acc?.Phone))  return acc.Phone;
        if(STRING.isNotBlank(acc?.MobilePhone__c))  return acc.MobilePhone__c;
        if(STRING.isNotBlank(acc?.OtherPhone__c))  return acc.OtherPhone__c;
        return '';
    }

}
