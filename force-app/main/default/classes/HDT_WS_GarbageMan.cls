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
    private static final String CF_REG ='^[A-Za-z]{6}[0-9]{2}[abcdehlmprstABCDEHLMPRST]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$';
    private static final Pattern CF_PATTERN = Pattern.compile(CF_REG);

    //public HDT_WS_GarbageMan(){}
    
    @TestVisible
    private class HDT_WRP_WasteDisposalRequest extends HDT_WS_Request{

        private String phoneNumber {get;set;}
        private String fiscalCode {get;set;}
        private String clientTypology {get;set;}
        private String contactName {get;set;}
        private String streetCode {get;set;}
        private String city {get;set;}
        private String street {get;set;}
        private String streetNumber {get;set;}
        private String province {get;set;}
        private String cap {get;set;}
        private String typeInt {get;set;}
        private String requestCode {get;set;}
        private String materialDescription {get;set;}
    }

    global class HDT_WRP_WasteDisposalResponse extends HDT_WS_Response{
        
        @TestVisible 
        private List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}

        @TestVisible 
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
            checkRequest(request);
            
            Account account;
            List<Account> accounts = qrAccount.getAccountByFiscalCode(request.fiscalCode);
            if(!accounts.isEmpty()){
                account = accounts[0];
            }
            
            Case theCase = utlGarbage.initCase(account);
            theCase.WasterCode__c = request.requestCode;
            theCase.description = request.materialDescription;

            theCase.TypeOperation__c = request.typeInt;
            theCase.ClientTypology__c = request.clientTypology;
            theCase.MaterialDescription__c = request.materialDescription;
            theCase.Description = request.materialDescription;
            //theCase.AlternativeAddress__c = request.city + ' ' + request.street + ' ' + request.streetNumber + ' ' + request.streetCode;
            theCase.InvoicingCity__c = request.city;
            theCase.CompanyOwner__c = utlGarbage.getCompanyOwnerFromCityData(request.city);
            theCase.InvoicingStreetName__c =request.street;
            theCase.InvoicingStreetNumber__c = request.streetNumber;
            theCase.InvoicingStreetCode__c = request.streetCode;
            theCase.InvoicingProvince__c=request.province;
            theCase.InvoicingPostalCode__c=request.cap;         
            theCase.InvoicingCountry__c = 'Italia';
            if(STRING.isBlank(account?.CustomerCode__c)){
                theCase.DifferentNameFromTheApplicant__c = request.contactName;
                //theCase.FiscalCode__c = request.fiscalCode;
            }
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
            /*RestContext.response.statusCode=400;
            RestContext.response.headers.put('Content-Type', 'application/json');*/
        }

        return new HDT_WRP_WasteDisposalResponse('N',null, request.requestCode, null);
    }

    @SuppressWarnings('PMD.CyclomaticComplexity')
    private static void checkRequest(HDT_WRP_WasteDisposalRequest request){
        if(
            STRING.isBlank(request.requestCode)
            || STRING.isBlank(request.streetCode)
            || !( STRING.isBlank(request.fiscalCode) || CF_PATTERN.matcher(request.fiscalCode).matches() )
            || STRING.isBlank(request.contactName)
            || STRING.isBlank(request.city)
            || STRING.isBlank(request.street)
            || STRING.isBlank(request.typeInt)
        ){
            throw new HDT_UTL_HeraException('incomplete data');
        }
    }

    @TestVisible
    private static String getPhoneNumber(HDT_WRP_WasteDisposalRequest request, Account acc){
        if(STRING.isNotBlank(request.phoneNumber))  return request.phoneNumber;
        if(STRING.isNotBlank(acc?.Phone))  return acc.Phone;
        if(STRING.isNotBlank(acc?.MobilePhone__c))  return acc.MobilePhone__c;
        if(STRING.isNotBlank(acc?.OtherPhone__c))  return acc.OtherPhone__c;
        return '';
    }

}
