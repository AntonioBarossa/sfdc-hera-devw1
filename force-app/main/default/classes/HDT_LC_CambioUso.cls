public with sharing class HDT_LC_CambioUso {

    private static HDT_QR_Case caseQr = new HDT_QR_Case();
    private static HDT_QR_ServicePoint srvQr = new HDT_QR_ServicePoint(); 
    private static HDT_SRV_Case caseSrv = new HDT_SRV_Case();
   // private static HDT_QR_CausalCodeCalculation causalCodeQR = new HDT_QR_CausalCodeCalculation();

    @AuraEnabled
    public static boolean updateCase(String caseId,String addebito,string tipoFornitura,String recapito,string tipoImpianto,boolean residente,string note){
        boolean res = true;
        HDT_SRV_Case caseSrv = new HDT_SRV_Case();
        System.debug('*****2:');
        Case c1 = caseQr.getRecordByIdCambioUso(caseId);
        List<ServicePoint__c> srv = srvQr.getRecordById(c1.servicepoint__c,'id,CommoditySector__c,SupplyCity__c,Account__r.CustomerMarking__c,distributor__r.code__c');
        try{
            System.debug('*****1:' + srv);
            Map<String,String> agc = HDT_UTL_Sales.getAgentNameAndCode(srv[0],srv[0].Account__r.CustomerMarking__c);
            //HDT_CausalCodeCalculation__mdt mcc = causalCodeQR.calculateCausalCode();
            Case c = new case(); 
            c.id = caseId;
            System.debug('*****3:');
            c.SupplyType__c = tipoFornitura;
            c.UseChangeCharge__c = addebito;
            c.PhoneNumber__c = recapito;
            c.ServicePointType__c = tipoImpianto;
            c.SalesCompanyCode__c = agc.get('codiceAgente');
            c.SalesCompany__c = agc.get('nomeAgente');
            c.distributorCode__c = srv[0].distributor__r.code__c;
            c.CausalCode__c = 'CAU';
            c.Resident__c = residente;
            c.Note__c = note;
            System.debug('*****4:');
            c.phase__c = 'Da Inviare';
            c.status = 'In Lavorazione';
            caseSrv.updateRecord(c);
            
        }
        catch(Exception e){
            res = false;
        }
        return res; 
    }
}