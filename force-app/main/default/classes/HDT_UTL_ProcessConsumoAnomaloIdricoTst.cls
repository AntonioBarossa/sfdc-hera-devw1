@IsTest
private class HDT_UTL_ProcessConsumoAnomaloIdricoTst {

    @TestSetup
    static void makeData(){
        Integer amount=8;
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountResidenziale(amount, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        for(Account tmp:accs){
            tmp.SAPIntegrationID__c=tmp.CustomerCode__c;
        }
        insert accs;
        List<ServicePoint__c> servPoint=new List<ServicePoint__c>();
        Integer k=0;
        for(ServicePoint__c sp: HDT_UTL_DataFactoryTst.createServicePoint(amount, false)) {
            sp.ServicePointCode__c=sp.ServicePointCode__c+k;
            servPoint.add(sp);
            k++;
        }
        insert servPoint;
        k=0;
        List<Contact>contactList= HDT_UTL_DataFactoryTst.createContact(amount, false, accs[0].Id);
        for(Contact c:contactList){
            c.AccountId=accs[k].Id;
            k++;
        }
        insert contactList;
        k=0;
        List<BillingProfile__c>billingProfList=HDT_UTL_DataFactoryTst.createBillingProfile(amount, false, accs[0].Id);
        for(BillingProfile__c tmpBill:billingProfList){
            tmpBill.Account__c=accs[k].Id;
            tmpBill.InvoicingCity__c='Roma';
            tmpBill.InvoicingCountry__c='Italia';
            tmpBill.InvoicingPlace__c='Test';
            tmpBill.InvoicingPostalCode__c='00160';
            tmpBill.InvoicingProvince__c='RM';
            tmpBill.InvoicingStreetName__c='Via test';
            tmpBill.InvoicingStreetNumber__c='15';
            tmpBill.InvoiceEmailAddress__c='testinvoice@gmail.com';
            k++;
        }
        insert billingProfList;
        k=0;
        List<Contract> cont = new List<Contract>();
        for(Contract tmp:HDT_UTL_DataFactoryTst.createContract(amount, false, accs[0].Id)){
            tmp.ServicePoint__c = servPoint[k].Id;
            tmp.SAPContractCode__c = '301960232'+k;
            tmp.AccountId=accs[k].Id;
            tmp.Contact__c=contactList[k].Id;
            tmp.BillingProfile__c=billingProfList[k].Id;
            cont.add(tmp);
            k++;
        }
        cont[4].ServicePoint__c=null;
        cont[6].BillingProfile__c=null;
        insert cont;

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 8;
        request.Priority__c = 210;
        request.ProcessType__c = 'ConsumoAnomaloIdrico';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        for(Integer n=0; n<8; n++){
            MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            switch on n {
                when 0 {
                    //ok
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-20|Y|Posta Cartacea|Cartacea';
                }
                when 1 {
                    //ko on sap code
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'Invalid'+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-21|Y|Posta Cartacea|Cartacea';
                }
                when 2{
                    //ko con BP code (Account.SAPIntegrationID__c)
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n-1].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-22|Y|Posta Cartacea|Cartacea';
                }
                when 3 {
                    //ko missing required field accountId
                    item.Data__c='Consumo Anomalo Idrico|'+''+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-23|Y|Posta Cartacea|Cartacea';
                }
                when 4 {
                    //Contract.ServicePoint__c is null
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n-1].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-24|Y|Posta Cartacea|Cartacea';
                }
                when 5 {
                    //ok
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-25|Y|E-Mail|Cartacea';
                }
                when 6 {
                    //Missing billing profile
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-26|Y|Posta Cartacea|Cartacea';
                }
                when 7 {
                    //ko pod mismatch
                    item.Data__c='Consumo Anomalo Idrico|'+accs[n].SAPIntegrationID__c+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n-1].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-27|Y|Posta Cartacea|Cartacea';
                }
            }
            itemsList.add(item);
        }
        insert itemsList;
    }

    @IsTest
    static void exectueTst() {
        MassiveLoaderRequest__c myBulkRequest=[SELECT Id,ProcessType__c FROM MassiveLoaderRequest__c WHERE ProcessType__c='ConsumoAnomaloIdrico' WITH SECURITY_ENFORCED LIMIT 1  ];
        List<MassiveLoaderRequestItem__c> bulkItems=[SELECT Id, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, NextStepData__c, Result__c, RelatedRequestItem__c, VasOrder__c,Status__c FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c=:myBulkRequest.Id];
        HDT_UTL_ProcessConsumoAnomaloIdrico consumoAnomaloBulk=new HDT_UTL_ProcessConsumoAnomaloIdrico();
        consumoAnomaloBulk.setRequestId(myBulkRequest.Id);
        consumoAnomaloBulk.setProcess(myBulkRequest.ProcessType__c);
        consumoAnomaloBulk.setMassiveLoaderRequestItemList(bulkItems);
        Test.startTest();
        consumoAnomaloBulk.execute();
        Test.stopTest();
        List<Case> caseList=[SELECT Id FROM Case WHERE Type='Consumo Anomalo Idrico' WITH SECURITY_ENFORCED];
        MassiveLoaderRequest__c myBulkRequestCheck=[SELECT Id,ProcessType__c,RequestKO__c,RequestOK__c FROM MassiveLoaderRequest__c WHERE ProcessType__c='ConsumoAnomaloIdrico' WITH SECURITY_ENFORCED LIMIT 1];
        System.assertEquals(2,myBulkRequestCheck.RequestOK__c,'2 requests are ok');
        System.assertEquals(6,myBulkRequestCheck.RequestKO__c,'6 requests are ko');
        System.assertEquals(2,caseList.size() ,'2 cases have been created');
    }
}