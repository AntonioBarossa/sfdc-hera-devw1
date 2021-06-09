public with sharing class HDT_UTL_Individual {
   
    
    // public static Individual createIndividualContact (Id ContactId) {

    //     Contact cont = HDT_QR_Contact.getRecordById(String.valueOf(ContactId));

    //     Individual individual =new Individual(LastName = cont.LastName ,FirstName = cont.firstName);
    //     HDT_SRV_Individual.checkCreateAccess(individual);
    //     Individual indv= HDT_SRV_Individual.createRecord(individual);
    //     Contact contact=new Contact(Id=ContactId,IndividualId=indv.id);
    //     HDT_SRV_Contact.checkUpdateAccess(contact);
    //     HDT_SRV_Contact.updateRecord(contact);
    //     return indv;
    // }

    public static List<Individual> createIndividualContact (List<String> contactIds) {
        HDT_SRV_Contact contactSrv= new HDT_SRV_Contact();
        HDT_QR_Contact contactQr = new HDT_QR_Contact();
        List<Contact> contacts = contactQr.getRecordsById(contactIds);
        List<Individual> inds= new List<Individual>();
        List<Contact> updateContacts= new List<Contact>();
        List<wrapContactIndi> listWrapInd = new List<wrapContactIndi>();
        Map<String,Individual> mapCheck = new Map<String,individual>();
        for(Contact c: contacts){
            Individual individual =new Individual(LastName = c.LastName,FirstName = c.firstName);
            inds.add(individual);
            mapCheck.put(c.id,individual);
            /*wrapContactIndi wr = new wrapContactIndi();
            wr.c = c;
            wr.i = individual;*/
        }
        List<Individual> indv= HDT_SRV_Individual.createRecord(mapCheck.values());
        for(Contact c :contacts){
            if(mapCheck.get(c.Id) != null){
                c.IndividualId = mapCheck.get(c.Id).id;
            }
            /*for(Individual i: indv){
                if(c.LastName== i.lastname && c.firstname == i.firstname){
                    Contact contact=new Contact(Id=c.Id, IndividualId=i.Id);
                    updateContacts.add(contact);
                }
            }*/
        }
        contactSrv.updateRecord(updateContacts);
        return indv;
    }
    public class wrapContactIndi{
        public Contact c;
        public Individual i;
    }
    /**
     * @author Elfrida Kora(elfrida.kora@dunegroup.it)
     * @description make update,create,check fields
     */

    // public static Individual createIndividualLead (Id LeadId) {

    //     Lead l = HDT_QR_Lead.getRecordById(String.valueOf(LeadId));

    //     Individual individual =new Individual(LastName = l.LastName,FirstName = l.firstName);
    //     HDT_SRV_Individual.checkCreateAccess(individual);
    //     Individual indv= HDT_SRV_Individual.createRecord(individual);
    //     Lead lead=new Lead(Id=LeadId, IndividualId=indv.id);
    //     HDT_SRV_Lead.checkUpdateAccess(lead);
    //     HDT_SRV_Lead.updateRecord(lead);
    //     return indv;
    // }
    public static List<Individual> createIndividualLead (List<String> leadIds) {
        HDT_QR_Lead leadQr = new HDT_QR_Lead();
        List<Lead> leads = leadQr.getRecordsById(leadIds);
        List<Individual> inds= new List<Individual>();
        List<Lead> updateLeads= new List<Lead>();
        for(Lead l: leads){
            Individual individual =new Individual(LastName = l.LastName,FirstName = l.firstName);
            inds.add(individual);
        }
        List<Individual> indv= HDT_SRV_Individual.createRecord(inds);
        for(Lead l :leads){
            for(Individual i: indv){
                if(l.LastName== i.LastName){
                    Lead lead=new Lead(Id=l.Id, IndividualId=i.Id);
                    updateLeads.add(lead);
                }
            }
        }
        HDT_SRV_Lead.updateRecord(updateLeads);
        return indv;
    }

    public static void updatePrivacy(Map<String,object> indv){
        Individual ind= new Individual();
        for(String field: indv.keySet()){
            ind.put(field,indv.get(field));
                 
        }
        HDT_SRV_Individual.updateRecord(ind);

    }

    public static void updateConsensoMarketingPrivacy(Individual indv,String VersioneInformativaMarketing,String FonteConsensoMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing ) {
        Individual ind =new Individual(Id = indv.id ,  MarketingPrivacyVersion__c = VersioneInformativaMarketing ,PrivacyMarketingChoiceSource__c = FonteConsensoMarketing ,
         PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing ,MarketingCompanyConsent__c = CompanyConsensoMarketing);
        
                
        HDT_SRV_Individual.checkCreateAccess(indv);
        Individual indvid= HDT_SRV_Individual.updateRecord(indv);

    }

    public static void updateConsensoProfilazionePrivacy(Individual indv,String VersioneInformativaProfilazione,String FonteConsensoProfilazione,String IniziativaConsensoProfilazione,Date DataConsensoProfilazione,String CompanyConsensoProfilazione ) {
        Individual ind =new Individual(Id=indv.id ,ProfilingPrivacyVersion__c = VersioneInformativaProfilazione,PrivacyProfilingChoiceSource__c = FonteConsensoProfilazione,PrivacyProfilingConsentInitiative__c = IniziativaConsensoProfilazione,
        PrivacyProfilingChoiceDate__c = DataConsensoProfilazione,ProfilingCompanyConsent__c = CompanyConsensoProfilazione);
        

        HDT_SRV_Individual.checkCreateAccess(indv);
        Individual individ= HDT_SRV_Individual.updateRecord(indv);
     }

     public static Individual modifyContentPrivacyMarketing(Individual indv,String VersioneInformativaMarketing,String FonteConsensoMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing ){
         Individual ind = new Individual(Id = indv.id, MarketingPrivacyVersion__c = VersioneInformativaMarketing, PrivacyMarketingChoiceSource__c = FonteConsensoMarketing ,
         PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing ,MarketingCompanyConsent__c = CompanyConsensoMarketing);

         HDT_SRV_Individual.checkCreateAccess(indv);
           return indv;
       }

     public static Individual modifyContentPrivacyProfiling(Individual indv,String VersioneInformativaProfilazione,String FonteConsensoProfilazione,String IniziativaConsensoProfilazione,Date DataConsensoProfilazione,String CompanyConsensoProfilazione){
         Individual ind =new Individual(Id=indv.id ,ProfilingPrivacyVersion__c = VersioneInformativaProfilazione,PrivacyProfilingChoiceSource__c = FonteConsensoProfilazione,PrivacyProfilingConsentInitiative__c = IniziativaConsensoProfilazione,
         PrivacyProfilingChoiceDate__c = DataConsensoProfilazione,ProfilingCompanyConsent__c = CompanyConsensoProfilazione);

         HDT_SRV_Individual.checkCreateAccess(indv);
           return indv;
     }

     public static Individual modifyContentPrivacyThirdParty(Individual indv,String Versioneinformativaconsensodatiater,String Fonteconsensodatiaterzi,String Iniziativaconsensodatiaterzi,Date Dataconsensodatiaterzi,String Companyconsensodatiatrezi){
        Individual ind =new Individual(Id=indv.id,ThirdPartyPrivacyVersion__c = Versioneinformativaconsensodatiater,PrivacyThirdPartyChoiceSource__c = Fonteconsensodatiaterzi,
        PrivacyThirdPartyConsentInitiative__c = Iniziativaconsensodatiaterzi, ThirdPartyCompanyConsent__c = Companyconsensodatiatrezi);

        HDT_SRV_Individual.checkCreateAccess(indv);
         return indv;

     }


     private static Individual instanceDefaultIndividual(){

        individual ind = new Individual();
        return ind;
     }

     public static Contact convertLeadToContact(Id contactId,Id individualId){
        Contact cont = new Contact (Id=ContactId,IndividualId = individualId);
         
        return cont;
     }

     public static individual modifyFieldValue(Map<String,Object> mapFields, Id individualId){
        Individual indv = new individual();
        for(String field :mapFields.keySet()){
            
            indv.put(field,mapFields.get(field));
        }
         return indv;
     }

}
