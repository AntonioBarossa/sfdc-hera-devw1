/**
 * @author 'Sabina Levonja' (sabina.levonja@dunegroup.it)
 * @description HDT_UTL_Individual - 
 */

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
        //List<wrapContactIndi> listWrapInd = new List<wrapContactIndi>();
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
    public static List<Individual> createIndividualContact (List<Contact> contactIds) {
        HDT_SRV_Contact contactSrv= new HDT_SRV_Contact();
        //HDT_QR_Contact contactQr = new HDT_QR_Contact();
        //List<Contact> contacts = contactQr.getRecordsById(contactIds);
        List<Individual> inds= new List<Individual>();
        List<Contact> updateContacts= new List<Contact>();
        //List<wrapContactIndi> listWrapInd = new List<wrapContactIndi>();
        Map<String,Individual> mapCheck = new Map<String,individual>();
        for(Contact c: contactIds){
            Individual individual =new Individual(LastName = c.LastName,FirstName = c.firstName,CompanyOwner__c = c.CompanyOwner__c);
            inds.add(individual);
            mapCheck.put(c.id,individual);
            /*wrapContactIndi wr = new wrapContactIndi();
            wr.c = c;
            wr.i = individual;*/
        }
        List<Individual> indv= HDT_SRV_Individual.createRecord(mapCheck.values());
      //  System.debug('********PREIndividual');
        for(Contact c :contactIds){
          //  System.debug('********IntoIndividual');
            if(mapCheck.get(c.Id) != null){
             //   System.debug('********Into2Individual:' + mapCheck.get(c.Id).id);
                c.IndividualId = mapCheck.get(c.Id).id;
                updateContacts.add(c);
            }
            /*for(Individual i: indv){
                if(c.LastName== i.lastname && c.firstname == i.firstname){
                    Contact contact=new Contact(Id=c.Id, IndividualId=i.Id);
                    updateContacts.add(contact);
                }
            }*/
        }
        // HRAWRM-881 Start 14/10/2021
        if (updateContacts!=null&&updateContacts.size()>0) {
            contactSrv.updateRecord(updateContacts);

        }
        // HRAWRM-881 End 14/10/2021
        return indv;
    }
    public class WrapContactIndi{
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

    public static List<Individual> createIndividualLead (List<Lead> leadIds) {
        //HDT_QR_Lead leadQr = new HDT_QR_Lead();
        //List<Lead> leads = leadQr.getRecordsById(leadIds);
        List<Individual> inds= new List<Individual>();
        List<Lead> updateLeads= new List<Lead>();
        Map<String,Individual> mapCheck = new Map<String,individual>();

        for(Lead l: leadIds){


            
            Individual individual =new Individual(LastName = l.LastName,FirstName = l.firstName,companyOwner__c = l.companyOwner__c);
            

            DateTime timeNow = Datetime.now();
            Date myDate = date.newinstance(timeNow.year(), timeNow.month(), timeNow.day());
            if(l.Consenso_IBM_Unica__c){
                
                individual.MarketingPrivacy__c = 'SI';
                individual.MarketingCompanyConsent__c = 'HC+HCM+EENE';
                individual.PrivacyMarketingChoiceSource__c = 'Ripresa Dati';
                individual.PrivacyMarketingChoiceDate__c = myDate;
            }
            else{
                individual.MarketingPrivacy__c = 'Non espresso';
            }
                    
            inds.add(individual);
            mapCheck.put(l.id,individual);
        }

        List<Individual> indv= HDT_SRV_Individual.createRecord(inds);
        
        for(Lead l :leadIds){
            if(mapCheck.get(l.Id) != null){
                System.debug('********Into2Individual:' + mapCheck.get(l.Id).id);
                l.IndividualId = mapCheck.get(l.Id).id;
                updateLeads.add(l);
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
//** [START MOD 2021-09-08] @Author:Luca Belometti - WR (luca.belometti@webresults.it) @Description: Commented becasue the methods are not used
/*
    public static void updateConsensoMarketingPrivacy(Individual indv,String VersioneInformativaMarketing,String FonteConsensoMarketing,String IniziativaConsensoMarketing,Date DataConsensoMarketing,String CompanyConsensoMarketing ) {
        Individual ind =new Individual(Id = indv.id ,  MarketingPrivacyVersion__c = VersioneInformativaMarketing ,PrivacyMarketingChoiceSource__c = FonteConsensoMarketing ,
         PrivacyMarketingConsentInitiative__c = IniziativaConsensoMarketing,PrivacyMarketingChoiceDate__c = DataConsensoMarketing ,MarketingCompanyConsent__c = CompanyConsensoMarketing);
        
                
        HDT_SRV_Individual.checkCreateAccess(indv);
       // /*Individual indvid= HDT_SRV_Individual.updateRecord(indv);

    }

    public static void updateConsensoProfilazionePrivacy(Individual indv,String VersioneInformativaProfilazione,String FonteConsensoProfilazione,String IniziativaConsensoProfilazione,Date DataConsensoProfilazione,String CompanyConsensoProfilazione ) {
        Individual ind =new Individual(Id=indv.id ,ProfilingPrivacyVersion__c = VersioneInformativaProfilazione,PrivacyProfilingChoiceSource__c = FonteConsensoProfilazione,PrivacyProfilingConsentInitiative__c = IniziativaConsensoProfilazione,
        PrivacyProfilingChoiceDate__c = DataConsensoProfilazione,ProfilingCompanyConsent__c = CompanyConsensoProfilazione);
        

        HDT_SRV_Individual.checkCreateAccess(indv);
        ///*Individual individ= HDT_SRV_Individual.updateRecord(indv);
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
     */
//** [END MOD 2021-09-08] @Author:Luca Belometti - WR (luca.belometti@webresults.it) @Description: Commented becasue the methods are not used

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
/*    public static void updatePrivacyConsentIBMUnica(Id recordId, Boolean IBMunica){
        DateTime dT = Datetime.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Individual ind =new Individual(Id = recordId);
        if(IBMunica){
            
            ind.MarketingPrivacy__c = 'SI';
            ind.MarketingCompanyConsent__c = 'HC+HCM+EENE';
            ind.PrivacyMarketingChoiceSource__c = 'Ripresa Dati';
            ind.PrivacyMarketingChoiceDate__c = myDate;
        }
        else{

                ind.MarketingPrivacy__c = 'Non espresso';
        }
                
        HDT_SRV_Individual.checkCreateAccess(ind);
        Individual indvid= HDT_SRV_Individual.updateRecord(ind);

    }
    */