@IsTest
private class HDT_UTL_BpManagementTst {

    @TestSetup
    static void setUp(){
        Integer amount=2;
        List<Account> accs = HDT_UTL_DataFactoryTst.createAccountResidenziale(amount, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        for(Account tmp:accs){
            tmp.SAPIntegrationID__c=tmp.CustomerCode__c;
        }
        insert accs;
        String accountListForCsv='';
        List<Account> bufferAccounts=HDT_UTL_DataFactoryTst.createAccountResidenziale(amount, false, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        for(Account buffAcc:bufferAccounts){
            buffAcc.SAPIntegrationID__c=buffAcc.CustomerCode__c;
            accountListForCsv+=buffAcc.CustomerCode__c+';';
        }
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
        insert cont;

        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 2;
        request.Priority__c = 210;
        request.ProcessType__c = 'GestioneBP';
        request.Status__c = 'In attesa di lavorazione';
        insert request;
        //Unificazione CA|3019681848|1005421319|1005425989|1007848247|200010613357|200010082321||892646689685|IT67K0300203280892646689685|4123|4123124|1|43|N|IT|Bollettino postale|Cartaceo|test@gmail.com|testpec@gmail.com|XML|Stesso sottoscrittore|Antonina|Lo Duca|LDCNNN84E24H501R|Sintetico|15213442|VLPDNC71H27H861F|4963754935701|ITALIA|N|TEST|5||Roma|Roma|RM|158
        //Separazione CA |3019681848|1005421319|1005425989|1007848247|200010613357|200010082321|200005932249||||||||||||||||||||||||||||||
        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        for(Integer n=0; n<amount; n++){
            MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            switch on n {
                when 0 {
                    item.Data__c=('Unificazione CA|'+cont[0].SAPContractCode__c+'|'+accountListForCsv+'|'+accs[0].CustomerCode__c+'|||892646689685|IT67K0300203280892646689685|4123|4123124|1|43|N|IT|Bollettino postale|Cartaceo|test@gmail.com|testpec@gmail.com|XML|Stesso sottoscrittore|Antonina|Lo Duca|LDCNNN84E24H501R|Sintetico|15213442|VLPDNC71H27H861F|4963754935701|ITALIA|N|TEST|5||Roma|Roma|RM|158').unescapeCsv();
                }
                when 1 {
                    item.Data__c=('Separazione CA|'+cont[1].SAPContractCode__c+'|'+accountListForCsv+'|'+accs[1].CustomerCode__c+'001;002|'+billingProfList[1].ContractAccountCode__c+'||||||||||||||||||||||||||||||').unescapeCsv();
                }
            }
            itemsList.add(item);
        }
        insert itemsList;
    }
    @IsTest
    static void executeTst() {
        MassiveLoaderRequest__c myBulkRequest=[SELECT Id,ProcessType__c FROM MassiveLoaderRequest__c WHERE ProcessType__c='GestioneBP' WITH SECURITY_ENFORCED LIMIT 1];
        List<MassiveLoaderRequestItem__c> bulkItems=[SELECT Id, Name, MassiveLoaderRequest__c, Account__c, Data__c, Lead__c, NextStepData__c, Result__c, RelatedRequestItem__c, VasOrder__c,Status__c FROM MassiveLoaderRequestItem__c WHERE MassiveLoaderRequest__c=:myBulkRequest.Id];
        HDT_UTL_BpManagement bpManage=new HDT_UTL_BpManagement();
        bpManage.setRequestId(myBulkRequest.Id);
        bpManage.setProcess(myBulkRequest.ProcessType__c);
        bpManage.setMassiveLoaderRequestItemList(bulkItems);
        Test.startTest();
        bpManage.execute();
        Test.stopTest();
        List<Case>caseList=[SELECT Id FROM Case];
        System.assertEquals(false,caseList.isEmpty(),'case list is empty');
    }
}