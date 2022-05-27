@SuppressWarnings('PMD.AvoidDebugStatements, PMD.ClassNamingConventions, PMD.ExcessiveParameterList, PMD.IfElseStmtsMustUseBraces, PMD.IfStmtsMustUseBraces, PMD.LocalVariableNamingConventions')
public inherited sharing class HDT_UTL_SlaManagement {
    
    private Set<Id> recordIdList;
    private Set<Id> slaAdminIds;
    private List<HDT_WRP_SlaManagement.HDT_WRP_sObject> wrpCaseList;
    private List<SlaTracking__c> trackingRecordsList;

    public HDT_UTL_SlaManagement() {
        System.debug('>>> HDT_UTL_SlaManagement...');
    }

    public void setRecordIds(Set<Id> recordIdList){
        this.recordIdList = recordIdList;
    }

    public void setChangedObjList(List<HDT_WRP_SlaManagement.HDT_WRP_sObject> wrpCaseList){
        this.wrpCaseList = wrpCaseList;
    }
    
    public void manageInsert(){
        for(HDT_WRP_SlaManagement.HDT_WRP_sObject wrpc : wrpCaseList){
            System.debug('>>> ' + String.valueOf(wrpc));
        }
    }

    public void manageUpdate(){
        for(HDT_WRP_SlaManagement.HDT_WRP_sObject wrpc : wrpCaseList){
            System.debug('>>> ' + String.valueOf(wrpc));
        }
    }

    public void getTrackingRecords(){
        trackingRecordsList = new List<SlaTracking__c>();
        trackingRecordsList = [
            SELECT Id, Activity__c, SlaAdministration__c, Case__c, EndDateTime__c, StartDateTime__c, Description__c,
                   SlaName__c, Order__c, Status__c, Name
            FROM SlaTracking__c
            WHERE Case__c IN :recordIdList
        ];

        slaAdminIds = new Set<Id>();
        for(SlaTracking__c track : trackingRecordsList){
            slaAdminIds.add(track.SlaAdministration__c);
        }

    }

    public static List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin> buildSlaRules(List<Id> slaAdminId){
        
        List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin> slaAdminRules = new List<HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin>();

        List<SlaAdministration__c> slaAdminList = [ 
            SELECT Id, CaseField__c, OrderField__c, Cluster__c, CompanyOwner__c, CreatedById, EndDate__c, StartDate__c,
                   Description__c, EndCasePhase__c, StartCasePhase__c, Range__c, LastModifiedById, Name, OwnerId, Process__c,
                   RecordTypeId, Commodity__c, SalesCompany__c, CustomerType__c, RangeType__c, Type__c
            FROM SlaAdministration__c
            WHERE Id IN :slaAdminId
            AND IsActive__c = true
        ];

        if(slaAdminList.size() == 0){
            return slaAdminRules;
        }

        HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin slaMgmt;
        for(SlaAdministration__c slaAdmin : slaAdminList){
            slaMgmt = new HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin();
            slaMgmt = buildSingleRule(slaMgmt, slaAdmin);
            slaAdminRules.add(slaMgmt);
        }

        return slaAdminRules;

    }

    public static HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin buildSingleRule(HDT_WRP_SlaManagement.HDT_WRP_SlaAdmin slaMgmt, SlaAdministration__c slaAdmin){

        slaMgmt.slaAdminId = slaAdmin.Id;

        switch on slaAdmin.Type__c {
            when '01' {
                // Transizione Fasi Case
                slaMgmt.startRule.isDate = false;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = 'Phase__c';
                slaMgmt.startRule.value = slaAdmin.StartCasePhase__c;

                slaMgmt.endRule.isDate = false;
                slaMgmt.endRule.obj = 'Case';
                slaMgmt.endRule.field = 'Phase__c';
                slaMgmt.endRule.value = slaAdmin.EndCasePhase__c;
            }	
            when '02' {
                // Data presente sul Case –> Apertura Activity
                slaMgmt.startRule.isDate = true;
                slaMgmt.startRule.obj = 'Case';
                slaMgmt.startRule.field = 'CaseField__c';
                slaMgmt.startRule.value = slaAdmin.CaseField__c;

                slaMgmt.endRule.isDate = true;
                slaMgmt.endRule.obj = 'Activity';
                slaMgmt.endRule.field = '';
                slaMgmt.endRule.value = '';
            }
            when '03' {
                // Data presente sul Case –> Chiusura Activity
            }	
            when '04' {
                // Data presente sul Case –> Fase Case             
            }
        }

        return slaMgmt;
    }

}