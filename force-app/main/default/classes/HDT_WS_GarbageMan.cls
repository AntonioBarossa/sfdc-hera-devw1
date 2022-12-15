/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 15-12-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidDebugStatements, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList')
@RestResource(urlMapping='/rifiutologo/*')
global with sharing class HDT_WS_GarbageMan {
  
    private static HDT_UTL_GarbageMan utlGarbage = new HDT_UTL_GarbageMan();
    private static HDT_QR_Account qrAccount = new HDT_QR_Account();

    //public HDT_WS_GarbageMan(){}
    
    public class HDT_WRP_WasteDisposalRequest extends HDT_WS_Request{

        public String phoneNumber {get;set;}
        public String fiscalCode {get;set;}
        public String clientTypology {get;set;}
        public String contactName {get;set;}
        public String streetCode {get;set;}
        public String city {get;set;}
        public String street {get;set;}
        public String streetNumber {get;set;}
        public String typeInt {get;set;}
        public String requestCode {get;set;}
        public String materialDescription {get;set;}
    }

    global class HDT_WRP_WasteDisposalResponse extends HDT_WS_Response{

        public List<HDT_WRP_MulesoftResponse.HDT_WRP_ErrorDetails> errorDetails {get;set;}
        public String requestInCharge {get;set;}
        public Datetime createdDate {get;set;}
        public String requestCode {get;set;}
        public String codeRds {get;set;}

        public HDT_WRP_WasteDisposalResponse(){
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
            Account account;
            List<Account> accounts = qrAccount.getAccountByFiscalCode(request.fiscalCode);
            
            Case theCase = new Case();
            theCase.Cluster__c = 'Segnalazioni';
            theCase.OperationGroup__c = 'CONSULTA IL RIFIUTOLOGO';
            theCase.Origin = 'Rifiutologo';
            theCase.WasterCode__c = request.requestCode;
            theCase.description = request.materialDescription;

            if(!accounts.isEmpty()){ //Gestione rifiuti normale

                account = accounts[0];
                List<AccountContactRelation> accContactRels = utlGarbage.getContactRelation(account.Id);
                if(!accContactRels.isEmpty()){
                    theCase.AccountId = account.Id;
                    theCase.CompanyOwner__c = account.CompanyOwner__c;
                    theCase.ContactId = accContactRel.ContactId;
                    theCase.SuppliedEmail = accContactRel.Contact.Email;
                    theCase.SuppliedPhone = accContactRel.Contact.MobilePhone;
                    theCase.BillingCity__c = account.BillingPlace__c;
                }
            }

            theCase.TypeOperation__c = request.typeInt;
            theCase.MaterialDescription__c = request.materialDescription;
            theCase.AlternativeAddress__c = request.city + request.street + request.streetNumber + request.streetCode;
            theCase.InvoicingCity__c = request.city;
            theCase.InvoicingStreetName__c =request.street;
            theCase.InvoicingStreetNumber__c = request.streetNumber;
            theCase.InvoicingStreetCode__c = request.streetCode;
            theCase.InvoicingCountry__c = 'Italia';
            theCase.PhoneNumber__c = getPhoneNumber(request, account);

            
            theCase.Phase__c = 'In Attesa Appuntamento';
            theCase.Status = 'In Lavorazione';

            Database.SaveResult isCaseInserted = Database.insert(theCase, false);
            if (isCaseInserted.isSuccess()){
                if(!Test.isRunningTest())    HDT_SRV_GarbageMan.scheduleAppointment(theCase.Id);
                return new HDT_WRP_WasteDisposalResponse('Y',theCase.CreatedDate, request.requestCode, theCase.Id);
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
