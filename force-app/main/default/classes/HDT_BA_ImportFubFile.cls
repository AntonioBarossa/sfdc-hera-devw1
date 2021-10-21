public with sharing class HDT_BA_ImportFubFile implements Database.Batchable<SObject> {
    public String FUBProcessingId;
    public String csvNumbers;
    public Date todayDate = Date.today();
    public List<CampaignMember> campaignMembers = new List<CampaignMember>();
    public List<ContactPointPhone> contactPointPhoneNumbers = new List<ContactPointPhone>();
    public List<ContactPointPhone> contactPointPhoneNumbersKO = new List<ContactPointPhone>();

    public HDT_BA_ImportFubFile(String FUBProcessingId,String csvNumbers){
        this.FUBProcessingId = FUBProcessingId;
        this.csvNumbers = csvNumbers;
    }


    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Name,PhoneNumber__c,ExcludeFub__c,Contact.IndividualId FROM CampaignMember WHERE ExcludeFub__c != \'Si\' AND Agency__c != null AND CampaignId  IN ( SELECT Campaign__c  FROM FUBProcessingItem__c WHERE FUBProcessing__c = :FUBProcessingId) AND Contact.IndividualId != null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<CampaignMember> scope) {

        List<String> splitCsv = csvNumbers.split(',');
        System.debug('********:' + splitCsv);
        List<String> okList = new List<String>();
        List<String> koList = new List<String>();
        Map<String,String> maStr = new Map<String,String>();
        List<String> contactList = new List<String>();
        for(String s : splitCsv){
            maStr.put(s,s);
        }
        System.debug('*****:+' + maStr);
        for(CampaignMember cm : scope) {
            System.debug('*****:+' + cm.PhoneNumber__c);
            if(maStr.get(cm.PhoneNumber__c) != null){
                System.debug('*****:+' + cm.PhoneNumber__c);
                cm.OutcomeFub__c = 'OK';
                cm.OutcomeDateFub__c = todayDate;
                campaignMembers.add(cm);
                contactList.add(cm.Contact.IndividualId);
                okList.add(cm.PhoneNumber__c);
            }
            else {
                cm.OutcomeFub__c = 'KO';
                cm.OutcomeDateFub__c = todayDate;
                campaignMembers.add(cm);
                koList.add(cm.Contact.IndividualId);
            }
        }
        System.debug('*****:+' + campaignMembers);
        update campaignMembers;

        //iterate ContactPointPhone
        Database.QueryLocator query = Database.getQueryLocator('SELECT Id, Name FROM ContactPointPhone WHERE parentId IN :contactList AND TelephoneNumber IN :okList');
        Database.QueryLocatorIterator it =  query.iterator();

        while (it.hasNext())
        {
            ContactPointPhone cpp = (ContactPointPhone)it.next();
            cpp.LastOutcomeFUB__c = 'OK';
            cpp.LastResultDateFUB__c = todayDate;
            contactPointPhoneNumbers.add(cpp);
        }

        Database.QueryLocator queryKo = Database.getQueryLocator('SELECT Id, Name FROM ContactPointPhone WHERE parentId IN :koList');
        Database.QueryLocatorIterator itKo =  queryKo.iterator();

        while (itKo.hasNext())
        {
            ContactPointPhone cpp = (ContactPointPhone)itKo.next();
            cpp.LastOutcomeFUB__c = 'KO';
            cpp.LastResultDateFUB__c = todayDate;
            contactPointPhoneNumbersKO.add(cpp);
        }

        update contactPointPhoneNumbers;
        update contactPointPhoneNumbersKO;
    }

    public void finish(Database.BatchableContext bc){
        //update FUBProcessing Status
        Database.QueryLocator queryFub = Database.getQueryLocator('SELECT Status__c FROM FUBProcessing__c WHERE Id = :FUBProcessingId');
        Database.QueryLocatorIterator itFub =  queryFub.iterator();
        FUBProcessing__c fubProcessing = new FUBProcessing__c();
        while (itFub.hasNext()) {
            fubProcessing = (FUBProcessing__c)itFub.next();
            fubProcessing.Status__c = 'Archivio FUB importato';
        }
        update fubProcessing;
    }
}