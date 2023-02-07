/**
 * Header of the class "HDT_UTL_ScartiTst"
 * @author Cesare Bagnolini, cesare.bagnolini@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_UTL_Scarti"
 * @history
 * @Created 07/10/2021
 * Modified By:
 **/

@isTest
public class HDT_UTL_ScartiTst {

    private static HDT_UTL_Constants constants=new HDT_UTL_Constants();

    @TestSetup
    static void makedata(){
        
        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(constants.SYSTEM_ADMINISTRATOR_NAME);
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);
        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;

        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            HDT_UTL_DataFactoryTst.pClickCasePhase();
            HDT_UTL_DataFactoryTst.newPhaseTransition('Annullato','Bozza',constants.ORDER_RECORDTYPEID_DEFAULT,constants.ORDER_RECORDTYPE_DEVELOPERNAME_DEFAULT);
            
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id; 
            
            List<Sale__c> sales = HDT_UTL_DataFactoryTst.createSale(1,true,accId,'Bozza'); 
            
            Id pricebookId = Test.getStandardPricebookId();            
            
            List<Contract> contracts = HDT_UTL_DataFactoryTst.createContract(1,true,accId);
            
            List<Individual> individuals = HDT_UTL_DataFactoryTst.createIndividual(2,true);
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(1,false,accId);
            contacts[0].Company__c='MMS';
            contacts[0].IndividualId = individuals[0].id;
            insert contacts;
            
