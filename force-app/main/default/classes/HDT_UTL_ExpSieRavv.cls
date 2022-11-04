/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 03-11-2022
 * @last modified by  : Giacinto Florio
**/
@SuppressWarnings('PMD.ifelsestmtsmustusebraces, PMD.ifstmtsmustusebraces')
public with sharing class HDT_UTL_ExpSieRavv {

    private static String vNomeOperando;
    private static String vValoreOperando;

    @AuraEnabled(cacheable=false)
    public static void createExportSobjects(HDT_WRP_SieExport wrapper){
        //cancellare gli esistenti record di ravvedimento operoso
        HDT_UTL_DatabaseService.deleteSObject([Select id From ExpRavv__c Where Case__c =:wrapper.record.Id OR Order__c =:wrapper.record.Id]);
        //creare e inserire i nuovi
        List<ExpRavv__c> exportObjectsToInsert = getExportRavv(wrapper);
        if(exportObjectsToInsert?.isEmpty() == false)   HDT_UTL_DatabaseService.insertSObject(exportObjectsToInsert);
        return;
    }


    private static List<ExpRavv__c> getExportRavv(HDT_WRP_SieExport wrapper){
        HDT_UTL_SieSobjectCreation createSobjUtl = new HDT_UTL_SieSobjectCreation(wrapper);

        if('order'.equalsIgnoreCase(createSobjUtl.getSobjectType())){
            Order ord = (Order) wrapper.record;
            if(('X'.equalsIgnoreCase(wrapper.period) || 'A'.equalsIgnoreCase(ord.BillingCategory__c)))     return null;
            
            String nomeOperando = 'TRSOSP0000';
            String valoreOperando = 'TSCFM';
            createSobjUtl.createExpRavv(nomeOperando,valoreOperando);
        }
        else if('case'.equalsIgnoreCase(createSobjUtl.getSobjectType())){
            caseSieExp(createSobjUtl);
        }
        return createSobjUtl.listToInsert;
    }
    
    private static void caseSieExp(HDT_UTL_SieSobjectCreation createSobjUtl){

        HDT_WRP_SieExport wrapper = createSobjUtl.getWrapper();
        Case caso = (Case) wrapper.record;
        if(('X'.equalsIgnoreCase(wrapper.period) || 'A'.equalsIgnoreCase(caso.BillingCategory__c)))     return;

        HDT_WRP_Operandi operands = new HDT_WRP_Operandi(caso);

        Set<String> subprocesses = new Set<String>{'Superficie', 'DOM_Componenti non residenti', 'NON DOM_ISTAT/Ronchi'};
        if(!(subprocesses.contains(caso.Subprocess__c)))    return;
        //Per variazioni, i processi ammessi sono solo 3

        if(wrapper.missingDue> 0 && 'NON DOM_ISTAT/Ronchi'.equalsIgnoreCase(caso.Subprocess__c))    return;
        //Inoltre se mancato dovuto presente, il processo non deve essere istat/ronchi

        if('Y'.equalsIgnoreCase(wrapper.period) || 'z'.equalsIgnoreCase(wrapper.period)){
            populateList(createSobjUtl, operands);                   
        }
        
    }

    private static void populateList(HDT_UTL_SieSobjectCreation createSobjUtl, HDT_WRP_Operandi operands){
        Case caso = (Case) createSobjUtl.getWrapper().record;
        vNomeOperando = operands.vNomeOperandoFittizio;
        vValoreOperando = operands.vNewValoreOperando;
        createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando);
        if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     createSobjUtl.createExpRavv(operands.vNomeOperandoFittizio2,vValoreOperando);
        
        vNomeOperando=operands.vNomeOperandoReale;
        vValoreOperando='OLD';
        createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando);
        if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     createSobjUtl.createExpRavv(operands.vNomeOperandoReale2,vValoreOperando);

        vValoreOperando = operands.vNewValoreOperando;
        createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando);
        if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     createSobjUtl.createExpRavv(operands.vNomeOperandoReale2,vValoreOperando);

        if('y'.equalsIgnoreCase(createSobjUtl?.getWrapper()?.period) && 'B'.equalsIgnoreCase(caso.BillingCategory__c)){
            createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando); 
            if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     createSobjUtl.createExpRavv(operands.vNomeOperandoReale2,vValoreOperando);
        }
    }

    private with sharing class HDT_UTL_SieSobjectCreation{
        HDT_WRP_SieExport wrapper {get;set;}
        String sobjectTypeName {get;set;}
        List<ExpRavv__c> listToInsert {get;set;}
        HDT_UTL_SieSobjectCreation(HDT_WRP_SieExport wrapper){
            this.wrapper=wrapper;
            this.sobjectTypeName = wrapper.record.Id.getSobjectType().getDescribe().getName().toLowerCase();
            this.listToInsert = new List<ExpRavv__c>();
        }

        private String getSobjectType(){
            return this.sobjectTypeName;
        }

        private HDT_WRP_SieExport getWrapper(){
            return this.wrapper;
        }

        @SuppressWarnings('PMD.ExcessiveParameterList')
        ExpRavv__c createExpRavv(String operandName, String operandValue){
            ExpRavv__c exportRecord = new ExpRavv__c();
            exportRecord.OperandName__c = operandName;
            exportRecord.OperandValue__c = operandValue;

            String billingCategory = (String) this.wrapper.record.get('BillingCategory__c');
            exportRecord.SuspensionEndDate__c = this.wrapper.declarationDate.addDays(-1).format();
            if(!'y'.equalsIgnoreCase(wrapper.period) || 'C'.equalsIgnoreCase(billingCategory) ){    
                exportRecord.SuspensionStartDate__c = this.wrapper.effectiveDate.format();  
            }else if('B'.equalsIgnoreCase(billingCategory)){
                exportRecord.SuspensionStartDate__c = this.wrapper.limitDateX.format();
            }

            exportRecord.CityCode__c = this.wrapper.cityCode;
            switch on this.sobjectTypeName {
                when 'case' {
                    exportRecord.Case__c=this.wrapper.record.Id;
                }
                when 'order' {
                    exportRecord.Order__c=this.wrapper.record.Id;
                }
            }
            this.listToInsert.add(exportRecord);
            return exportRecord;
        }
    }

    public with sharing class HDT_WRP_SieExport{
        @AuraEnabled public String period {get;set;}
        @AuraEnabled public String subtype {get;set;}
        @AuraEnabled public String cityCode {get;set;}
        @AuraEnabled public Date declarationDate {get;set;}
        @AuraEnabled public Date effectiveDate {get;set;}
        @AuraEnabled public Date limitDateX {get;set;}
        @AuraEnabled public Sobject record {get;set;}
        @AuraEnabled public Integer missingDue  {
            get { return missingDue > 0 ? 1 : 0; }
            set { missingDue = value; }
        }
    }

    private with sharing class HDT_WRP_Operandi{
        String vNomeOperandoReale;
        String vNomeOperandoReale2;
        String vNomeOperandoFittizio;
        String vNomeOperandoFittizio2;
        String vNewValoreOperando;
    
        HDT_WRP_Operandi(Case caso){
            switch on caso.Subprocess__c {
                when 'Superficie' {
                    vNomeOperandoReale = 'TFSC000000';
                    vNomeOperandoFittizio ='TFSCRAV000';
                    vNewValoreOperando = caso.DeclaredArea__c.format();
                }
                when 'DOM_Componenti non residenti' {
                    vNomeOperandoReale = 'TRSOSP0000';
                    vNomeOperandoFittizio ='TFNCERAV00';
                    vNewValoreOperando = caso.NotResidentMembers__c.format();
                }
                when 'NON DOM_ISTAT/Ronchi' 
                {
                    vNomeOperandoReale = 'TRSOSP0000';
                    vNomeOperandoReale2 ='TUSCATCOM0';
                    vNomeOperandoFittizio ='TUCATCMRAV';
                    vNomeOperandoFittizio2 ='TUSCATRAV0';
                    vNewValoreOperando = caso.RonchiCode__c;
                }
            }
        }
    }

}