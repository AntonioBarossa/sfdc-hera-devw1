/**
* @author Elfrida Kora (elfrida.kora@dunegroup.it)
* @date 02/09/2021
* @description HDT_UTL_Individual for Test Classes
* @history Luca Belometti WR (luca.belometti@w) – 08/09/2021 – MOdified class
*/

@IsTest
public class HDT_UTL_IndividualTst {
    @TestSetup
    static void makeData() 
    {
        
        HDT_UTL_DataFactoryTst.createIndividual(1,true);
        List<Account> accList = HDT_UTL_DataFactoryTst.createAccountBusiness(1, true, 'HERA COMM', 'Azienda', 'Aziende SME');
        HDT_UTL_DataFactoryTst.createContact(1,true,accList[0].Id);
        HDT_UTL_DataFactoryTst.createLead(1,true);

         
        }
    
     @isTest
    public static void testConsentIndividual(){
        
         Test.startTest();

          
          List<Contact> contactId =[SELECT Id FROM Contact];
          List<String> listString = new List<String>(); 
          listString.add(String.valueOf(contactId[0].Id));
        
        List<Lead> leadId =[SELECT Id FROM Lead];
        List<String> lstString = new List<String>();
        
        lstString.add(String.valueOf(leadId[0].Id));

        
        List<Individual> individualReturnedFromMethod = HDT_UTL_Individual.createIndividualContact(listString);
        Id indIdRet = individualReturnedFromMethod[0].Id;
        List<Individual> indvl =[SELECT Id FROM Individual WHERE Id = :indIdRet];
        System.debug('@@@@RETURNED INDIVIDUAL FROM METHOD: ' + individualReturnedFromMethod);
        System.debug('@@@@RETURNED INDIVIDUAL FROM METHOD - SIZE:  ' + individualReturnedFromMethod.size());

        
        
        System.assertEquals(indvl[0].Id,individualReturnedFromMethod[0].Id,'The method worked on the right Id of the Individual');
        System.assertNotEquals(null,individualReturnedFromMethod[0].Id,'The method worked on the recordId of the Individual, in fact it is not null');
        Test.stopTest();
        
            
        }
    @isTest
    public static void testCreateIndividualLead(){
        Test.startTest();
        List<Lead> leadId =[SELECT Id FROM Lead];
        List<String> lstString = new List<String>();
         lstString.add(String.valueOf(leadId[0].Id));
         List<Individual> returnedIndv = HDT_UTL_Individual.createIndividualLead(lstString);
         List<Id> listaIdFromReturnedIndv = new List<Id>();
         for (Individual ind : returnedIndv) {
           listaIdFromReturnedIndv.add(ind.Id);
         }

         System.debug('#### RETURNED ID : ' + listaIdFromReturnedIndv);
         List<Lead> leads =[SELECT Id,IndividualId FROM Lead WHERE IndividualId IN :listaIdFromReturnedIndv];
         System.debug('@@@@LISTA DEI LEAD: ' + leads);
         List<Individual> indvl =[SELECT Id FROM Individual WHERE Id IN :listaIdFromReturnedIndv];

        
        System.assertEquals(indvl[0].Id,leads[0].IndividualId,'The method updated the lead with the correct Individial Id');
        System.assertNotEquals(null,leads[0].IndividualId, 'The method correctly updated the Individual Id of The lead');
        Test.stopTest();
    }
    
      @isTest
    public static void testModifyFieldValue(){
      Test.startTest();
        List<Individual> indv =[SELECT Id,LastName FROM Individual];
        Map<String,object> params= new Map<String, object>();
        params.put('LastName',indv[0].LastName);
        
        Individual returnedIndivudual = HDT_UTL_Individual.modifyFieldValue(params, indv[0].Id);
        System.debug('@@@testModifyFieldValue: ' + returnedIndivudual); 
        
        System.assertEquals('Guzzo',returnedIndivudual.LastName,'LastNameField correctly taken from method Guzzo');
        System.assertNotEquals('Test',returnedIndivudual.LastName,'LastName not equal in Test LastNameField in Guzzo, correclty taken from method');
      Test.stopTest();
    }
    
    @isTest
    public static void testConvertLeadToContact(){
      Test.startTest();
        List<Individual> indv =[SELECT Id FROM Individual];
		    List<Contact> contactList = [SELECT Id FROM Contact];
        Contact returnedContact =  HDT_UTL_Individual.convertLeadToContact(contactList[0].Id, indv[0].Id);
        
        System.assertEquals(indv[0].Id,returnedContact.IndividualId,'The Method updated correctly the Contact IndividualId');
        System.assertNotEquals(null,returnedContact.IndividualId,'The Method updated correctly the Contact IndividualId, it is not null');
      Test.stopTest();
        
    }

}