/**
 * @author Luca Molino (luca.molino@dunegroup.it)
 * @date 06/09/2021
 * @description HDT_BA_QualityCall test Class
 * @history Luca Molino – 06/10/2021 – Created Class
 */
@isTest
public with sharing class HDT_BA_QualityCallTst {

    private static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();

    @testSetup
    public static void setup(){

        Id adminUserProfileId=HDT_UTL_DataFactoryTst.getProfileId(utlConstants.HERA_SYSTEM_ADMINISTRATOR_NAME);
    
        User internalUser=HDT_UTL_DataFactoryTst.createInternalUser(adminUserProfileId, false);

        internalUser.UserPermissionsMarketingUser=true;

        insert internalUser;  
        System.runAs(internalUser){
            
            HDT_UTL_DataFactoryTst.pClickInstance();
            HDT_UTL_DataFactoryTst.pClickOrderPhase();
            /* HDT_UTL_DataFactoryTst.newPhaseTransition('Ammissibilità OK','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Heroku','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);  
            HDT_UTL_DataFactoryTst.newPhaseTransition('Comunicazione verso Motore VAS','Bozza',utlConstants.ORDER_RECORDTYPEID_SWITCHIN,utlConstants.ORDER_RECORDTYPE_DEVELOPERNAME_SWITCHIN);  
              */
            List<AgentMatrix__c> agentMatrix = HDT_UTL_DataFactoryTst.createAgentMatrix(1,false,'Sportello') ; 
            agentMatrix[0].IsMonitoring__c=true;
            agentMatrix[0].AgencyCode__c='001';
            insert agentMatrix;
            List<Account> accs = HDT_UTL_DataFactoryTst.createAccountBusiness(1,true,'MMS','MMS Azienda','Aziende SME');
            Id accId = accs[0].id;
            
            List<Contact> contacts = HDT_UTL_DataFactoryTst.createContact(2,false,accId);
            for(Contact c : contacts) {
                c.Company__c='MMS';
            }
            insert contacts;
            Id contactId = contacts[0].id;
            Id anotherContactId = contacts[1].id;
            List<Sale__c> sales=HDT_UTL_DataFactoryTst.createSale(16, true, accId, 'Attiva');
            
            List<Order> parentOrders = HDT_UTL_DataFactoryTst.createOrder(8,false,accId,'Documentazione Gestita');
            for (Integer i = 0;i<8;i++){
                parentOrders[i].Name = 'P'+String.valueOf(i);
                parentOrders[i].Contact__c = (Math.mod(i, 2) == 0)?contactId : anotherContactId;
                parentOrders[i].Status = 'Completed';
                parentOrders[i].recordTypeId = utlConstants.ORDER_RECORDTYPEID_ORDERDOSSIER;
            }
            insert parentOrders;
            List<Order> childOrders = HDT_UTL_DataFactoryTst.createOrderWithPricebook(16, false, accId, sales, Test.getStandardPricebookId());//HDT_UTL_DataFactoryTst.createOrder(16,false,accId,'Comunicazione verso Heroku');
            for (Integer i = 0;i<16;i++){
                childOrders[i].Name = 'C'+String.valueOf(i);
                childOrders[i].Status='In Lavorazione';
                childOrders[i].Phase__c = 'Ammissibilità KO';
                childOrders[i].Username__c=(Math.mod(i, 2) == 0)? 'test' : 'test2';
                childOrders[i].Password__c=(Math.mod(i, 2) == 0)?'test1' : 'test21';
                childOrders[i].NotRegisteredMeterCase__c=true;
                childOrders[i].EffectiveDate__c=date.today();
                childOrders[i].PowerCommitted__c=2;
                childOrders[i].ImplantType__c='13A0-Usi di Abitazione BT';
                childOrders[i].RequestOption__c='Domestici-TD';
                childOrders[i].QualityCall__c=(i != 4 && i != 7 && i!= 14);  
                childOrders[i].QualityCallUnique__c = ( i != 0 && i != 1);
                childOrders[i].ComfortCallDaysDue__c=null;
                childOrders[i].WizardCompletedDate__c=date.today().addDays(-60);
                childOrders[i].IsVas__c= (i==3 || i ==6);
                childOrders[i].AgencyCode__c='001';
                childOrders[i].Channel__c = 'Agenzia';
                childOrders[i].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_SWITCHIN;
            
            }
            //P1
            childOrders[0].ParentOrder__c = parentOrders[0].Id;
            childOrders[0].Contact__c = parentOrders[0].Contact__c;
            childOrders[0].Sale__c = sales[0].Id;
            //P2
            childOrders[1].Phase__c = 'Comunicazione verso Heroku OK';
            childOrders[1].ParentOrder__c = parentOrders[1].Id;
            childOrders[1].Contact__c = parentOrders[1].Contact__c;
            childOrders[1].Sale__c = sales[1].Id;
            //P3
            childOrders[2].Phase__c = 'Voltura Rifiutata';
            childOrders[2].ParentOrder__c = parentOrders[2].Id;
            childOrders[2].Contact__c = parentOrders[2].Contact__c;
            childOrders[2].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VOLTURA;
            childOrders[2].Sale__c = sales[2].Id;
            
            childOrders[3].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VAS;
            childOrders[3].Phase__c = 'Comunicazione verso Heroku KO';
            childOrders[3].ParentOrder__c = parentOrders[2].Id;
            childOrders[3].Sale__c = sales[2].Id;
            childOrders[3].Contact__c = parentOrders[2].Contact__c;
            
            childOrders[4].Phase__c = 'Attesa Credit Check';
            childOrders[4].ParentOrder__c = parentOrders[2].Id;
            childOrders[4].Sale__c = sales[2].Id;
            childOrders[4].Contact__c = parentOrders[2].Contact__c;
            //P4
            childOrders[5].Phase__c = 'Comunicazione verso Heroku OK';
            childOrders[5].ParentOrder__c = parentOrders[3].Id;
            childOrders[5].Sale__c = sales[3].Id;
            childOrders[5].Contact__c = parentOrders[3].Contact__c;
            
            childOrders[6].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VAS;
            childOrders[6].Phase__c = 'Comunicazione verso Heroku OK';
            childOrders[6].ParentOrder__c = parentOrders[3].Id;
            childOrders[6].VASType__c = 'VAS Fatturabili';
            childOrders[6].Sale__c = sales[3].Id;
            childOrders[6].Contact__c = parentOrders[3].Contact__c;
            
            childOrders[7].ParentOrder__c = parentOrders[3].Id;
            childOrders[7].Sale__c = sales[3].Id;
            childOrders[7].Contact__c = parentOrders[3].Contact__c;
            //P5
            childOrders[8].Phase__c = 'Comunicazione verso Heroku OK';
            childOrders[8].ParentOrder__c = parentOrders[4].Id;
            childOrders[8].Sale__c = sales[4].Id;
            childOrders[8].Contact__c = parentOrders[4].Contact__c;
            
            childOrders[9].Phase__c = 'Credit Check KO';
            childOrders[9].ParentOrder__c = parentOrders[4].Id;
            childOrders[9].Sale__c = sales[4].Id;
            childOrders[9].Contact__c = parentOrders[4].Contact__c;
            
            childOrders[10].ParentOrder__c = parentOrders[4].Id;
            childOrders[10].Sale__c = sales[4].Id;
            childOrders[10].Contact__c = parentOrders[4].Contact__c;
            //P6
            childOrders[11].WizardCompletedDate__c=date.today().addDays(3);
            childOrders[11].ParentOrder__c = parentOrders[5].Id;
            childOrders[11].Sale__c = sales[5].Id;
            childOrders[11].Contact__c = parentOrders[5].Contact__c;
            
            childOrders[12].ParentOrder__c = parentOrders[5].Id;
            childOrders[12].Sale__c = sales[5].Id;
            childOrders[12].Contact__c = parentOrders[5].Contact__c;
            
            childOrders[13].ParentOrder__c = parentOrders[5].Id;
            childOrders[13].Sale__c = sales[5].Id;
            childOrders[13].Contact__c = parentOrders[5].Contact__c;
            //P7
            childOrders[14].ParentOrder__c = parentOrders[6].Id;
            childOrders[14].Sale__c = sales[6].Id;
            childOrders[14].Contact__c = parentOrders[6].Contact__c;
            
            childOrders[15].VasSubtype__c = 'Analisi consumi';
            childOrders[15].Phase__c = 'Comunicazione verso Heroku KO';
            childOrders[15].ParentOrder__c = parentOrders[6].Id;
            childOrders[15].Contact__c = parentOrders[6].Contact__c;
            childOrders[15].Sale__c = sales[6].Id;
            childOrders[15].RecordTypeId = utlConstants.ORDER_RECORDTYPEID_VAS;
            
            insert childOrders;
            
            List<Campaign> campaigns = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaigns[0].Name = 'Comfort Campaign';
            insert campaigns;
            
           
            List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(1,false);
            products[0].family = 'VAS Servizio';
            products[0].CancelableQC__c = true;
            insert products;
            List<ServicePoint__c> sp = HDT_UTL_DataFactoryTst.createServicePoint(1,true);
            List<PricebookEntry> entries = HDT_UTL_DataFactoryTst.createPricebookEntry(products,true,Test.getStandardPricebookId());
            
            HDT_UTL_DataFactoryTst.createOrderItem(1,true,childOrders[0].Id,sp[0].Id,products[0].Id,entries[0].id);

            List<Campaign> campaign = HDT_UTL_DataFactoryTst.createCampaign(1,false);
            campaign[0].Name='Quality Campaign';
            campaign[0].CompanyOwner__c ='MMS';
            campaign[0].Tipology__c = 'Quality Call';
            campaign[0].Status = 'In Corso';
            insert campaign;
            
            List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(1, false);
            List<Individual> inds = HDT_UTL_DataFactoryTst.createIndividual(1, false);
            insert inds;
            leads[0].IndividualId=inds[0].id;
            insert leads;

            List<CampaignMember> campaignMember = HDT_UTL_DataFactoryTst.createCampaignMember( false, campaign[0].Id, leads, contacts);
            insert campaignMember;

            

            List<ComfortQualityCall__c> cqcRecords = HDT_UTL_DataFactoryTst.createComfortQualityCall(1, false);
            cqcRecords[0].DocumentValidation__c = true;
            cqcRecords[0].QualityEnabled__c = true;
            insert cqcRecords;

            List<wrts_prcgvr__Activity__c> activity = HDT_UTL_DataFactoryTst.createActivityCustom(2,false,accId);
            activity[0].order__c=childOrders[0].Id;
            activity[0].Type__c='Esito KO DL';
            activity[0].wrts_prcgvr__Status__c = 'Aperta';
            activity[1].order__c=childOrders[0].Id;
            activity[1].Type__c='Ammissibilità KO';
            activity[1].wrts_prcgvr__Status__c = 'Aperta';
            insert activity;
        } 
    }

    @isTest
    public static void testQualityCallExecute(){
        Test.startTest();
        
            HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
            Database.executeBatch(batch,200);

        Test.stopTest();
        
        List<wrts_prcgvr__Activity__c> activities = [SELECT id,Order__r.Name, Order__r.Phase__c, Type__c,wrts_prcgvr__Status__c FROM wrts_prcgvr__Activity__c WHERE Type__c IN ('Quality Call','Quality Scaduta')];
        Set<String> qcActivity = new Set<String>{
            'C0',
            'C1',
            'P2',
            'P3',
            'P4',
            'P5'
        };
        Set<String> qsActivity = new Set<String>{
            'P3'
        };
        Set<String> phaseOrder = new Set<String>{
            'C0-Annullato',
            'C1-Comunicazione verso Heroku OK'
        };
        Set<String> closedActivity = new Set<String>{
            'C0',
            'C1',
            'P2',
            'P3'
        };
        for (wrts_prcgvr__Activity__c act : activities){
            phaseOrder.remove(act.Order__r.Name + '-' + act.Order__r.Phase__c);
            if ('Quality Call'.equalsIgnoreCase(act.Type__c)){
                qcActivity.remove(act.Order__r.Name);
            }
            if ('Quality Scaduta'.equalsIgnoreCase(act.Type__c)){
                qsActivity.remove(act.Order__r.Name);
                continue;
            }
            if (!'Chiusa'.equalsIgnoreCase(act.wrts_prcgvr__Status__c)){
                System.assert(!closedActivity.contains(act.Order__r.Name), 'Le quality call non sono state chiuse correttamente');
            }
        }
        System.assertEquals(qcActivity.size(), 0, 'Non sono state create tutte le activity di Quality Call');
        System.assertEquals(qsActivity.size(), 0, 'Non sono state create le activity di Quality Scaduta');
        System.assertEquals(phaseOrder.size(), 0, 'Gli ordini non sono correttamente aggiornati');
        System.assertEquals(2, [SELECT id FROM wrts_prcgvr__Activity__c WHERE Type__c IN ('Esito KO DL','Ammissibilità KO') AND wrts_prcgvr__Status__c = 'Annullata'].size(), 'Le activitie non sono state chiuse');
    }

    @isTest
    public static void testQualityCallClosed(){
        delete [SELECT id FROM CampaignMember];
        List<Order> orders =[SELECT Id,AccountId, Name FROM Order WHERE Name IN ('C0','C9','P4','P5','C12')];
        List<wrts_prcgvr__Activity__c> acts = new List<wrts_prcgvr__Activity__c>();
        List<Order> ords = new List<Order>();
        for (order o : orders){
            if ('C0'.equals(o.Name) || 'P4'.equals(o.Name) || 'P5'.equals(o.Name)){
                acts.add(
                    new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_ComfortQualityCall'),
                        Type__c = 'Quality Call',
                        wrts_prcgvr__Status__c = 'Aperta',
                        ActivatedDate__c = Date.today(),
                        LoginChannel__c = 'Agenzia',
                        Order__c = o.Id
                    )
                );
            }
            if ('C0'.equals(o.Name) || 'P5'.equals(o.Name)){
                acts.add(
                    new wrts_prcgvr__Activity__c(
                        RecordTypeId = HDT_UTL_ActivityCustom.getRecordTypeId('HDT_RT_AttivitaGestionali'),
                        Account__c = o.AccountId,
                        Order__c =  o.Id,
                        Type__c = 'Quality Scaduta',
                        wrts_prcgvr__Status__c = 'Aperta',
                        wrts_prcgvr__Description__c = 'Non è stato possibile procedere all\'annullamento allo scadere dei 50 giorni di quality call, verificare la richiesta e procedere tramite ripensamento o tramite il case di post sales Disattivazione VAS'
                    )
                );

            }
            if ('C9'.equals(o.Name) || 'C12'.equals(o.Name)){
                ords.add(new Order(Id = o.Id, QualityCallStatus__c = HDT_UTL_QualityCall.HANDLE_DEADLINE));

            }
        }
        insert acts;
        update ords;
        Test.startTest();
        
            HDT_BA_QualityCall batch = new HDT_BA_QualityCall();
            Database.executeBatch(batch,200);

        Test.stopTest();
        System.assertEquals(3, [SELECT Id FROM wrts_prcgvr__Activity__c WHERE wrts_prcgvr__Status__c = 'Chiusa' AND RecordType.DeveloperName = 'HDT_RT_ComfortQualityCall' AND Order__r.NAme IN ('C0','P4','P5')].size(), 'Le activity di QC non sono state chiuse');
    }

}