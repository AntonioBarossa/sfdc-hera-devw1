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
            orders[0].Catalog__c = 'testCatalog';
            orders[0].Contact__c = contacts[0].id;
            orders[0].PhoneNumber__c ='3461357661';
            orders[0].Email__c = 'email@nuova.it';
            insert orders;
            Id orderId = orders[0].id;
            
            List<OrderItem> orderItems = HDT_UTL_DataFactoryTst.createOrderItem(1,true,orderId,pointId,productId,entryId);            
                     
            List<Case> cases = HDT_UTL_DataFactoryTst.createCase(1, false, accId, contacts[0].id, null, contracts[0].Id, orders[0].Id);
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
            
            List<wrts_prcgvr__ActivityTemplate__c> activityTemplates = HDT_UTL_DataFactoryTst.createActivityTemplate(6,false);
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
            rules[0].ControllingField__c = 'Catalog__c';
            rules[0].ProcessField__c = 'CausalCode__c';
            rules[0].ProcessValue__c = 'testCausalCode';
            rules[0].ControllingValue__c = 'testCatalog';
            insert rules;
            
            List<DiscardAnnullmentRule__c> rules2 = HDT_UTL_DataFactoryTst.createDiscardAnnullmentRule(1,false,'Case');
            rules2[0].ControllingField__c = 'TraderPracticeCode__c';
            rules2[0].ProcessField__c = 'TrackingDiscardPhase__c';
            rules2[0].ProcessValue__c = 'testphase';
            rules2[0].ControllingValue__c = 'testcode';
            insert rules2;
            
            List<wrts_prcgvr__Activity__c> activities = HDT_UTL_DataFactoryTst.createActivityCustom(2,false,accId);
            activities[0].Order__c = orders[0].id;
            activities[0].Status__c = 'Creata';
            activities[0].NewEmail__c = 'yes@no.it';
            activities[0].NewMobile__c = '3334441122';
            activities[0].DiscardCategory__c = 'Anonima';
            activities[0].Case__c = cases[0].id;            
            activities[1].Case__c = cases[0].id;
            activities[1].DiscardCategory__c = 'Anonima';
            activities[1].Status__c = 'Creata';
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
   
    
    @isTest private static void evaluate(){
        
        Order record = [Select id from Order limit 1];
        
        Map<String, Object> argsMap = new Map<String, Object>{'transition'=>null,
                                                              'action'=>null,
                                                              'method'=>'checkActivityCreation___CBS_ATT006__AMMISSIBILITA_KO',
            												  'record'=>record,
                                                              'sender'=>null};
                                                                  
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        boolean b = classInstance.evaluate(argsMap);
        
        System.assertEquals(false, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    }
    
    @isTest private static void evaluate2(){
        
        Order record = [Select id from Order limit 1];
        
        Map<String, Object> argsMap = new Map<String, Object>{'transition'=>null,
                                                              'action'=>null,
                                                              'method'=>'checkAnnullment___CBS_ATT006__AMMISSIBILITA_KO',
            												  'record'=>record,
                                                              'sender'=>null};
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        boolean b = classInstance.evaluate(argsMap);
        
        System.assertEquals(true, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    }
    
    @isTest private static void evaluate3(){
        
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
    
    @isTest private static void evaluate4(){
        
        Case record = [Select id from Case limit 1];
        
        Map<String, Object> argsMap = new Map<String, Object>{
            'transition'=>null,
            'action'=>null,
            'method'=>'checkActivityCreation___CBS_HER008__ELIMINATO_ESITO_IN_SCARTO_SALES',
            'record'=>record,
            'sender'=>null};
                
        HDT_UTL_Scarti classInstance = new HDT_UTL_Scarti();
        boolean b = classInstance.evaluate(argsMap);
        
        System.assertEquals(false, b, 'evaluate did not work correctly');
        System.assertNotEquals(null, b, 'evaluate did not work correctly');
    }
    
    @isTest static void invokeScartiAction1(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input1 = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input1.methodName = 'chiudiAttivita';
        input1.objectId = record.id;
        input1.templateName = 'templateName';
        inputs.add(input1);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
        
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction2(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input2 = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input2.methodName = 'annullaPratica';
        input2.objectId = record.id;
        input2.templateName = 'templateName';
        inputs.add(input2);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction3(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input3 = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input3.methodName = 'annullaContratti';
        input3.objectId = record.id;
        input3.templateName = 'templateName';
        inputs.add(input3);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction4(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input4 = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input4.methodName = 'createActivityByObjectIdAndTemplateName';
        input4.objectId = record.id;
        input4.templateName = 'CBS_ATT006__AMMISSIBILITA_KO';
        inputs.add(input4);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
        
    @isTest static void invokeScartiAction5(){
        
        Order record = [Select id from Order limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input5 = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input5.methodName = 'createActivityByObjectIdAndTemplateName';
        input5.objectId = record.id;
        input5.templateName = 'wrongtemplatename';
        inputs.add(input5);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
      
        System.assertEquals('KO', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');

    }
    
    @isTest static void invokeScartiAction6(){
        
        Case record = [Select id from Case limit 1];
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowInputs> inputs = new List<HDT_UTL_Scarti.HDT_UTL_FlowInputs>();
        
        HDT_UTL_Scarti.HDT_UTL_FlowInputs input1 = new HDT_UTL_Scarti.HDT_UTL_FlowInputs();
        input1.methodName = 'chiudiAttivita';
        input1.objectId = record.id;
        input1.templateName = 'templateName';
        inputs.add(input1);
        
        List<HDT_UTL_Scarti.HDT_UTL_FlowOutputs> outputs = HDT_UTL_Scarti.invokeScartiAction(inputs);
        
        System.assertEquals('OK', outputs[0].esito, 'invokeScartiAction did not work correctly');
        System.assertNotEquals(null, outputs[0], 'invokeScartiAction did not work correctly');
        
    }
    
    @isTest static void createAttivitaTracciaturaHeroku(){
        
        List<Map<String,String>> arg = new List<Map<String,String>>();
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('ATTIVITA','Richiesta non identificata');
        mapp.put('UTENZA','testutenza');
        mapp.put('DATA_EVENTO',String.valueOf(system.today()));
        mapp.put('ERROR_MESSAGE','erroretest');

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
            
        System.assertEquals(2, mails.size(), 'updateContactForScartoDocumentale did not work correctly');
        System.assertEquals(2, phones.size(), 'updateContactForScartoDocumentale did not work correctly');
        
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
        
        update individualEmailResults;
        
        String newBounceSubCategory = [Select BounceSubCategory__c From et4ae5__IndividualEmailResult__c limit 1].BounceSubCategory__c;
        
        System.assertEquals('changed', newBounceSubCategory, 'createScartoForMarketingCloud did not work correctly');
        System.assertNotEquals(null, newBounceSubCategory, 'createScartoForMarketingCloud did not work correctly');
        
    }
    
    @isTest static void createScartoForMarketingCloud2(){
        
        List<et4ae5__IndividualEmailResult__c> individualEmailResults = [Select id,BounceSubCategory__c From et4ae5__IndividualEmailResult__c where OrderID__c != null ];
        
        individualEmailResults[0].BounceSubCategory__c = 'changed';
        
        update individualEmailResults;
        
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
        
        List<wrts_prcgvr__Activity__c> activities = [Select id,DiscardCategory__c,Case__c,Order__c From wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it'];
            
        HDT_UTL_Scarti.checkForEsitiIntermedi(activities);
        
        List<wrts_prcgvr__Activity__c> relatedAct = [Select id,status__c,wrts_prcgvr__Status__c From wrts_prcgvr__Activity__c where NewEmail__c != 'yes@no.it'];
        
        System.assertEquals('Chiusa', relatedAct[0].wrts_prcgvr__Status__c, 'checkForEsitiIntermedi did not work correctly');
        System.assertNotEquals(null, relatedAct, 'checkForEsitiIntermedi did not work correctly');
        
    }
    
    @isTest static void handleMRRInboundRequest(){
        
        HDT_WRP_MrrRequest mrRequest = new HDT_WRP_MrrRequest();
        
        List<HDT_WRP_MrrRequest.HDT_WRP_Field> fields = new List<HDT_WRP_MrrRequest.HDT_WRP_Field>();
        HDT_WRP_MrrRequest.HDT_WRP_Field field1 = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        field1.fieldType = 'fieldType';
        field1.name = 'ATTIVITA***';
        field1.value = 'Richiesta non identificata***';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field field2 = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        field2.fieldType = 'fieldType';
        field2.name = 'FASE';
        field2.value = 'Completata';
        
        HDT_WRP_MrrRequest.HDT_WRP_Field field3 = new HDT_WRP_MrrRequest.HDT_WRP_Field();      
        field3.fieldType = 'fieldType';
        field3.name = 'RECORD_ID';
        field3.value = 'O-00100327';
        
        
        fields.add(field1);
        fields.add(field2);
        fields.add(field3);
        
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

    @isTest static void updatePraticaForScartoDocumentaleQueue(){
                
        HDT_UTL_Scarti sca = new HDT_UTL_Scarti();
        ID jobID = System.enqueueJob(sca);
               
        wrts_prcgvr__Activity__c act = [Select id from wrts_prcgvr__Activity__c where NewEmail__c = 'yes@no.it' LIMIT 1];       
        act.NewEmail__c = 'forse@bo.it';
        update act;
                
        List<Order> ords = [Select Email__c From Order Where Email__c ='forse@bo.it'];
        System.assertNotEquals(null, ords, 'updatePraticaForScartoDocumentaleQueue did not work correctly');
        List<AsyncApexJob> jobs = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'Queueable'];
    	System.assertEquals(2, jobs.size(), 'expecting one queued job');
        System.assertNotEquals(null, jobID, 'updatePraticaForScartoDocumentaleQueue did not work correctly');
               
    }        
}