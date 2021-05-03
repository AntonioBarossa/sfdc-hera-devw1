public inherited sharing class HDT_UTL_PostSalesManager{

    HDT_QR_Contract contractQr = new HDT_QR_Contract();


    public void changeCaseValue(Sobject inputCase){

        Case currentCase = (Case) inputCase;

        currentCase.Subject = 'Il metodo ha funzionato';

    }


    public void changeQuotationType(Sobject inputCase){

        Case currentCase = (Case) inputCase;

        System.debug('Amount --> '+currentCase.Amount__c);

        System.debug('Condition--> '+currentCase.Amount__c != null);

        if(currentCase.Amount__c != null){

            System.debug('QuotationType__c before --> '+currentCase.QuotationType__c);

            currentCase.QuotationType__c = 'Predeterminabile';

            System.debug('QuotationType__c after --> '+currentCase.QuotationType__c);

        }

    }

    public void closeContract(Sobject inputCase){

        Case currentCase = (Case) inputCase;
        List<Contract> contractList = new List<Contract>();

        try{

            contractList = contractQr.getRecordById(currentCase.Contract__c);
            contractList[0].Status = 'Cessato';
            HDT_UTL_DatabaseService.updateSObject(contractList);
            
        }catch(Exception e){
            
            System.debug(e.getMessage());

        }


    }


}