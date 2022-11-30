@IsTest
private class HDT_UTL_ProcessConsumoAnomaloIdricoTst {

    @TestSetup
    static void makeData(){
        List<Account> acc = HDT_UTL_DataFactoryTst.createAccountResidenziale(2, true, 'HERA COMM', 'D1 - Persona fisica', 'Enti');
        List<ServicePoint__c> servPoint=new List<ServicePoint__c>();
        Integer k=0;
        for(ServicePoint__c sp: HDT_UTL_DataFactoryTst.createServicePoint(3, false)) {
            sp.ServicePointCode__c=sp.ServicePointCode__c+k;
            servPoint.add(sp);
            k++;
        }
        insert servPoint;
        k=0;
        List<Contract> cont = new List<Contract>();
        for(Contract tmp:HDT_UTL_DataFactoryTst.createContract(3, false, acc[0].Id)){
            tmp.ServicePoint__c = servPoint[k].Id;
            tmp.SAPContractCode__c = '301960232'+k;
            cont.add(tmp);
        }
        insert cont;
        HDT_UTL_DataFactoryTst.createContact(1, true, acc[0].Id);
        MassiveLoaderRequest__c request = new MassiveLoaderRequest__c();
        request.TotalRequest__c = 4;
        request.Priority__c = 210;
        request.ProcessType__c = 'ConsumoAnomaloIdrico';
        request.Status__c = 'In attesa di lavorazione';
        insert request;

        List<MassiveLoaderRequestItem__c> itemsList = new List<MassiveLoaderRequestItem__c>();
        for(Integer n=0; n<4; n++){
            MassiveLoaderRequestItem__c item = new MassiveLoaderRequestItem__c();
            item.MassiveLoaderRequest__c = request.Id;
            item.Status__c = 'In attesa di lavorazione';
            switch on n {
                when 0 {
                    //ok
                    item.Data__c='Consumo Anomalo Idrico|'+acc[0].Id+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-20|Y';
                }
                when 1 {
                    //ko on sap code
                    item.Data__c='Consumo Anomalo Idrico|'+acc[0].Id+'|'+cont[n].SAPContractCode__c+'Invalid'+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-20|Y';
                }
                when 2{
                    String tempId=acc[0].Id;
                    tempId=tempId+'0';
                    //ko con accountid
                    item.Data__c='Consumo Anomalo Idrico|'+acc[1].Id+'|'+cont[n].SAPContractCode__c+'|'+servPoint[n].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-20|Y';
                }
                when 3 {
                    //ko missing required field accountId
                    item.Data__c='Consumo Anomalo Idrico|'+''+'|'+cont[2].SAPContractCode__c+'|'+servPoint[2].ServicePointCode__c+'|Protocollo|Da Gestore|Forte Consumo|12331134|2022-11-20|Y';
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
        MassiveLoaderRequest__c myBulkRequestCheck=[SELECT Id,ProcessType__c,RequestKO__c,RequestOK__c FROM MassiveLoaderRequest__c WHERE ProcessType__c='ConsumoAnomaloIdrico' WITH SECURITY_ENFORCED LIMIT 1];
        System.assertEquals(1,myBulkRequestCheck.RequestOK__c,'1 request is ok');
        System.assertEquals(3,myBulkRequestCheck.RequestKO__c,'3 requests are ko');
    }
}