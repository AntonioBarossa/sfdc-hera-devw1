public with sharing class HDT_UTL_ProcessLead extends  HDT_UTL_ProcessExecution {
    private Map<String, String> mapLeadFields       ;
    private Map<String, String> mapIndividualFields ;
    private List<Lead> listLead                     ;
    public override void checks(){
        mapFieldsObject();
        Integer count=0;

        for (String tempField : currentProcess.currentRequestItem.Data__c.split(',')) {
            if(String.isNotBlank(mapLeadFields.get(mapHeaderByPosition.get(count)))&& String.isNotBlank(tempField) ){
                mapTypeField(currentProcess.currentLead,mapLeadFields,count,tempField);
            }
            if(String.isNotBlank(mapIndividualFields.get(mapHeaderByPosition.get(count)))&& String.isNotBlank(tempField) ){
                mapTypeField(currentProcess.currentIndividual,mapIndividualFields,count,tempField);
            }
           
            count++;
        }

        if (String.isBlank( currentProcess.currentLead.Company)) {
            currentProcess.currentLead.Company=currentProcess.currentLead.FirstName+currentProcess.currentLead.LastName;
        }
    }

    public override void getRecords(){
        if (String.isNotBlank(currentProcess.currentLead.FirstName)&&String.isNotBlank(currentProcess.currentLead.LastName)&& String.isNotBlank(currentProcess.currentLead.CompanyOwner__c) ) {
            listLead =HDT_QR_Lead.getCurrentRecords(currentProcess.currentLead.FirstName, currentProcess.currentLead.LastName, currentProcess.currentLead.CompanyOwner__c);
        }
       
    }

    public override void registryCreation(){

       
        if (listLead!=null && listLead.size()>0) {
            Lead oldLead=listLead.get(0);
            for (String tempField : mapLeadFields.values()) {
                if ( String.isBlank(String.valueOf(oldLead.get(tempField))) ||'LeadValidityEndDate__c'.equalsIgnoreCase(tempField)) {
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

        List<Lead> listAfterInsert              = HDT_QR_Lead.getCurrentRecords(currentProcess.currentLead.FirstName, currentProcess.currentLead.LastName, currentProcess.currentLead.CompanyOwner__c);
        currentProcess.currentLead              = listAfterInsert.get(0);
        currentProcess.currentIndividual.id     = currentProcess.currentLead.IndividualId;
        system.debug('currentProcess.currentIndividual: '+currentProcess.currentIndividual);
        update currentProcess.currentIndividual;

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
