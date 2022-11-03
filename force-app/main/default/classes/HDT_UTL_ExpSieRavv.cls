/**
 * @description       : 
 * @author            : Giacinto Florio
 * @group             : 
 * @last modified on  : 03-11-2022
 * @last modified by  : Giacinto Florio
**/
public with sharing class HDT_UTL_ExpSieRavv {

    static String vNomeOperandoReale;
    static String vNomeOperandoReale2;
    static String vNomeOperandoFittizio;
    static String vNomeOperandoFittizio2;
    static String vNewValoreOperando;

    @AuraEnabled(cacheable=false)
    public static void createExportSobjects(HDT_WRP_SieExport wrapper){
        //cancellare gli esistenti record di ravvedimento operoso
        HDT_UTL_DatabaseService.deleteSObject([Select id From ExpRavv__c Where Case__c =:wrapper.record.Id OR Order__c =:wrapper.record.Id]);
        //creare e inserire i nuovi
        List<ExpRavv__c> exportObjectsToInsert = getExportRavv(wrapper);
        HDT_UTL_DatabaseService.insertSObject(exportObjectsToInsert);
        return;
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

    private with sharing class HDT_UTL_SieSobjectCreation{
        HDT_WRP_SieExport wrapper {get;set;}
        String sobjectTypeName {get;set;}
        HDT_UTL_SieSobjectCreation(HDT_WRP_SieExport wrapper){
            this.wrapper=wrapper;
            this.sobjectTypeName = wrapper.record.Id.getSobjectType().getDescribe().getName().toLowerCase();
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
            return exportRecord;
        }
    }

    private static List<ExpRavv__c> getExportRavv(HDT_WRP_SieExport wrapper){
        HDT_UTL_SieSobjectCreation createSobjUtl = new HDT_UTL_SieSobjectCreation(wrapper);
        List<ExpRavv__c> listToInsert = new List<ExpRavv__c>();

        if('order'.equalsIgnoreCase(createSobjUtl.getSobjectType())){
            if(!'X'.equalsIgnoreCase(wrapper.period)){
                Order ord = (Order) wrapper.record;
                if( !'A'.equalsIgnoreCase(ord.BillingCategory__c)){
                    String nomeOperando = 'TRSOSP0000';
                    String valoreOperando = 'TSCFM';
                    listToInsert.add(createSobjUtl.createExpRavv(nomeOperando,valoreOperando));
                }
            }
        }
        else if('case'.equalsIgnoreCase(createSobjUtl.getSobjectType())){
            caseSieExp(createSobjUtl, listToInsert);
        }
        return listToInsert;
    }

    @SuppressWarnings('PMD.ifelsestmtsmustusebraces, PMD.ifstmtsmustusebraces')
    private static void caseSieExp(HDT_UTL_SieSobjectCreation createSobjUtl, List<ExpRavv__c> listToInsert){
        String vNomeOperando;
        String vValoreOperando;

        HDT_WRP_SieExport wrapper = createSobjUtl.getWrapper();
        Case caso = (Case) wrapper.record;
        if(('X'.equalsIgnoreCase(wrapper.period) || 'A'.equalsIgnoreCase(caso.BillingCategory__c)))     return;

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
        if('Y'.equalsIgnoreCase(wrapper.period)){
            if(!(wrapper.missingDue> 0)){   //SE mancatoDovuto Assente
                if(caso.Subprocess__c.equalsIgnoreCase('Superficie') 
                    || caso.Subprocess__c.equalsIgnoreCase('DOM_Componenti non residenti')
                    || caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi')){
                        
                    vNomeOperando=vNomeOperandoFittizio;
                    vValoreOperando=vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoFittizio2,vValoreOperando));

                    vNomeOperando=vNomeOperandoReale;
                    vValoreOperando='OLD';
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));

                    vValoreOperando=vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));


                    if('B'.equalsIgnoreCase(caso.BillingCategory__c)){
                        listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando)); 
                        if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                    }
                }

            } 
            else{   //SE mancatoDovuto Presente: 

                if(caso.Subprocess__c.equalsIgnoreCase('Superficie') || caso.Subprocess__c.equalsIgnoreCase('DOM_Componenti non residenti')){
                    vNomeOperando=vNomeOperandoFittizio;
                    vValoreOperando=vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando, vValoreOperando));

                    //if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoFittizio2,vValoreOperando));
                    //cannever be truth

                    vNomeOperando=vNomeOperandoReale;
                    vValoreOperando='OLD';
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando, vValoreOperando));
                    //if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                    //cannever be truth

                    vValoreOperando=vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando, vValoreOperando));
                    //if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                    //cannever be truth

                    if('B'.equalsIgnoreCase(caso.BillingCategory__c)){
                        listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando, vValoreOperando));
                        //if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                        //cannever be truth
                    }
                }                    
            }
        }
        if('z'.equalsIgnoreCase(wrapper.period)){
            if(!(wrapper.missingDue> 0)){  //SE mancatoDovuto Assente, !>0 contempla anche il caso null
                if(caso.Subprocess__c.equalsIgnoreCase('Superficie') 
                    || caso.Subprocess__c.equalsIgnoreCase('DOM_Componenti non residenti') 
                    || caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi')){
                    
                    vNomeOperando = vNomeOperandoFittizio;
                    vValoreOperando = vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoFittizio2,vValoreOperando));
                    
                    vNomeOperando=vNomeOperandoReale;
                    vValoreOperando='OLD';
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));

                    vValoreOperando = vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi'))     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                }
            }else{  //SE mancatoDovuto Presente
                if(caso.Subprocess__c.equalsIgnoreCase('Superficie') || caso.Subprocess__c.equalsIgnoreCase('DOM_Componenti non residenti')){
                    vNomeOperando = vNomeOperandoFittizio;
                    vValoreOperando = vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                
                    // if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi')){
                    //     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoFittizio2,vValoreOperando));
                    // }
                    vNomeOperando = vNomeOperandoReale;
                    vValoreOperando = 'OLD';
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    // if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi')){
                    //     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                    // }
                    vValoreOperando = vNewValoreOperando;
                    listToInsert.add(createSobjUtl.createExpRavv(vNomeOperando,vValoreOperando));
                    // if(caso.Subprocess__c.equalsIgnoreCase('NON DOM_ISTAT/Ronchi')){
                    //     listToInsert.add(createSobjUtl.createExpRavv(vNomeOperandoReale2,vValoreOperando));
                    // }
                }
            }
            //}
        }
        
    }

}