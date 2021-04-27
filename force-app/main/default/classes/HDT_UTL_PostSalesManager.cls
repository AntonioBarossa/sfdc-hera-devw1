public inherited sharing class HDT_UTL_PostSalesManager{


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


}