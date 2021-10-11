@isTest
public class HDT_LC_ComposeBodyResponseTst {
    
    @TestSetup
    static void setup(){
        
        HDT_UTL_DataFactoryTst.pClickCasePhase();

        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        List<Order> ordList = HDT_UTL_DataFactoryTst.createOrder(1, true, accList[0].id, 'Bozza');
        List<ServicePoint__c> servPointList = HDT_UTL_DataFactoryTst.createServicePoint(1, true);
        List<Contact> contactList = HDT_UTL_DataFactoryTst.createContact(1, true, accList[0].id);
        List<BillingProfile__c> billingProfileList = HDT_UTL_DataFactoryTst.createBillingProfile(1,true, accList[0].Id);
        List<Contract> contractList = HDT_UTL_DataFactoryTst.createContract(1, true, accList[0].id);
        
        List<Case> caseList = HDT_UTL_DataFactoryTst.createCase(2, false, accList[0].id, contactList[0].Id, servPointList[0].id, contractList[0].id, ordList[0].id);
        caseList[0].BillingProfile__c = billingProfileList[0].Id;
        // caseList[0].QuotationValidityDate__c = Date.today()-5;
        // caseList[0].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        // caseList[0].Phase__c  = 'Inviata a SAP';
        caseList[0].Type  = 'Autolettura da cliente';

        caseList[1].BillingProfile__c = billingProfileList[0].Id;
        // caseList[1].QuotationValidityDate__c = Date.today()-5;
        // caseList[1].RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        // caseList[1].Phase__c  = 'Inviata a SAP';
        // caseList[1].Type  = 'Autolettura da cliente';
        caseList[1].ComplaintBodyResponse__c  = '<p>prova</p>';
    
        insert caseList;
        
        // HDT_UTL_Constants constantsUtl = new HDT_UTL_Constants();
        // String rtName = 'HDT_RT_Autolettura';
        // String rtId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        
        // HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Inviata a SAP', 'Bozza', rtId, rtName,'A','','','');
        // HDT_UTL_DataFactoryTst.createPhaseTransition(true, 'Esito KO da SAP simulato', 'Inviata a SAP', rtId, rtName,'A','','','');

    }