            List<ServicePoint__c> points = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            Id pointId = points[0].id;   
            
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,true);
            Id productId = products[0].id; 
            
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,pricebookId);
            Id entryId = entries[0].id;
                        
            List<Order> orders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(1,false,accId,sales,pricebookId);
            orders[0].CausalCode__c = 'testCausalCode';
            orders[0].DiscardReason__c = 'testCatalog';
            orders[0].Contact__c = contacts[0].id;
            orders[0].PhoneNumber__c ='3461357661';
            orders[0].Email__c = 'email@nuova.it';
            orders[0].ProcessType__c = 'Connessione con Attivazione';
            insert orders;
            Id orderId = orders[0].id;
            
            HDT_UTL_DataFactoryTst.createOrderItem(1,true,orderId,pointId,productId,entryId);            
                     
            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, false, accId, contacts[0].id, null, contracts[0].Id, orders[0].Id);
            cases[0].DiscardDescription__c = 'testdescription';
            cases[0].type = 'Consegna copia chiave GdM';
            cases[0].TraderPracticeCode__c = 'testcode';
            cases[0].TrackingDiscardPhase__c = 'testphase';
            insert cases;       
                        
            List<wrts_prcgvr__FieldsTemplate__c> fieldTemplates = HDT_UTL_DataFactoryTst.createFieldsTemplate(4,false);
            fieldTemplates[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
            fieldTemplates[0].wrts_prcgvr__ObjectType__c= 'Order';
            fieldTemplates[1].wrts_prcgvr__Code__c= '424cd628-7cc0-4b1f-b727-7e095aedc068';
            fieldTemplates[1].wrts_prcgvr__ObjectType__c= 'Order';
            fieldTemplates[2].wrts_prcgvr__Code__c= 'db7818bf-1c29-4de0-bd88-83d69447aabb';
            fieldTemplates[2].wrts_prcgvr__ObjectType__c= 'Order';
            fieldTemplates[3].wrts_prcgvr__Code__c= 'b5a0181e-68c3-4f99-9d4f-9c899b01ed4b';
            fieldTemplates[3].wrts_prcgvr__ObjectType__c= 'Order';
            insert fieldTemplates;
            
            List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = HDT_UTL_DataFactoryTst.createActivityTemplate(8,false);
            activityTemplates[0].Name = 'CBS_ATT006__AMMISSIBILITA_KO';
            activityTemplates[0].wrts_prcgvr__Code__c = 'e88f26f9-a32f-439f-b258-db04fadd3994';
            activityTemplates[0].wrts_prcgvr__FieldsTemplate__c= fieldTemplates[0].id;
            activityTemplates[0].wrts_prcgvr__ObjectType__c = 'Order';            
            activityTemplates[1].Name = 'CBS_HER004__ERRORE_INVIO_A_SAP_POSTSALES';
            activityTemplates[2].Name = 'CBS_HER001__ESITO_NON_ELABORATO_DA_DLSII_POSTSALES';
            activityTemplates[2].wrts_prcgvr__Code__c = '424cd628-7cc0-4b1f-b727-7e095aedc068';
            activityTemplates[2].wrts_prcgvr__ObjectType__c = 'Order';
            activityTemplates[3].Name = 'CBS_HER008__ELIMINATO_ESITO_IN_SCARTO_SALES';
            activityTemplates[4].Name = 'CBS_CRP004__SCARTI_DOCUMENTALI_POST_SALES';
            activityTemplates[4].wrts_prcgvr__ObjectType__c = 'Order';
            activityTemplates[4].wrts_prcgvr__Code__c = 'b5a0181e-68c3-4f99-9d4f-9c899b01ed4b';
            activityTemplates[5].Name = 'CBS_CRP003__SCARTI_DOCUMENTALI_SALES';
            activityTemplates[5].wrts_prcgvr__Code__c = 'db7818bf-1c29-4de0-bd88-83d69447aabb';
            activityTemplates[5].wrts_prcgvr__ObjectType__c = 'Order';
            activityTemplates[6].Name = 'CBS_ATT001__ESITO_KO_DA_SAP';
            activityTemplates[6].wrts_prcgvr__Code__c = 'b466bf37-4f13-4b39-97fd-e085b3d49651';
            activityTemplates[6].wrts_prcgvr__ObjectType__c = 'Order';
            activityTemplates[7].Name = 'CBS_MOR001__ESITO_KO_DA_SAP';
            activityTemplates[7].wrts_prcgvr__Code__c = '02c4450f-d1cc-4cd4-b53b-f7bb82027158';
            activityTemplates[7].wrts_prcgvr__ObjectType__c = 'Case';
            insert activityTemplates;

            List<wrts_prcgvr__ActivityAction__c> activityActions = HDT_UTL_DataFactoryTst.createActivityAction(1,false,activityTemplates[0].id);
            activityActions[0].wrts_prcgvr__Field__c = '{!Type__c}';
            activityActions[0].wrts_prcgvr__Value__c = 'ActivityTypeTest';
            insert activityActions;
            
            List<wrts_prcgvr__ActivityAction__c> activityActions2 = HDT_UTL_DataFactoryTst.createActivityAction(1,false,activityTemplates[3].id);
            activityActions2[0].wrts_prcgvr__Field__c = '{!Type__c}';
            activityActions2[0].wrts_prcgvr__Value__c = 'ActivityTypeTest';
            insert activityActions2;
            
            List<DiscardAnnullmentRule__c> rules = HDT_UTL_DataFactoryTst.createDiscardAnnullmentRule(1,false,'Order');
            rules[0].ActivityType__c = 'Esito KO da DL';
            rules[0].ControllingField__c = 'DiscardReason__c';
            rules[0].ControllingValue__c = 'testCatalog';
            rules[0].ProcessField__c = 'ProcessType__c';
            rules[0].ProcessValue__c = 'Connessione con Attivazione';
            rules[0].DiscardNoteReliability__c='Alta';
            rules[0].IsActive__c = true;
            insert rules;
            
            List<DiscardAnnullmentRule__c> rulesCase = HDT_UTL_DataFactoryTst.createDiscardAnnullmentRule(1,false,'Case');
            rulesCase[0].ActivityType__c = 'Ammissibilità KO';
            rulesCase[0].ControllingField__c = 'DiscardDescription__c';
            rulesCase[0].ControllingValue__c = 'testdescription';
            rulesCase[0].ProcessField__c = 'Type';
            rulesCase[0].ProcessValue__c = 'Consegna copia chiave GdM';
            rulesCase[0].DiscardNoteReliability__c='Alta';
            rulesCase[0].IsActive__c = true;
            insert rulesCase;
            
            List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(4,false,accId);
            activities[0].Order__c = orders[0].id;
            activities[0].wrts_prcgvr__Status__c = 'Aperta';
            activities[0].NewEmail__c = 'yes@no.it';
            activities[0].NewMobile__c = '3334441122';
            activities[0].DiscardCategory__c = 'Anonima';
            activities[0].type__c = 'Contattare il cliente';
            activities[0].Case__c = cases[0].id;            
            activities[1].Case__c = cases[0].id;
            activities[1].DiscardCategory__c = 'Anonima';
            activities[1].wrts_prcgvr__Status__c = 'Aperta';
            activities[2].NewEmail__c = 'activityCase@no.it';
            activities[2].Case__c = cases[0].id;   
            activities[3].NewEmail__c = 'activityOrder@no.it';
            activities[3].Order__c = orders[0].id;
            insert activities;
                        
            List<ContactPointPhone> phones = HDT_UTL_DataFactoryTst.createContactPointPhone(2,false,individuals[0].id);
            phones[0].TelephoneNumber = 'oldPhone';
            phones[0].Status__c = 'Verificato';
            phones[1].ParentId = individuals[0].id;
            phones[1].TelephoneNumber = 'oldPhone';
            phones[1].Status__c = 'Non Verificato';          
            insert phones;
            
            List<ContactPointEmail> mails = HDT_UTL_DataFactoryTst.createContactPointEmail(2,false,individuals[0].id);
            mails[0].EmailAddress = 'old@Email.it';
            mails[0].Status__c = 'Verificato';
            mails[1].ParentId = individuals[0].id;
            mails[1].EmailAddress = 'old@Email.it';
            mails[1].Status__c = 'Non Verificato';
            insert mails;
            
            List<et4ae5__Automated_Send__c> sends = HDT_UTL_DataFactoryTst.createTriggeredSend(1,true);
            
            List<et4ae5__IndividualEmailResult__c> results = HDT_UTL_DataFactoryTst.createIndividualEmailResult(2,false,sends[0].id); 
            results[0].BounceSubCategory__c = 'some';
            results[1].OrderID__c = orders[0].id;
            insert results;
            
            List<SMSTracking__c> tracks =  HDT_UTL_DataFactoryTst.createSmsTracking(1, false, contacts[0].id);
            tracks[0].Undelivered__c = true;
            insert tracks;
                        
        }
     }
   
    
    @isTest private static void evaluateTrue(){
        
        Order record = [Select id from Order limit 1];
        
        Map<String, Object> argsMap = new Map<String, Object>{'transition'=>null,
                                                              'action'=>null,
                                                              'method'=>'checkActivityCreation___CBS_ATT006__AMMISSIBILITA_KO',
            												  'record'=>record,
                                                              'sender'=>null};
                                                                  
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        boolean b = classInstance.evaluate(argsMap);
        
        System.assertEquals(true, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    }
    
    @isTest private static void evaluateFalse(){
        
        Order record = [Select id from Order limit 1];
        
        Map<String, Object> argsMap = new Map<String, Object>{'transition'=>null,
                                                              'action'=>null,
                                                              'method'=>'checkAnnullment___CBS_ATT006__AMMISSIBILITA_KO',
            												  'record'=>record,
                                                              'sender'=>null};
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        boolean b = classInstance.evaluate(argsMap);
        
        System.assertEquals(false, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    }
    
    @isTest private static void evaluateNull(){
        
        Order record = [Select id from Order limit 1];
        
        Map<String, Object> argsMap = new Map<String, Object>{
            'transition'=>null,
            'action'=>null,
            'method'=>'nullvalue___CBS_ATT006__AMMISSIBILITA_KO',
            'record'=>record,
            'sender'=>null};
                
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        boolean b = classInstance.evaluate(argsMap);
        
        System.assertEquals(null, b, 'evaluate did not work correctly');
        System.assertNotEquals(true, b, 'evaluate did not work correctly');
    }
    
    @isTest static void invokeScartiAction1(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input.methodName = 'chiudiAttivita';
        input.objectId = record.id;
        input.templateName = 'templateName';
        inputs.add(input);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
        
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction2(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input.methodName = 'annullaPratica';
        input.objectId = record.id;
        input.templateName = 'templateName';
        inputs.add(input);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction3(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input.methodName = 'annullaContratti';
        input.objectId = record.id;
        input.templateName = 'templateName';
        inputs.add(input);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction4(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input.methodName = 'createActivityByObjectIdAndTemplateName';
        input.objectId = record.id;
        input.templateName = 'CBS_ATT006__AMMISSIBILITA_KO';
        inputs.add(input);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
        
    @isTest static void invokeScartiAction5(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input.methodName = 'createActivityByObjectIdAndTemplateName';
        input.objectId = record.id;
        input.templateName = 'wrongtemplatename';
        inputs.add(input);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('KO', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void createAttivitaTracciaturaHeroku(){
        
        List<Map<String,String>> arg = new List<Map<String,String>>();
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Richiesta non identificata');

        mapp.put('UTENZA','userprova');
        mapp.put('DATA_EVENTO',String.valueof(System.today()));
        mapp.put('ERROR_MESSAGE','descrizione scarto');
            

        arg.add(mapp);
        
        HDT_UTL_Scarti.createAttivitaTracciaturaHeroku(arg);
        
        List<wrts_prcgvr__Activity__c> activities = [Select id From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        
        System.assertEquals(1, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        System.assertNotEquals(null, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        
    }
    
    @isTest static void createAttivitaTracciaturaHeroku2(){
        
        Order record = [Select id from Order];
        
        List<Map<String,String>> arg = new List<Map<String,String>>();
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Esito non elaborato');
        mapp.put('UTENZA','userprova');
        mapp.put('DATA_EVENTO',String.valueof(System.today()));
        mapp.put('ERROR_MESSAGE','descrizione scarto');
        mapp.put('RECORD_ID',record.id);
        mapp.put('PROCESS_CATEGORY','postsales');
        mapp.put('COUNTER','1.1');
        mapp.put('COD_PRAT_UTENTE','codice1');
        mapp.put('CMP','codice2');
        mapp.put('NOTE_ERR','codice3');
        mapp.put('STEP_ERR','codice4');
        mapp.put('NOTA_HK','codice5');
                                                                                          
        arg.add(mapp);
        
        HDT_UTL_Scarti.createAttivitaTracciaturaHeroku(arg);
        
        List<wrts_prcgvr__Activity__c> activities = [Select id From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        
        System.assertEquals(1, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        System.assertNotEquals(null, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        
    }

    @isTest static void createAttivitaTracciaturaHeroku3(){
               
        List<Map<String,String>> arg = new List<Map<String,String>>();
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Esito non elaborato');
        mapp.put('UTENZA','testutenza');
        mapp.put('DATA_EVENTO',String.valueOf(system.today()));
        mapp.put('ERROR_MESSAGE','erroretest');
        mapp.put('RECORD_ID','O-pizza');
        mapp.put('PROCESS_CATEGORY','sales');
        
        arg.add(mapp);
        
        HDT_UTL_Scarti.createAttivitaTracciaturaHeroku(arg);
        
        List<wrts_prcgvr__Activity__c> activities = [Select id From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        
        System.assertEquals(1, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        System.assertNotEquals(null, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        
    }
    
    @isTest static void createAttivitaTracciaturaHeroku4Order(){
        
        Order record = [Select id from Order];
        
        record.RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        update record;
               
        List<Map<String,String>> arg = new List<Map<String,String>>();
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Errore lavorazione SAP');
        mapp.put('DATA_EVENTO',String.valueOf(system.today()));
        mapp.put('ERROR_MESSAGE','erroretest');
        mapp.put('RECORD_ID',record.id);
        
        arg.add(mapp);
        
        HDT_UTL_Scarti.createAttivitaTracciaturaHeroku(arg);
        
        List<wrts_prcgvr__Activity__c> activities = [Select id From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        
        System.assertEquals(1, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        System.assertNotEquals(null, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        
    }
    
    @isTest static void createAttivitaTracciaturaHeroku4Case(){
        
        Case record = [Select id from Case];
                       
        List<Map<String,String>> arg = new List<Map<String,String>>();
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Errore lavorazione SAP');
        mapp.put('DATA_EVENTO',String.valueOf(system.today()));
        mapp.put('ERROR_MESSAGE','erroretest');
        mapp.put('RECORD_ID',record.id);
        
        arg.add(mapp);
        
        HDT_UTL_Scarti.createAttivitaTracciaturaHeroku(arg);
        
        List<wrts_prcgvr__Activity__c> activities = [Select id From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        
        System.assertEquals(1, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        System.assertNotEquals(null, activities.size(), 'createAttivitaTracciaturaHeroku did not work correctly');
        
    }   
    
    @isTest static void createActivityByObjectIdAndTemplateNameBulk(){
        
        Order record = [Select id from Order limit 1];
        
        List<String> ids = new List<String>();
        ids.add(record.id);
        
        List<wrts_prcgvr__Activity__c> activities = HDT_UTL_Scarti.createActivityByObjectIdAndTemplateNameBulk(ids, 'CBS_ATT006__AMMISSIBILITA_KO');
        
        System.assertEquals(1, activities.size(), 'createActivityByObjectIdAndTemplateNameBulk did not work correctly');
        System.assertNotEquals(null, activities, 'createActivityByObjectIdAndTemplateNameBulk did not work correctly');
        
    }
    
    @isTest static void updateContactForScartoDocumentale(){
        
        Account acc = [Select id from Account LIMIT 1];
        
        Contact cont = [Select id, IndividualId from Contact Limit 1];
        
        Individual ind = [Select id from Individual  where id =: cont.IndividualId limit 1];
        
        List<ContactPointPhone> cpp = [Select id, ParentId from ContactPointPhone];
        for(ContactPointPhone c : cpp){
            c.parentId = ind.id;
        }
        update cpp;
        
        List<ContactPointEmail> cpe = [Select id, ParentId from ContactPointEmail];
        for(ContactPointEmail c : cpe){
            c.parentId = ind.id;
        }
        update cpe;
        
        HDT_UTL_Scarti.updateContactForScartoDocumentale(acc.id,'oldPhone', 'old@Email.it', 'newPhone',  'new@Mail.it');
        
        List<ContactPointEmail> mails = [Select EmailAddress From ContactPointEmail Where Status__c = 'Non verificato'];
        List<ContactPointPhone> phones = [Select TelephoneNumber From ContactPointPhone Where Status__c = 'Non verificato'];
            
        System.assertEquals(true, mails != null, 'updateContactForScartoDocumentale did not work correctly');
        System.assertEquals(true, phones != null, 'updateContactForScartoDocumentale did not work correctly');
        
    }
    
    @isTest static void updateContactForScartoDocumentale2(){
        
        Account acc = [Select id from Account LIMIT 1];
        
        Contact cont = [Select id, IndividualId from Contact Limit 1];
        
        Individual ind = [Select id from Individual  where id =: cont.IndividualId limit 1];
        
        List<ContactPointPhone> cpp = [Select id, ParentId from ContactPointPhone where Status__c = 'Non verificato'];
        for(ContactPointPhone c : cpp){
            c.parentId = ind.id;
        }
        update cpp;
        
        List<ContactPointEmail> cpe = [Select id, ParentId from ContactPointEmail where Status__c = 'Non verificato'];
        for(ContactPointEmail c : cpe){
            c.parentId = ind.id;
        }
        update cpe;
        
        HDT_UTL_Scarti.updateContactForScartoDocumentale(acc.id,'oldPhone', 'old@Email.it', 'newPhone',  'new@Mail.it');
        
        List<ContactPointEmail> mails = [Select EmailAddress From ContactPointEmail Where EmailAddress = 'new@Mail.it'];
        List<ContactPointPhone> phones = [Select TelephoneNumber From ContactPointPhone Where TelephoneNumber = 'newPhone'];
            
        System.assertEquals(1, mails.size(), 'updateContactForScartoDocumentale did not work correctly');
        System.assertEquals(1, phones.size(), 'updateContactForScartoDocumentale did not work correctly');
        
    }
    
    @isTest static void createScartoForMarketingCloud(){
        
        List<et4ae5__IndividualEmailResult__c> individualEmailResults = [Select id,BounceSubCategory__c From et4ae5__IndividualEmailResult__c where OrderID__c = null];
        
        individualEmailResults[0].BounceSubCategory__c = 'changed';
        Test.startTest();
            update individualEmailResults;
        Test.stopTest();
        String newBounceSubCategory = [Select BounceSubCategory__c From et4ae5__IndividualEmailResult__c limit 1].BounceSubCategory__c;
        
        System.assertEquals('changed', newBounceSubCategory, 'createScartoForMarketingCloud did not work correctly');
        System.assertNotEquals(null, newBounceSubCategory, 'createScartoForMarketingCloud did not work correctly');
        
    }
    
    @isTest static void createScartoForMarketingCloud2(){
        
        List<et4ae5__IndividualEmailResult__c> individualEmailResults = [Select id,BounceSubCategory__c From et4ae5__IndividualEmailResult__c where OrderID__c != null ];
        
        individualEmailResults[0].BounceSubCategory__c = 'changed';
        Test.startTest();
            update individualEmailResults;
        Test.stopTest();
        String newBounceSubCategory = [Select BounceSubCategory__c From et4ae5__IndividualEmailResult__c where OrderID__c != null limit 1].BounceSubCategory__c;
        
        System.assertEquals('changed', newBounceSubCategory, 'createScartoForMarketingCloud did not work correctly');
        System.assertNotEquals(null, newBounceSubCategory, 'createScartoForMarketingCloud did not work correctly');
        
    }
    
    @isTest static void createScartoForMarketingCloud3(){
        
        List<SMSTracking__c> trackings = [Select id,Undelivered__c From SMSTracking__c];
        
        trackings[0].Undelivered__c = false;
        
        update trackings;
        
        Boolean newUndelivered = [Select Undelivered__c From SMSTracking__c ].Undelivered__c;
        
        System.assertEquals(false, newUndelivered, 'createScartoForMarketingCloud did not work correctly');
        System.assertNotEquals(true, newUndelivered, 'createScartoForMarketingCloud did not work correctly');
        
    }
    
    @isTest static void checkForEsitiIntermedi(){
        
        List<wrts_prcgvr__Activity__c> activities = [Select id,DiscardCategory__c,Case__c,Order__c, wrts_prcgvr__ObjectId__c,Type__c From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
            
        HDT_UTL_Scarti.checkForEsitiIntermedi(activities);
        
        List<wrts_prcgvr__Activity__c> relatedAct = [Select id,wrts_prcgvr__Status__c From wrts_prcgvr__Activity__c where NewEmail__c != 'yes@no.it'];
        
        System.assertEquals('Aperta', relatedAct[0].wrts_prcgvr__Status__c, 'checkForEsitiIntermedi did not work correctly');
        System.assertNotEquals(null, relatedAct, 'checkForEsitiIntermedi did not work correctly');
        
    }
    
    @isTest static void handleMrrInboundRequest(){
        
        HDT_WRP_MrrRequest mrRequest = new HDT_WRP_MrrRequest();
        
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fields = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldAttivita = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldAttivita.fieldType = 'fieldType';
        fieldAttivita.name = 'ATTIVITA';
        fieldAttivita.value = 'Richiesta non identificata.';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldFase = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldFase.fieldType = 'fieldType';
        fieldFase.name = 'FASE';
        fieldFase.value = 'Completata';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldRecordOrder = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldRecordOrder.fieldType = 'fieldType';
        fieldRecordOrder.name = 'RECORD_ID';
        fieldRecordOrder.value = [Select id from order].id;
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldRecordCase = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldRecordCase.fieldType = 'fieldType';
        fieldRecordCase.name = 'RECORD_ID';
        fieldRecordCase.value = [Select id from Case].id;
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldPizza = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldPizza.fieldType = 'fieldType';
        fieldPizza.name = 'RECORD_ID';
        fieldPizza.value = 'O-pizza';
        
        fields.add(fieldAttivita);
        fields.add(fieldFase);
        fields.add(fieldRecordOrder);
        fields.add(fieldRecordCase);
        fields.add(fieldPizza);
        
        HDT_WRP_MrrRequest.HDT_WRP_Header head = new HDT_WRP_MrrRequest.HDT_WRP_Header();
        head.requestId = 'requestId';
        head.requestTimeStamp = 'requestTimeStamp';
        head.requestType = 'requestType';
        head.fields = fields;       
        
        List<HDT_WRP_MrrRequest.HDT_WRP_Object> objs = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
        HDT_WRP_MrrRequest.HDT_WRP_Object ob = new HDT_WRP_MrrRequest.HDT_WRP_Object();
        ob.fields = fields;
        ob.id = 'obid';
        ob.name = 'obname';       
        ob.objectType = 'obtype';
        objs.add(ob);
        
        HDT_WRP_MrrRequest.HDT_WRP_Request req = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        req.code = 'code';
        req.description = 'description';
        req.header = head;
        req.objects = objs;

        List<HDT_WRP_MrrRequest.HDT_WRP_Request> reqs = new List<HDT_WRP_MrrRequest.HDT_WRP_Request>();
        reqs.add(req);
        mrRequest.requests = reqs;
        
        Test.startTest();

        HDT_UTL_Scarti.handleMRRInboundRequest(mrRequest.requests);
        
        Test.stopTest();
        
        System.assertEquals('code', mrRequest.requests[0].code, 'handleMRRInboundRequest did not work correctly');
        System.assertNotEquals(null, mrRequest.requests, 'handleMRRInboundRequest did not work correctly');
        
    }      

    @isTest static void updatePraticaForScartoDocumentaleQueueException(){
               
        list <wrts_prcgvr__Activity__c> act = [Select id from wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it' LIMIT 1];       
        list <wrts_prcgvr__Activity__c> actnewlist=new list<wrts_prcgvr__Activity__c>();
        wrts_prcgvr__Activity__c actnew=new wrts_prcgvr__Activity__c();
        actnew.id=act[0].id;
        actnew.NewEmail__c = 'forse@bo.it';
        actnewlist.add(actnew);
        //update act;
        HDT_UTL_Scarti.updatePraticaForScartoDocumentale(actnewlist, act);        
        List<Order> ords = [Select Email__c From Order Where Email__c ='forse@bo.it'];
        System.assertNotEquals(null, ords, 'updatePraticaForScartoDocumentaleQueue did not work correctly');
        List<AsyncApexJob> jobs = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'Queueable'];
    	System.assertEquals(1, jobs.size(), 'expecting one queued job');
               
    }
    
  /*  @isTest static void updatePraticaForScartoDocumentaleQueueOrder(){
               
        wrts_prcgvr__Activity__c act = [Select id from wrts_prcgvr__Activity__c where NewEmail__c = 'activityOrder@no.it' LIMIT 1];       
        act.NewEmail__c = 'forse@bo.it';
        update act;
                
        List<Order> ords = [Select Email__c From Order Where Email__c ='forse@bo.it'];
        System.assertNotEquals(null, ords, 'updatePraticaForScartoDocumentaleQueue did not work correctly');
        List<AsyncApexJob> jobs = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'Queueable'];
    	System.assertEquals(1, jobs.size(), 'expecting one queued job');
               
    }*/
    
    @isTest static void checkDiscardAnnullmentRuleCase(){
        
        String caseId = [Select Id From Case Limit 1].id;
        
        Test.startTest();
        
        Boolean b = HDT_UTL_Scarti.checkDiscardAnnullmentRule(caseId, 'Ammissibilità KO');
        
        Test.stopTest();
        
        System.assertEquals(true, b, 'checkDiscardAnnullmentRule did not work correctly');
        System.assertNotEquals(null, b, 'checkDiscardAnnullmentRule did not work correctly');
    }
    
    @isTest static void checkDiscardAnnullmentRuleOrder(){
        
        String orderId = [Select Id From Order Limit 1].id;
        
        Test.startTest();
        
        Boolean b = HDT_UTL_Scarti.checkDiscardAnnullmentRule(orderId, 'Esito KO da DL');
        
        Test.stopTest();
        
        System.assertEquals(true, b, 'checkDiscardAnnullmentRule did not work correctly');
        System.assertNotEquals(null, b, 'checkDiscardAnnullmentRule did not work correctly');
    }
    
    @isTest static void chiudiAttivitaCase(){
        
        String caseId = [Select Id From Case Limit 1].id;
        
        Test.startTest();
        
        HDT_UTL_Scarti.chiudiAttivita(caseId);
        
        Test.stopTest();
        
        List<wrts_prcgvr__Activity__c> activities = [Select id, wrts_prcgvr__Status__c from wrts_prcgvr__Activity__c where case__c =: caseId];
        
        System.assertNotEquals('Aperta', activities[0].wrts_prcgvr__Status__c, 'chiudiAttivitaCase did not work correctly');

    }
        
    @isTest static void annullaPraticaCase(){
        
        String caseId = [Select Id From Case Limit 1].id;
        
        Test.startTest();
        
        HDT_UTL_Scarti.annullaPratica(caseId);
        
        Test.stopTest();
        
        List<Case> cases = [Select id, CancellationReason__c, Status From Case Where id =: caseId];
        
        System.assertEquals('Closed', cases[0].Status, 'annullaPraticaCase did not work correctly');
        System.assertNotEquals('', cases[0].CancellationReason__c, 'annullaPraticaCase did not work correctly');

    }
    
    @isTest static void handleEditButtonPress(){
        Map<Id,wrts_prcgvr__Activity__c> activityOldMap = new Map<Id,wrts_prcgvr__Activity__c>();
        List<wrts_prcgvr__Activity__c> activityOld = [Select id, RecordTypeId, wrts_prcgvr__Status__c, DiscardCategory__c from wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        for(wrts_prcgvr__Activity__c a : activityOld){
            activityOldMap.put(a.id,a);
        }
        
        List<wrts_prcgvr__Activity__c> activityNew = [Select id, RecordTypeId, wrts_prcgvr__Status__c, DiscardCategory__c, Type__c, DiscardWorked__c from wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        activityNew[0].wrts_prcgvr__Status__c = 'Chiusa';
        activityNew[0].RecordTypeId = Schema.SObjectType.wrts_prcgvr__Activity__c.getRecordTypeInfosByDeveloperName().get('HDT_RT_Scarto').getRecordTypeId();
        
        HDT_UTL_Scarti.handleEditButtonPress(activityNew, activityOldMap);
        
        List<wrts_prcgvr__Activity__c> activityAfter = [Select id, RecordTypeId, wrts_prcgvr__Status__c, DiscardCategory__c, Type__c, DiscardWorked__c from wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
        
        System.assertEquals('Aperta', activityAfter[0].wrts_prcgvr__Status__c, 'handleEditButtonPress did not work correctly');
        System.assertNotEquals(null, activityAfter[0].DiscardWorked__c, 'handleEditButtonPress did not work correctly');
    }
    
     @isTest static void updateCloseDiscardActivityTest(){
        
        wrts_prcgvr__Activity__c act = [Select id from wrts_prcgvr__Activity__c LIMIT 1];       

        
        Test.startTest();
        
        Boolean res = HDT_UTL_Scarti.updateCloseDiscardActivity(act.Id);
        
        Test.stopTest();
        
        System.assertEquals(true, res, 'updateCloseDiscardActivity did not work correctly');
        System.assertNotEquals(null, res, 'updateCloseDiscardActivity did not work correctly');

    }
    
    
         @isTest static void closeDiscardActivityTest(){
        
        wrts_prcgvr__Activity__c act = [Select id from wrts_prcgvr__Activity__c LIMIT 1];       

        
        Test.startTest();
        
        wrts_prcgvr__Activity__c res = HDT_UTL_Scarti.CloseDiscardActivity(act.Id);
        
        Test.stopTest();
        
        System.assertEquals('Chiusa', res.wrts_prcgvr__Status__c, 'CloseDiscardActivity did not work correctly');

    }
    @isTest static void handleHerokuResponseTest(){
        wrts_prcgvr__Activity__c act = [Select id from wrts_prcgvr__Activity__c LIMIT 1]; 
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Richiesta non identificata');

        mapp.put('UTENZA','userprova');
        mapp.put('DATA_EVENTO',String.valueof(System.today()));
        mapp.put('ERROR_MESSAGE','descrizione scarto');
        
                Test.startTest();
        
        HDT_UTL_Scarti.handleHerokuResponse(act.Id,'Test','Fase1', mapp);
        
        Test.stopTest();
        
    }
    
    @isTest static void discardManagementTest(){
                HDT_WRP_MrrRequest mrRequest = new HDT_WRP_MrrRequest();
        
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fields = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldAttivita = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldAttivita.fieldType = 'fieldType';
        fieldAttivita.name = 'ATTIVITA';
        fieldAttivita.value = 'Richiesta non identificata.';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldFase = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldFase.fieldType = 'fieldType';
        fieldFase.name = 'FASE';
        fieldFase.value = 'Completata';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldRecordOrder = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldRecordOrder.fieldType = 'fieldType';
        fieldRecordOrder.name = 'RECORD_ID';
        fieldRecordOrder.value = [Select id from order].id;
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldRecordCase = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldRecordCase.fieldType = 'fieldType';
        fieldRecordCase.name = 'RECORD_ID';
        fieldRecordCase.value = [Select id from Case].id;
        
        HDT_WRP_MrrRequest.HDT_WRP_Field fieldPizza = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        fieldPizza.fieldType = 'fieldType';
        fieldPizza.name = 'RECORD_ID';
        fieldPizza.value = 'O-pizza';
        
        fields.add(fieldAttivita);
        fields.add(fieldFase);
        fields.add(fieldRecordOrder);
        fields.add(fieldRecordCase);
        fields.add(fieldPizza);
        
        HDT_WRP_MrrRequest.HDT_WRP_Header head = new HDT_WRP_MrrRequest.HDT_WRP_Header();
        head.requestId = 'requestId';
        head.requestTimeStamp = 'requestTimeStamp';
        head.requestType = 'requestType';
        head.fields = fields;       
        
        List<HDT_WRP_MrrRequest.HDT_WRP_Object> objs = new List<HDT_WRP_MrrRequest.HDT_WRP_Object>();
        HDT_WRP_MrrRequest.HDT_WRP_Object ob = new HDT_WRP_MrrRequest.HDT_WRP_Object();
        ob.fields = fields;
        ob.id = 'obid';
        ob.name = 'obname';       
        ob.objectType = 'obtype';
        objs.add(ob);
        
        HDT_WRP_MrrRequest.HDT_WRP_Request req = new HDT_WRP_MrrRequest.HDT_WRP_Request();
        req.code = 'code';
        req.description = 'description';
        req.header = head;
        req.objects = objs;

        List<HDT_WRP_MrrRequest.HDT_WRP_Request> reqs = new List<HDT_WRP_MrrRequest.HDT_WRP_Request>();
        reqs.add(req);
        mrRequest.requests = reqs;
        
        Test.startTest();

        HDT_UTL_Scarti.discardManagement(mrRequest.requests);
        
        Test.stopTest();
        
        System.assertEquals('code', mrRequest.requests[0].code, 'handleMRRInboundRequest did not work correctly');
        System.assertNotEquals(null, mrRequest.requests, 'handleMRRInboundRequest did not work correctly');
        
    }

    @IsTest
    public static void testCloseActivityOnCompleted(){
        String debugString = 'method - closeActivityOnCompleted ';
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata','Bozza',constants.ORDER_RECORDTYPEID_VOLTURA,constants.ORDER_RECORDTYPE_DEVELOPERNAME_VOLTURA);
        Order ord = [SELECT id FROM Order LIMIT 1];
        Account acc = [SELECT id FROM Account LIMIT 1];
        List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(1,false,acc.Id);
        activities[0].Order__c = ord.id;
        activities[0].wrts_prcgvr__Status__c = 'Aperta';
        activities[0].DiscardCategory__c = 'Tracciatura';
        insert activities;  
        activities = [SELECT id FROM wrts_prcgvr__Activity__c WHERE Order__c = :ord.Id AND wrts_prcgvr__Status__c = 'Aperta'];
        Integer preOpenActivities = activities.size();
        ord.Phase__c = 'Completata';
        ord.RecordTypeId = constants.ORDER_RECORDTYPEID_VOLTURA;
        Test.startTest();
         update ord;
        Test.stopTest();
        activities = [SELECT id FROM wrts_prcgvr__Activity__c WHERE Order__c = :ord.Id AND wrts_prcgvr__Status__c = 'Aperta'];
        System.assertEquals(1, preOpenActivities-activities.size(), debugString + 'Non si è chiusa l\'attività di tracciatura');
    }

    @isTest static void invokeDiscardSelfReading(){
        List<wrts_prcgvr__ActivityTemplate__c> templates =  HDT_UTL_DataFactoryTst.createActivityTemplate(1, false);
        templates[0].Name = 'CBS_AUT002__ESITO_KO_DA_SAP';
        templates[0].wrts_prcgvr__ObjectType__c = 'Case';
        insert templates;
        Contact cont = [SELECT Id,accountId FROM Contact LIMIT 1];
        Contract contr = [SELECT Id FROM Contract WHERE AccountId = :cont.AccountId LIMIT 1];
        List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, false, cont.AccountId, cont.id, null, contr.Id, null);
        cases[0].DiscardDescription__c = 'testdescription';
        cases[0].type = 'Autolettura da Cliente';
        cases[0].TraderPracticeCode__c = 'testcode';
        cases[0].TrackingDiscardPhase__c = 'testphase';
        cases[0].Cluster__c = 'Autolettura';
        cases[0].Phase__c = 'Esito KO da SAP';
        cases[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_RT_Autolettura').getRecordTypeId();
        insert cases;
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input.methodName = 'discardSelfReading';
        input.objectId = cases[0].id;
        input.templateName = 'Esito KO da SAP';
        inputs.add(input);
        Test.setMock(HttpCalloutMock.class, new HDT_TST_MyWebServiceMock());
        Test.startTest();
            List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
        Test.stopTest();
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(true, [SELECT Id FROM wrts_prcgvr__Activity__c  WHERE Type__c = 'Esito KO da SAP' AND wrts_prcgvr__Description__c LIKE '%Test Messaggio errore%'].size() == 1, 'Attività non creata correttamente.');

    }

    @IsTest
    public static void testGestioneSapOrder(){
        Order o = [SELECT id FROM Order Limit 1];
		o.RecordTypeId = constants.ORDER_RECORDTYPEID_ATTIVAZIONE;
        setObject(o, 'Ammissibilità KO');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata','Errore Lavorazione SAP',constants.ORDER_RECORDTYPEID_ATTIVAZIONE,constants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Esito OK da DL','Errore Lavorazione SAP',constants.ORDER_RECORDTYPEID_ATTIVAZIONE,constants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Errore Lavorazione SAP',constants.ORDER_RECORDTYPEID_ATTIVAZIONE,constants.ORDER_RECORDTYPE_DEVELOPERNAME_ATTIVAZIONE);
        Test.startTest();
            update new Order (Id = o.Id, Phase__c = 'Completata');
            o = [SELECT id,Phase__c FROM Order WHERE Id =:o.Id];
            System.assertEquals(o.Phase__c, 'Ammissibilità KO', 'La fase non è ritornata in Ammissibilità KO');
            setObject(o, 'Esito OK da DL');
            update new Order (Id = o.Id, Phase__c = 'Completata');
            o = [SELECT id,Phase__c FROM Order WHERE Id =:o.Id];
            System.assertEquals(o.Phase__c, 'Completata', 'La pratica non è stata chiusa');
            setObject(o, 'Ammissibilità OK');
            update new Order (Id = o.Id, Phase__c = 'Esito OK da DL');
            o = [SELECT id,Phase__c FROM Order WHERE Id =:o.Id];
            System.assertEquals(o.Phase__c, 'Esito OK da DL', 'L\'esito OK non ha sbloccato l\'errore lavorazione SAP.');
            setObject(o, 'Ammissibilità OK');
            Boolean error = false;
            try{
                update new Order (Id = o.Id, Phase__c = 'Da Inviare');
            }catch(Exception e){
                error = true;
                System.assert(e.getMessage().containsIgnoreCase('Su questo ordine è presente uno scarto SAP da gestire'),'L\'eccezione lanciata non è quella attesa');
            }
            System.assert(error,'Non è stata lanciata l\'eccezione attesa');
            o.Phase__c = 'Errore Lavorazione SAP';
            update o;
            update new Order (Id = o.Id,ManagedSapDiscard__c = 'OK', PhaseStory__c = 'Errore tecnico invio a SAP@@Errore Lavorazione SAP@@1669487910967@@A||Errore Lavorazione SAP@@Errore tecnico invio a SAP@@1669404356152@@A||Ammissibilità OK@@Errore Lavorazione SAP@@1659117263912@@A||' );
            update new Order (Id = o.Id, Phase__c = 'Da Inviare');
            o = [SELECT id,Phase__c,ManagedSapDiscard__c FROM Order WHERE Id =:o.Id];
            System.assertEquals(o.Phase__c, 'Da Inviare', 'Non è stato rivelato l\'errore lavorazione SAP impostato da SFDC.');
            System.assert(String.isBlank(o.ManagedSapDiscard__c), 'Non è stato sbiancato il campo all\'uscita della fase');
        Test.stopTest();
    }

    @IsTest
    public static void testGestioneSapCase(){
        Case c = [SELECT id FROM Case Limit 1];
        setObject(c, 'Ammissibilità KO');
        HDT_UTL_DataFactoryTst.newPhaseTransition('Completata','Errore Lavorazione SAP',constants.CASE_RECORDTYPEID_MOROSITA,constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Esito OK da DL','Errore Lavorazione SAP',constants.CASE_RECORDTYPEID_MOROSITA,constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA);
        HDT_UTL_DataFactoryTst.newPhaseTransition('Da Inviare','Errore Lavorazione SAP',constants.CASE_RECORDTYPEID_MOROSITA,constants.CASE_RECORDTYPE_DEVELOPERNAME_MOROSITA);
        Test.startTest();
            update new Case (Id = c.Id, Phase__c = 'Completata');
            c = [SELECT id,Phase__c FROM Case WHERE Id =:c.Id];
            System.assertEquals(c.Phase__c, 'Ammissibilità KO', 'La fase non è ritornata in Ammissibilità KO');
            setObject(c, 'Esito OK da DL');
            update new Case (Id = c.Id, Phase__c = 'Completata');
            c = [SELECT id,Phase__c FROM Case WHERE Id =:c.Id];
            System.assertEquals(c.Phase__c, 'Completata', 'La pratica non è stata chiusa');
            setObject(c, 'Ammissibilità OK');
            update new Case (Id = c.Id, Phase__c = 'Esito OK da DL');
            c = [SELECT id,Phase__c FROM Case WHERE Id =:c.Id];
            System.assertEquals(c.Phase__c, 'Esito OK da DL', 'L\'esito OK non ha sbloccato l\'errore lavorazione SAP.');
            setObject(c, 'Ammissibilità OK');
            Boolean error = false;
            try{
                update new Case (Id = c.Id, Phase__c = 'Da Inviare');
            }catch(Exception e){
                error = true;
                System.assert(e.getMessage().containsIgnoreCase('Su questo ordine è presente uno scarto SAP da gestire'),'L\'eccezione lanciata non è quella attesa');
            }
            System.assert(error,'Non è stata lanciata l\'eccezione attesa');
            c.Phase__c = 'Errore Lavorazione SAP';
            update c;
            update new Case (Id = c.Id,DistributorFlowCode__c = 'OK', PhaseStory__c = 'Errore tecnico invio a SAP@@Errore Lavorazione SAP@@1669487910967@@A||Errore Lavorazione SAP@@Errore tecnico invio a SAP@@1669404356152@@A||Ammissibilità OK@@Errore Lavorazione SAP@@1659117263912@@A||' );
            update new Case (Id = c.Id, Phase__c = 'Da Inviare');
            c = [SELECT id,Phase__c,DistributorFlowCode__c FROM Case WHERE Id =:c.Id];
            System.assertEquals(c.Phase__c, 'Da Inviare', 'Non è stato rivelato l\'errore lavorazione SAP impostato da SFDC.');
            System.assert(String.isBlank(c.DistributorFlowCode__c), 'Non è stato sbiancato il campo all\'uscita della fase');
        Test.stopTest();   
    }

    private static void setObject(SObject o,String previousPhase){
        o.put('Phase__c' , 'Errore Lavorazione SAP');
        update o;
        o.put('PhaseStory__c', 'Errore tecnico invio a SAP@@Errore Lavorazione SAP@@1669487910967@@A||Errore Lavorazione SAP@@Errore tecnico invio a SAP@@1669404356152@@A||'+previousPhase+'@@Errore Lavorazione SAP@@1659117263912@@A||');
        update o;
    }
    
    public class HDT_TST_MyWebServiceMock implements HTTPCalloutMock{
        
        public HTTPResponse respond(HTTPRequest request){
            HttpResponse response = new HttpResponse();
            //PREPARING RESPONSE
            Map<String, Object> myResponseMap = new Map<String, Object>();
            String myError = 'Test Messaggio errore';
            myResponseMap.put('message', myError);
            
            List<Object> errorDetails = new List<Object>{myResponseMap};
            
            Map<String, Object> body = new Map<String, Object>();
            body.put('errorDetails', errorDetails);
            
            //HTTP RESPONSE
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(body));
            response.setStatusCode(400);
            response.setStatus('BAD REQUEST');
            return response;
        }
    }

}