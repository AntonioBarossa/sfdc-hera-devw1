/**
 * @author Valere (valere@noeli-it.net)
 * @date 10/09/2021
 * @description HDT_UTL_CalculateFiscalCodeTst Test Classes
 * @history valere - 10/09/2021– Created Class
 */

@isTest
public class HDT_UTL_CalculateFiscalCodeTst {
    @testSetup 
    static void setup() {
        HDT_UTL_DataFactoryTst.createCity();
    }

    @isTest 
    static void calculateFiscalCodeTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addDays(-100)));
        infoDtata.put('lastName', 'LastNameTest');
        infoDtata.put('firstName', 'FirtNameTest');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Test');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateSetFiscalCodeTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addDays(-100)));
        infoDtata.put('lastName', 'LastNameTest');
        infoDtata.put('firstName', 'FirtNameTest');
        infoDtata.put('gender', 'Maschio');
        Set<String> resultSetFiscalCode =HDT_UTL_CalculateFiscalCode.calculateSetFiscalCode(infoDtata);
        List<String> resultFiscalCode = new List<String>(resultSetFiscalCode);
        System.assertEquals(true, !resultFiscalCode.isEmpty(), 'Calculate FiscalCode Test');
        System.assertEquals(16, resultFiscalCode[0].length(), 'Calculate FiscalCode Test');
        System.assertNotEquals(true, resultFiscalCode[0].length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeBirthPlaceNotFoundTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Milan');
        infoDtata.put('birthDate', String.valueOf(Date.today()));
        infoDtata.put('lastName', 'LastNameTest');
        infoDtata.put('firstName', 'FirtNameTest');
        infoDtata.put('gender', 'Femmina');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(null, resultFiscalCode, 'Calculate FiscalCode Birth Place Not Found Test');
    }
    @isTest 
    static void calculateFiscalCodeOtherGenderTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(3)));
        infoDtata.put('lastName', 'LNT');
        infoDtata.put('firstName', 'FNT');
        infoDtata.put('gender', 'Femmina');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Other Gender Test');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeLastAndFirtNameEqual2(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(4)));
        infoDtata.put('lastName', 'waN');
        infoDtata.put('firstName', 'zoD');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(),'Calculate FiscalCode Last And FirtName Equal');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeLastAndFirtNameEqual1(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(5)));
        infoDtata.put('lastName', 'Le');
        infoDtata.put('firstName', 'Qu');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Last And FirtName Equal');
    }
    @isTest 
    static void calculateFiscalCodeLastAndFirtNameEqual1manyVowel(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(6)));
        infoDtata.put('lastName', 'pao');
        infoDtata.put('firstName', 'joa');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Last And FirtName Equal1 many Vowel');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeMonthsplusSeven(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(7)));
        infoDtata.put('lastName', 'bi123456789');
        infoDtata.put('firstName', 'ovhi');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Months plus Seven');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeMonthsplusone(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(1)));
        infoDtata.put('lastName', 'tyi');
        infoDtata.put('firstName', 'reg');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Months plus one');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeMonthsplutwo(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(2)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Months plus two');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeMonthsplusheigth(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(8)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Months plus two');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeMonthsminous1(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(-1)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Months minous 1');
    }
    @isTest 
    static void calculateFiscalCodeMonthsminous2(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(-2)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Months minous 1');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeCyrrentMonth(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today()));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode CyrrentMonth');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }
    @isTest 
    static void calculateFiscalCodeInvalidMonth(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.newInstance(1960, 0, 17)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'Maschio');
        String resultFiscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.assertEquals(16, resultFiscalCode.length(), 'Calculate FiscalCode Invalid Month');
        System.assertNotEquals(true, resultFiscalCode.length()<16, 'FiscalCode is wrong');

    }

}