    @IsTest
    static void testBuildResponse(){

        String template = '<p style="text-align: justify;"><span style="font-size: 10pt; font-family: Arial, sans-serif;">Gentile Avv/Dott/Sig…, </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">(da omettere se l’intestazione si inserisce tramite S.Co.Re.)</i></p><p style="text-align: justify;"><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">come anticipato telefonicamente il ….., la informiamo che per il punto di fornitura di Energia Elettrica n….- identificato dal POD ….di Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo</i><span style="font-size: 10pt; font-family: ArialMTStd;">), non possiamo applicare l’opzione tariffaria prevista per le abitazioni di residenza</span></p><p><br></p><p><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">Stesso indirizzo, stessa unità immobiliare con due contatori</b></p><p><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto ci risulta che sia a lei intestato sempre con tariffa residente il contratto n…….in Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo) </i><span style="font-size: 10pt; font-family: Arial, sans-serif;">servito dal POD…..</span></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">Nel rispetto delle normative vigenti, presso una medesima unità abitativa non possono essere presenti due punti di prelievo con tariffa domestico residente.</span></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">In tal senso se si mantengono attivi due punti di prelievo uno potrà essere ad uso domestico, residente o non residente, mentre per l’altro dovrà esser richiesta la modifica ad uso non domestico. In alternativa, potrà essere richiesto, se necessario, l’aumento di potenza per uno dei due punti di prelievo e disattivato, e se si desidera rimosso, l’altro punto di prelievo.</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> La invitiamo cortesemente a</span><span style="font-size: 10pt; font-family: Arial, sans-serif;"> procedere al pagamento della bolletta n…..per la quale abbiamo bloccato la messa in mora fino al……..</span></p><p style="text-align: justify;"><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">Stesso indirizzo, due unità immobiliari allo stesso indirizzo: è necessario che specifichi dove è residente e dove non lo è</b></p><p><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto ci risulta che sia a lei intestato sempre con tariffa residente il contratto n…….in Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo) </i><span style="font-size: 10pt; font-family: Arial, sans-serif;">servito dal POD…..</span></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">Le chiediamo cortesemente di precisare se si tratta di due unità immobiliari distinte ed in quale quindi è effettivamente residente e da che data e se nell’altro indirizzo lo è stato e in quale periodo</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> In attesa delle precisazioni richieste, </span><span style="font-size: 10pt; font-family: Arial, sans-serif;">abbiamo bloccato la messa in mora della bolletta n….. fino al……..</span></p><p style="text-align: justify;"><br></p><p><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">Due indirizzi diversi, due unità immobiliari ad indirizzi diversi: è necessario che specifichi dove è residente e dove non lo è</b></p><p><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto ci risulta che sia a lei intestato sempre con tariffa residente il contratto n…….in Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo) </i><span style="font-size: 10pt; font-family: Arial, sans-serif;">servito dal POD…..</span></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">Le chiediamo cortesemente di precisare in quale indirizzo è effettivamente residente e da che data e se nell’altro indirizzo lo è stato e in quale periodo</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> In attesa delle precisazioni richieste, </span><span style="font-size: 10pt; font-family: Arial, sans-serif;">abbiamo bloccato la messa in mora della bolletta n….. fino al……..</span></p><p style="text-align: justify;"><br></p><p style="text-align: justify;"><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">caso forze armate: se ha solo il domicilio non può avere la tariffa residente</b></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto lei stesso ci precisa di aver solo il domicilio a quell’indirizzo.</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> La invitiamo cortesemente a</span><span style="font-size: 10pt; font-family: Arial, sans-serif;"> procedere al pagamento della bolletta n…..per la quale abbiamo bloccato la messa in mora fino al……..</span></p><p><br></p><p style="text-align: justify;"><br></p><p style="text-align: justify;"><br></p><p style="text-align: justify;"><br></p><p><span style="font-size: 10pt; font-family: Arial, sans-serif;">Per qualsiasi ulteriore chiarimento, rimaniamo a disposizione ai riferimenti sottoindicati.</span></p>';

        String currentTemplate = '';

        List<String> templates = new List<String>();
        List<String> currentTemplates = new List<String>();

        templates.add(template);
        currentTemplates.add(currentTemplate);

        Case cs = [SELECT Id FROM Case WHERE Type  = 'Autolettura da cliente' LIMIT 1];
        
        Test.startTest();

        HDT_LC_ComposeBodyResponse.buildResponse(templates, currentTemplates, cs.Id, true);

        Case updatedCase = [SELECT Id, ComplaintBodyResponse__c FROM Case WHERE Id =: cs.Id LIMIT 1];
        System.assertEquals(null, updatedCase.ComplaintBodyResponse__c, 'ComplaintBodyResponse__c != null');

        Test.stopTest();
        
    }

