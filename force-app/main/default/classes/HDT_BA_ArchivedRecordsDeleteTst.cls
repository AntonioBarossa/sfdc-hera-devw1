/**
 * Header of the class "HDT_BA_AttributesContactTst"
 * @author Andrei Necsulescu, andrei.necsulescu@webresults.it
 * @version 1.0
 * @description: Apex Test Class of the relative Apex Class "HDT_BA_ArchivedRecordsDelete"
 * @history
 * @Created 21/10/2022
 * Modified By:
 **/

@isTest
public with sharing class HDT_BA_ArchivedRecordsDeleteTst {

    static HDT_UTL_Constants utlConstants = new HDT_UTL_Constants();
    static Integer numberOfRecords = 10;
    static Integer batchSize = 200;
    static User testAdmin = HDT_UTL_DataFactoryTst.createInternalUser(HDT_UTL_DataFactoryTst.getProfileId(utlConstants.SYSTEM_ADMINISTRATOR_NAME), true);
    static HDT_BA_ArchivedRecordsDelete ard = new HDT_BA_ArchivedRecordsDelete(batchSize);

    @TestSetup
    static void setup(){

        // Process Click setup
        HDT_UTL_DataFactoryTst.pClickInstance();
        HDT_UTL_DataFactoryTst.pClickOrderPhase();
        
        // Create Accounts
        List<Account> accounts = HDT_UTL_DataFactoryTst.createAccountBusiness(numberOfRecords, true, 'MMS', 'G1 - MMS Persona fisica', 'Famiglie');
        // Create Pricebook
        Pricebook2 pricebook = HDT_UTL_DataFactoryTst.activeStandardPricebook();
        // Create Products
        List<Product2> products = HDT_UTL_DataFactoryTst.createProduct2(numberOfRecords, true);
        // Create PriceBookEntries
        List<PricebookEntry> pricebookEntries = HDT_UTL_DataFactoryTst.createPricebookEntry(products, true, pricebook.Id);
        // Create TriggeredSend
        et4ae5__Automated_Send__c triggeredSend = HDT_UTL_DataFactoryTst.createTriggeredSend(1, true).get(0);
        // Create IndividualEmailResults
        List<et4ae5__IndividualEmailResult__c> individualEmailResults = HDT_UTL_DataFactoryTst.createIndividualEmailResult(numberOfRecords, false, triggeredSend.Id);
        // Create Individuals
        List<Individual> individuals = HDT_UTL_DataFactoryTst.createIndividual(numberOfRecords, true);
        // Create Leads
        List<Lead> leads = HDT_UTL_DataFactoryTst.createLead(numberOfRecords, false);

        List<BillingProfile__c> billingProfiles = new List<BillingProfile__c>();
        List<Contact> contacts = new List<Contact>();
        List<Order> orders = new List<Order>();
        List<OrderItem> orderItems = new List<OrderItem>();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<Contract> contracts = new List<Contract>();
        List<Case> cases = new List<Case>();
        List<CommunicationLog__c> communicationLogs = new List<CommunicationLog__c>();
        List<SMSTracking__c> smsTrackings = new List<SMSTracking__c>();
        List<PushTracking__c> pushTrackings = new List<PushTracking__c>();
        List<Sale__c> sales = new List<Sale__c>();
        List<wrts_prcgvr__Activity__c> activities = new List<wrts_prcgvr__Activity__c>();

        // Records that must be related to an account
        for (Integer i = 0; i < numberOfRecords; i++) {

            // Create BillingProfiles
            BillingProfile__c bp = HDT_UTL_DataFactoryTst.createBillingProfile(1, false, accounts.get(i).Id).get(0);
            // Create Contacts
            Contact con = HDT_UTL_DataFactoryTst.createContact(1, false, accounts.get(i).Id).get(0);

            bp.ContractAccountCode__c = String.valueOf(Decimal.valueOf(bp.ContractAccountCode__c) + i);

            billingProfiles.add(bp);            

            con.IndividualId = individuals.get(i).Id;
            con.CompanyOwner__c = 'MMS';
            con.Company__c = 'MMS';


            leads.get(i).IndividualId = individuals.get(i).Id;

            contacts.add(con);
            
        }

        insert billingProfiles;
        insert contacts;
        insert leads;

        // Create Interactions
        List<Interaction__c> interactions = HDT_UTL_DataFactoryTst.createInteraction(contacts, true);
        // Create ServicePoints
        List<ServicePoint__c> servicepoints = HDT_UTL_DataFactoryTst.createServicePoint(numberOfRecords, true);

        for (Integer i = 0; i < numberOfRecords; i++) {
            
            // Create Orders
            Order ord = HDT_UTL_DataFactoryTst.createOrder(1, false, accounts.get(i).Id, 'Bozza').get(0);
            // Create Contracts
            Contract cont = HDT_UTL_DataFactoryTst.createContract(1, false, accounts.get(i).Id).get(0);
            // Create Cases
            Case cas = HDT_UTL_DataFactoryTst.createCase(1, false, accounts.get(i).Id, contacts.get(i).Id, servicepoints.get(i).Id, null, null).get(0);
            // Create CommunicationLogs
            communicationLogs.addAll(HDT_UTL_DataFactoryTst.createCommunicationLog(1, false, accounts.get(i).Id, contacts.get(i).Id));
            // Create Sales
            Sale__c sale = HDT_UTL_DataFactoryTst.createSale(1, false, accounts.get(i).Id, '').get(0);
            // Create Activities
            wrts_prcgvr__Activity__c activity = HDT_UTL_DataFactoryTst.createActivityCustom(1, false, accounts.get(i).Id).get(0);

            ord.BillingProfile__c = billingProfiles.get(i).Id;
            ord.Interaction__c = interactions.get(i).Id;
            ord.pricebook2Id = pricebook.Id;

            cont.BillingProfile__c = billingProfiles.get(i).Id;

            cas.BillingProfile__c = billingProfiles.get(i).Id;
            cas.TargetBillingProfile__c = billingProfiles.get(i).Id;
            cas.Interaction__c = interactions.get(i).Id;
            cas.ServicePoint__c = servicepoints.get(i).Id;

            sale.Interaction__c = interactions.get(i).Id;

            activity.ServicePoint__c = servicepoints.get(i).Id;
            activity.Interaction__c = interactions.get(i).Id;

            orders.add(ord);

            contracts.add(cont);

            cases.add(cas);

            sales.add(sale);

            activities.add(activity);

        }

        insert orders;
        insert cases;
        insert contracts;
        insert communicationLogs;
        insert sales;
        insert activities;

        for (Integer i = 0; i < numberOfRecords; i++) {

            // Create OrderItems
            OrderItem ordi = HDT_UTL_DataFactoryTst.createOrderItem(1, false, orders.get(i).Id, null, products.get(i).Id, pricebookEntries.get(0).Id).get(0);
            // Create SMSTrackings
            SMSTracking__c smst = HDT_UTL_DataFactoryTst.createSmsTracking(1, false, contacts.get(i).Id).get(0);            
            // Create SMSTrackings
            PushTracking__c put = HDT_UTL_DataFactoryTst.createPushTracking(1, false, contacts.get(i).Id).get(0);

            ordi.BillingProfile__c = billingProfiles.get(0).Id;

            smst.IdLog__c = communicationLogs.get(i).Id;

            put.IdLog__c = communicationLogs.get(i).Id;

            individualEmailResults.get(i).IdLog__c = communicationLogs.get(i).Id;

            orderItems.add(ordi);

            smsTrackings.add(smst);

            pushTrackings.add(put);

        }

        insert orderItems;
        insert smsTrackings;
        insert pushTrackings;
        insert individualEmailResults;

        // Create Opportunities
        List<Opportunity> opportunities = HDT_UTL_DataFactoryTst.createOpportunity(numberOfRecords, true);

        // Create Quotes
        for (Integer i = 0; i < numberOfRecords; i++) {
            
            SBQQ__Quote__c quote = HDT_UTL_DataFactoryTst.createQuote(1, false, orders.get(i).Id, opportunities.get(i).Id, null, '').get(0);

            quote.SBQQ__Primary__c = true;
            quote.SBQQ__PriceBook__c = pricebook.Id;

            quotes.add(quote);

        }

        insert quotes;
        
        // Create QuoteLines
        for (Integer i = 0; i < numberOfRecords; i++) {
            
            SBQQ__QuoteLine__c qli = HDT_UTL_DataFactoryTst.createQuoteLines(products.get(I).Id, quotes.get(i).Id, 1, false).get(0);

            qli.SBQQ__SubscriptionPricing__c = 'Fixed Price';

            quoteLines.add(qli);
        }

        insert quotelines;

        // Update Orders and OrderItems
        for (Integer i = 0; i < numberOfRecords; i++) {
            
            orders.get(i).SBQQ__Contracted__c = true;
            orders.get(i).Status = 'Activated';

            orderItems.get(i).SBQQ__Contracted__c = true;
            orderitems.get(i).SBQQ__Activated__c = true;

        }

        update orders;
        update orderItems;

    }

    @IsTest
    static void testFullBatchLaunch(){
        
        Test.startTest();
        System.runAs(testAdmin){

            // Batch will try to delete all the objects specified
            Database.executeBatch(ard, batchSize);

        }
        Test.stopTest();        
        
        Interaction__c testInteraction = [SELECT Id, IsDeleted FROM Interaction__c WHERE IsDeleted = true LIMIT 1 ALL ROWS];
        System.assertEquals(true, testInteraction.IsDeleted, 'The Interaction__c was not deleted as expected');

    }

    @IsTest
    static void testDeleteException(){
        
        Test.startTest();
        System.runAs(testAdmin){

            ard = new HDT_BA_ArchivedRecordsDelete(batchSize, 0, false);
            ard.currentObject = 'Account';
            
            // Delete Accounts
            Database.executeBatch(ard, batchSize);

        }
        Test.stopTest();

        Account testAccount = [SELECT Id, IsDeleted FROM Account WHERE IsDeleted = false LIMIT 1 ALL ROWS];
        System.assertEquals(false, testAccount.IsDeleted, 'The Account was deleted but an exception was expected');
        
    }

}