/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 15-12-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.AvoidDebugStatements, PMD.EmptyStatementBlock, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList')
@RestResource(urlMapping='/rifiutologo/*')
global with sharing class HDT_WS_GarbageMan {
    
    public HDT_WS_GarbageMan(){}
    
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

        public HDT_WRP_WasteDisposalResponse(){}

        public HDT_WRP_WasteDisposalResponse(String requestInCharge, Datetime createdDate, String requestCode, String codeRds){
            this.requestInCharge = requestInCharge;
            this.createdDate = createdDate;
            this.requestCode = requestCode;
            this.codeRds = codeRds;
        }
    }

    @HttpPost
    global static HDT_WRP_WasteDisposalResponse handleWasteDisposalFromApp(){
        String body = '';
        System.debug(LoggingLevel.DEBUG, 'HDT_WS_GarbageMan input body: ' + body);
        body = RestContext.request.requestBody.toString();
        HDT_WRP_WasteDisposalRequest request = (HDT_WRP_WasteDisposalRequest) JSON.deserialize(body,HDT_WRP_WasteDisposalRequest.Class);
        try{
            Account account = [ SELECT Id 
                                FROM Account 
                                WHERE FiscalCode__c=:request.fiscalCode 
                                WITH SECURITY_ENFORCED 
                                LIMIT 1]; 
            
            Case theCase = new Case();
            theCase.Cluster__c = 'Segnalazioni';
            theCase.OperationGroup__c = 'CONSULTA IL RIFIUTOLOGO';
            theCase.Origin = 'Rifiutologo';
            theCase.WasterCode__c = request.requestCode;
            theCase.description = request.materialDescription;

            if(account!= null){ //Gestione rifiuti normale

                AccountContactRelation accContactRel = [SELECT Id, ContactId
                                                        FROM AccountContactRelation 
                                                        WHERE AccountId =:account.Id
                                                        WITH SECURITY_ENFORCED 
                                                        LIMIT 1];

                theCase.AccountId = account.Id;
                theCase.CompanyOwner__c = accContactRel.Account.CompanyOwner__c;
                theCase.ContactId = accContactRel.ContactId;
                theCase.PhoneNumber__c = accContactRel.Contact.MobilePhone;
                theCase.SuppliedEmail = accContactRel.Contact.Email;
                theCase.SuppliedPhone = accContactRel.Contact.MobilePhone;
                theCase.BillingCity__c = accContactRel.Account.BillingPlace__c;

            }else{ //Gestione rifiuti anonima

                theCase.InvoicingCity__c = request.city;
                theCase.TypeOperation__c = request.typeInt;
                theCase.MaterialDescription__c = request.materialDescription;
                theCase.AlternativeAddress__c = request.city + request.street + request.streetNumber + request.streetCode;
                
            }

            TariAppointment__c tabellaAppuntamento = [  SELECT Id 
                                                        FROM TariAppointment__c
                                                        WHERE City__c = 'CONSULTA IL RIFIUTOLOGO'
                                                        AND TypeOperation__c =:request.typeInt
                                                        WITH SECURITY_ENFORCED 
                                                        LIMIT 1];

            if(tabellaAppuntamento!= null){
                theCase.Phase__c = 'In Attesa Appuntamento';
            }else{
                theCase.Phase__c = 'Da Inviare';
            }

            Boolean isObjInserted = HDT_UTL_DatabaseService.insertSObject(theCase);
            if (isObjInserted){
                HDT_SRV_GarbageMan.HDT_QBL_ScheduleAppointment.scheduleAppointment(theCase.Id);
                return new HDT_WRP_WasteDisposalResponse('Y',theCase.CreatedDate, request.requestCode, theCase.Id);
            }

        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'HDT_WS_GarbageMan Error ' + e.getMessage());
            RestContext.response.statusCode=400;
            RestContext.response.headers.put('Content-Type', 'application/json');
        }

        return new HDT_WRP_WasteDisposalResponse('N',null, request.requestCode, null);
    }

}