    @IsTest
    static void testBuildResponseWithComplaintBodyResponse(){

        String template = '<p style="text-align: justify;"><span style="font-size: 10pt; font-family: Arial, sans-serif;">Gentile Avv/Dott/Sig…, </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">(da omettere se l’intestazione si inserisce tramite S.Co.Re.)</i></p><p style="text-align: justify;"><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">come anticipato telefonicamente il ….., la informiamo che per il punto di fornitura di Energia Elettrica n….- identificato dal POD ….di Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo</i><span style="font-size: 10pt; font-family: ArialMTStd;">), non possiamo applicare l’opzione tariffaria prevista per le abitazioni di residenza</span></p><p><br></p><p><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">Stesso indirizzo, stessa unità immobiliare con due contatori</b></p><p><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto ci risulta che sia a lei intestato sempre con tariffa residente il contratto n…….in Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo) </i><span style="font-size: 10pt; font-family: Arial, sans-serif;">servito dal POD…..</span></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">Nel rispetto delle normative vigenti, presso una medesima unità abitativa non possono essere presenti due punti di prelievo con tariffa domestico residente.</span></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">In tal senso se si mantengono attivi due punti di prelievo uno potrà essere ad uso domestico, residente o non residente, mentre per l’altro dovrà esser richiesta la modifica ad uso non domestico. In alternativa, potrà essere richiesto, se necessario, l’aumento di potenza per uno dei due punti di prelievo e disattivato, e se si desidera rimosso, l’altro punto di prelievo.</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> La invitiamo cortesemente a</span><span style="font-size: 10pt; font-family: Arial, sans-serif;"> procedere al pagamento della bolletta n…..per la quale abbiamo bloccato la messa in mora fino al……..</span></p><p style="text-align: justify;"><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">Stesso indirizzo, due unità immobiliari allo stesso indirizzo: è necessario che specifichi dove è residente e dove non lo è</b></p><p><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto ci risulta che sia a lei intestato sempre con tariffa residente il contratto n…….in Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo) </i><span style="font-size: 10pt; font-family: Arial, sans-serif;">servito dal POD…..</span></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">Le chiediamo cortesemente di precisare se si tratta di due unità immobiliari distinte ed in quale quindi è effettivamente residente e da che data e se nell’altro indirizzo lo è stato e in quale periodo</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> In attesa delle precisazioni richieste, </span><span style="font-size: 10pt; font-family: Arial, sans-serif;">abbiamo bloccato la messa in mora della bolletta n….. fino al……..</span></p><p style="text-align: justify;"><br></p><p><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">Due indirizzi diversi, due unità immobiliari ad indirizzi diversi: è necessario che specifichi dove è residente e dove non lo è</b></p><p><br></p><p><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto ci risulta che sia a lei intestato sempre con tariffa residente il contratto n…….in Via </span><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">….(Indirizzo completo) </i><span style="font-size: 10pt; font-family: Arial, sans-serif;">servito dal POD…..</span></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">Le chiediamo cortesemente di precisare in quale indirizzo è effettivamente residente e da che data e se nell’altro indirizzo lo è stato e in quale periodo</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> In attesa delle precisazioni richieste, </span><span style="font-size: 10pt; font-family: Arial, sans-serif;">abbiamo bloccato la messa in mora della bolletta n….. fino al……..</span></p><p style="text-align: justify;"><br></p><p style="text-align: justify;"><br></p><p><b style="font-size: 12pt; color: rgb(178, 178, 178);">caso forze armate: se ha solo il domicilio non può avere la tariffa residente</b></p><p><br></p><p style="text-align: justify;"><span style="font-size: 10pt; font-family: ArialMTStd;">in quanto lei stesso ci precisa di aver solo il domicilio a quell’indirizzo.</span></p><p style="text-align: justify;"><i style="font-size: 10pt; font-family: Arial, sans-serif; color: rgb(68, 114, 196);">Aggiungere se necessario</i><span style="font-size: 10pt; font-family: ArialMTStd;"> </span><span style="font-size: 10pt; font-family: Wingdings;">à</span><span style="font-size: 10pt; font-family: ArialMTStd;"> La invitiamo cortesemente a</span><span style="font-size: 10pt; font-family: Arial, sans-serif;"> procedere al pagamento della bolletta n…..per la quale abbiamo bloccato la messa in mora fino al……..</span></p><p><br></p><p style="text-align: justify;"><br></p><p style="text-align: justify;"><br></p><p style="text-align: justify;"><br></p><p><span style="font-size: 10pt; font-family: Arial, sans-serif;">Per qualsiasi ulteriore chiarimento, rimaniamo a disposizione ai riferimenti sottoindicati.</span></p>';

        String currentTemplate = '';

        List<String> templates = new List<String>();
        List<String> currentTemplates = new List<String>();

        templates.add(template);
        currentTemplates.add(currentTemplate);

        Case cs = [SELECT Id FROM Case WHERE Type <> 'Autolettura da cliente' LIMIT 1];
        
        Test.startTest();

        HDT_LC_ComposeBodyResponse.buildResponse(templates, currentTemplates, cs.Id, false);

        String expectedValue = '<p>prova</p>' + template;

        Case updatedCase = [SELECT Id, ComplaintBodyResponse__c FROM Case WHERE Id =: cs.Id LIMIT 1];
        System.assertEquals(expectedValue, updatedCase.ComplaintBodyResponse__c, 'ComplaintBodyResponse__c != expectedValue');

        Test.stopTest();
        
    }

    @IsTest
    static void testUpdateResponse(){

        Case cs = [SELECT Id FROM Case WHERE Type  = 'Autolettura da cliente' LIMIT 1];
        String fieldValue = '<p>prova</p>';
        
        Test.startTest();
        
        String result = HDT_LC_ComposeBodyResponse.updateResponse(fieldValue, cs.Id);

        System.assertEquals(null, result, 'result != null');

        Case updatedCase = [SELECT Id, ComplaintBodyResponse__c FROM Case WHERE Id =: cs.Id LIMIT 1];
        System.assertEquals(fieldValue, updatedCase.ComplaintBodyResponse__c, 'ComplaintBodyResponse__c != fieldValue');

        Test.stopTest();
        
    }

    @IsTest
    static void testStripHtmlTags(){

        String inputHtml = '<p>prova</p>';
        
        Test.startTest();

        String result = HDT_LC_ComposeBodyResponse.stripHtml(inputHtml);

        System.assertEquals('prova', result, 'result != prova');

        Test.stopTest();
        
    }

}
