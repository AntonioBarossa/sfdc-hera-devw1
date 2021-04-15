public inherited sharing class HDT_UTL_CheckDocumentSelected {

    @InvocableMethod(label = 'Controlla Documenti a Credito/Debito')
    public static List<String> checkCreditDebit(List<HDT_UTL_FlowInputs> inputs){

        List<String> returnValue = new List<String>();

        String caseId = inputs[0].caseId;

        Boolean flagCredito = false;

        Boolean flagDebito = false;

        for(DocumentSelected__c doc : [SELECT Residue__c FROM DocumentSelected__c WHERE Case__c = :caseId WITH SECURITY_ENFORCED]){

            if(doc.Residue__c < 0){

                flagCredito = true;

            } else if(doc.Residue__c > 0){

                flagDebito = true;

            }
        }

        System.debug(flagCredito);

        System.debug(flagDebito);
        
        if(flagDebito==true && flagCredito==true){

            returnValue.add('OK');

            return returnValue;

        } else {

            returnValue.add('KO');

            return returnValue;

        }
    }


    public class HDT_UTL_FlowInputs{

        @InvocableVariable
        public String caseId;

  }

}