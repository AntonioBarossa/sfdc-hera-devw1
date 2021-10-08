/**
* @author Fabricio Nunes (fabricio.nunes@engdb.com.br)
* @date 02/09/2021
* @description HDT_QR_MatriceAgenti Test Classes
* @history Fabricio Nunes – 02/09/2021 – Created class
*/

@isTest
public with sharing class HDT_QR_MatriceAgentiTst {

    @isTest
    public static void testGetAgente(){

        Test.startTest();

        List<HDT_MatriceSocietaVendita__mdt> testGetAgent = HDT_QR_MatriceAgenti.getAgente('Gas', 'EENE', 'ALTRO', 'ALTRO');

        System.assertEquals(false, testGetAgent.isEmpty(), 'Matrice Societa Vendita Agente not found');
        System.assertNotEquals(true, testGetAgent.isEmpty(), 'value of parameter is not matching');

        Test.stopTest();
    }

    @isTest
    public static void testGetAgenteException(){

        Test.startTest();

        List<HDT_MatriceSocietaVendita__mdt> testGetAgenteException = HDT_QR_MatriceAgenti.getAgenteException('Gas', 'EENE', 'ALTRO', 'ALTRO', 'ALTRO');

        System.assertEquals(false, testGetAgenteException.isEmpty(), 'Matrice Societa Vendita Agente Exception not found');
        System.assertNotEquals(true, testGetAgenteException.isEmpty(), 'value of parameter is not matching');

        Test.stopTest();
    }

    @isTest
    public static void testGetAgenteExceptionList(){

        Test.startTest();

        List<HDT_MatriceSocietaVendita__mdt> testGetAgenteExceptionList = HDT_QR_MatriceAgenti.getAgenteExceptionList();

        System.assertEquals(false, testGetAgenteExceptionList.isEmpty(), 'Matrice Societa Vendita Agente Exception List tnot found');
        System.assertNotEquals(true, testGetAgenteExceptionList.isEmpty(), 'value of parameter is not matching');

        Test.stopTest();
    }

    @isTest
    public static void testGetAgenteList(){

        Test.startTest();

        List<HDT_MatriceSocietaVendita__mdt> testGetAgenteList = HDT_QR_MatriceAgenti.getAgenteList();

        System.assertEquals(false, testGetAgenteList.isEmpty(), 'Matrice Societa Vendita Agente List tnot found');
        System.assertNotEquals(true, testGetAgenteList.isEmpty(), 'value of parameter is not matching');

        Test.stopTest();
    }
}