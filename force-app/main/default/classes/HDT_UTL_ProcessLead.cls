public with sharing class HDT_UTL_ProcessLead extends  HDT_UTL_ProcessExecution {
    private Map<String, String> mapLeadFields       ;
    private Map<String, String> mapIndividualFields ;
    private List<Lead> listLead                     ;
    public override void checks(){
        mapFieldsObject();
        Integer count=0;
        for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
            if(String.isNotBlank(mapLeadFields.get(mapHeaderByPosition.get(count))) ){
                mapTypeField(currentProcess.currentLead,mapLeadFields,count,tempField);
            }
           
            count++;
        }
        if (String.isBlank( currentProcess.currentLead.Company)) {
            currentProcess.currentLead.Company=currentProcess.currentLead.FirstName+currentProcess.currentLead.LastName;
        }
        system.debug('currentProcess.currentLead '+currentProcess.currentLead);
    }

    public override void getRecords(){
        if (String.isNotBlank(currentProcess.currentLead.FirstName)&&String.isNotBlank(currentProcess.currentLead.LastName)&& String.isNotBlank(currentProcess.currentLead.CompanyOwner__c) ) {
            listLead =HDT_QR_Lead.getCurrentRecords(currentProcess.currentLead.FirstName, currentProcess.currentLead.LastName, currentProcess.currentLead.CompanyOwner__c);
        }
        System.debug('listLead.size '+listLead.size());
       
    }

    public override void registryCreation(){

       
        if (listLead.size()>0) {
            Lead oldLead=listLead.get(0);
            for (String tempField : mapLeadFields.values()) {
                if ( String.isBlank(String.valueOf(oldLead.get(tempField)))) {
                    oldLead.put(tempField,currentProcess.currentLead.get(tempField));
                }
            }
            oldLead.LeadReceptionDate__c=currentProcess.currentLead.LeadReceptionDate__c;
            currentProcess.currentLead=oldLead;
            update currentProcess.currentLead;
        }
        else {
            insert currentProcess.currentLead;
        }
    }


    public override void finalUpdate(){

    }


    private void mapFieldsObject(){
        List<HDT_MassiveFieldsObjectMap__mdt> listLeadFields = getMapFieldsObject('Lead', this.processName);
        mapLeadFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt temp : listLeadFields){
            system.debug('temp Map '+temp.labelField__c);
            mapLeadFields.put(temp.labelField__c, temp.nameField__c);
        }
        List<HDT_MassiveFieldsObjectMap__mdt> listIndividualFields = getMapFieldsObject('Individual', this.processName);
        mapIndividualFields = new Map<String, String>();
        for(HDT_MassiveFieldsObjectMap__mdt temp : listIndividualFields){
            mapIndividualFields.put(temp.labelField__c, temp.nameField__c);
        }

    }
}
