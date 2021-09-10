/**
 * @author Lucas da Silva Fernandes (lucas.dasilva@engdb.com.br)
 * @date 20/08/2021
 * @description HDT_UTL_ Test Classes
 * @history Lucas da Silva Fernandes – 20/08/2021 – Created class
 */
@isTest
public with sharing class HDT_UTL_ConstantsTst {
    
    private static HDT_UTL_Constants constants = new HDT_UTL_Constants();

    @isTest
    public static void testConstants() {

        Test.startTest();

        System.debug('Constants: ' +constants);

        System.assertNotEquals(null, constants, 'Constants has been populated.');

        Test.stopTest();
    }
}
