global with sharing class HDT_SRV_BillingRefundsServiceOne implements wrts_prcgvr.Interfaces_1_0.IApexCalloutAction{
    final HDT_QR_Contract qrContract=new HDT_QR_Contract();
    final HDT_QR_Account qrAccount=new HDT_QR_Account();
    global Object execute(Object args){
        wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse responseReturn = new wrts_prcgvr.ApexActionIntegration_1_0.CalloutResponse();
        Map<String,Object> argsMap = (Map<String,Object>) args;
        String method = (String) argsMap.get('method');
        Case caseToSend = (Case) argsMap.get('sender');
        if(method=='practicalescapes'){
            List<Contract> contr=qrContract.getRecordById(caseToSend.Contract__c);
            Account acc=qrAccount.getRecordById(caseToSend.AccountId,'CompanyOwner__c');
            try{
                HDT_WS_ArrichmentDataEntityResponse resp=callServiceOne(new Map<String,Object>{'processCase'=>caseToSend,'api'=>method,'account'=>acc,'contract'=>contr[0]});
                responseReturn.success = true;
                responseReturn.message = resp.statusCode==200 ? 'OK':'KO';
                caseToSend.TecnicalPhase__c = resp.statusCode==200 ? Label.phaseInviataASap:Label.phaseNonInviataASap;
                update caseToSend;
            }catch (Exception e){
                responseReturn.success=true;
                responseReturn.message=e.getMessage();
                caseToSend.TecnicalPhase__c=Label.phaseNonInviataASap;
                update caseToSend;
            }
        }
        return responseReturn;
    }

    public HDT_WS_ArrichmentDataEntityResponse callServiceOne(Map<String,Object> params){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:MulesoftBasePath/practical-escapes');
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Content-Type','application/json');
        request.setBody(JSON.serialize(new ServiceOneRequest((Case)params.get('processCase'),(Contract)params.get('contract'),(Account)params.get('account'))));
        HttpResponse response = http.send(request);
        HDT_WS_ArrichmentDataEntityResponse responseSerialized=(HDT_WS_ArrichmentDataEntityResponse)JSON.deserialize(response.getBody(),HDT_WS_ArrichmentDataEntityResponse.class);
        responseSerialized.statusCode=response.getStatusCode();
        return responseSerialized;
    }

    public class ServiceOneRequest{
        public String company;
        public String caseNumber;
        public String caseId;
        public String sapContract;
        public String status;
        public String reading;
        public String readingDate;
        public ServiceOneRequest (){}
        public ServiceOneRequest(Case c,Contract contr,Account acc){
            company=getCompanyCode(acc.CompanyOwner__c);
            caseNumber=c.CaseNumber;
            caseId=c.Id;
            sapContract=contr.SAPContractCode__c;
            status='01';
            reading=c.AbnormalReading__c;
            readingDate=c.AbnormalReadingDate__c != null ? String.valueOf(c.AbnormalReadingDate__c) : '';
        }
        private String getCompanyCode(String companyOwner){
            String company='';
            switch on companyOwner{
                when 'HERA COMM'{
                    company='HeraCompany_5010';
                }
                when 'AAA-EBT'{
                    company='HeraCompany_7010';
                }
                when 'MMS'{
                    company='HeraCompany_8060';
                }
                when else {
                    throw new IllegalArgumentException('Company:'+companyOwner+' is not valid');
                }
            }
            HDT_HeraCompany__mdt matrixCompanyCode = HDT_HeraCompany__mdt.getInstance(company);
            return matrixCompanyCode.CompanyCode__c;
        }
    }
}