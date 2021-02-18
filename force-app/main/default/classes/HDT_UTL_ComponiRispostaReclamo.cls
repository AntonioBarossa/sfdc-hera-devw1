public without sharing class HDT_UTL_ComponiRispostaReclamo {

    /*@AuraEnabled(Cacheable = false)
    public static void buildRisposta(List<String> templates, String recordId, Boolean deleteAll){

        Case c = [SELECT evr_CorpoRispostaReclamo__c FROM Case WHERE Id = :recordId LIMIT 1];

        if(c.evr_CorpoRispostaReclamo__c == null || deleteAll == true){

            c.evr_CorpoRispostaReclamo__c = '';

            if(deleteAll == true){

                update c;

                return;

            }

        }

       
        for(String template : templates){

            c.evr_CorpoRispostaReclamo__c += template + '\n';

        }

        update c;

        return;

    }



    @InvocableMethod(label = 'Componi Risposta Recalmo')
    public static void buildRispostaReclam(List<FlowInputs> inputs){

        Case c = [SELECT evr_TemplateRisposte__c, evr_TemplateRiposteArgomento__c, evr_CorpoRispostaReclamo__c FROM Case WHERE Id = :inputs[0].caseId];

        List<String> templateRisposta = new List<String>();
        List<String> templateRispostaArgomento = new List<String>();


        if(c.evr_CorpoRispostaReclamo__c != ''){
            
            c.evr_CorpoRispostaReclamo__c += '\n';
            
        }

        templateRisposta = c.evr_TemplateRisposte__c.split(';');
        templateRispostaArgomento = c.evr_TemplateRiposteArgomento__c.split(';');

        List<evr_TemplateRisposta__c> templates = [SELECT evr_CorpoRispostaReclamo__c 
        FROM evr_TemplateRisposta__c 
        WHERE 
        Name IN :templateRisposta
        OR
        Name IN :templateRispostaArgomento ];

        for(evr_TemplateRisposta__c template : templates){

            c.evr_CorpoRispostaReclamo__c += template.evr_CorpoRispostaReclamo__c + '\n';

        }*/

        //String caseContenutiIdString = inputs[0].caseContenutiId.replace(' ',''); 

        //List<String> caseContenutiId = caseContenutiIdString.split(';');


        /*caseContenuti = [SELECT evr_TemplateRisposte__c, evr_TemplateRiposteArgomento__c, evr_CorpoRispostaReclamo__c 
        FROM Case 
        WHERE Id IN :caseContenutiId];

        for(Case cc : caseContenuti){

            List<Case> listCase = new List<Case>();

            listCase.add(cc);

            caseContenutiReturn.add(listCase);

            listCase.clear();

        }

        /*if(inputs[0].isContenitore == true){

            String caseContenutiIdString = inputs[0].caseContenutiId.replace(' ',''); 

            List<String> caseContenutiId = caseContenutiIdString.split(';');

            caseContenuti = [SELECT evr_TemplateRisposte__c, evr_TemplateRiposteArgomento__c, evr_CorpoRispostaReclamo__c 
            FROM Case 
            WHERE Id IN :caseContenutiId];

            for(Case cc : caseContenuti){

                //cc.evr_TemplateRisposte__c = c.evr_TemplateRisposte__c;
                //cc.evr_TemplateRiposteArgomento__c = c.evr_TemplateRiposteArgomento__c;
                cc.evr_CorpoRispostaReclamo__c = c.evr_CorpoRispostaReclamo__c;

            }

        }*/

        //caseContenuti.add(c);

        //update c;

        //return;

   //}

    public class FlowInputs{

        @InvocableVariable
        public String caseId;

        @InvocableVariable
        public String caseContenutiId;

        @InvocableVariable
        public Boolean isContenitore;

    }

}