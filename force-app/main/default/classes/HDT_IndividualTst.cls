
@isTest
public with sharing class HDT_IndividualTst {
    
    @isTest
    public static void individualTest() {

        List<Individual> indiTest  = HDT_UTL_DataFactoryTst.createIndividual(1,true);


        system.assertNotEquals('', indiTest[0].id , 'Individual list is not created correctly (trigger on Individual)');
        system.assertEquals(true, indiTest.size() != null , 'individual list is empty');
    }
}
