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
    @isTest
    static void cleanFiscalCodeFromOmocodiaTst()
    {
        String testCode = 'MRCMRC80ALMHRLMG';
        String assertCode = 'MRCMRC80A01H501Y';
        Test.startTest();
            String result = HDT_UTL_CalculateFiscalCode.cleanFiscalCodeFromOmocodia(testCode);
        Test.stopTest();
        System.assertEquals(assertCode, result, 'Fiscal code not cleaned correctly');
    }

    @isTest 
    static void getAgeFromFiscalCodeTest(){
        Date d = Date.today();
        Test.startTest();
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode('1111111254455698'), null, 'Calcolo cf numerico non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode('XXXXXX76X41X000X'), null, 'Calcolo mese errato non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode(''), null, 'Calcolo valore vuoto non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode('XXXXXXXXXXXXXXXX'), null, 'Calcolo string 16 caratteri non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode('XXXXXX76A 1X000X'), null, 'Calcolo cf con spazio non corretto non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode(dateForFiscalCode(d,30, true, false)), 29, 'Calcolo età compiuta non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode(dateForFiscalCode(d,30, false, true)), 30, 'Calcolo età non compiuta non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode(dateForFiscalCode(d,0, false, true)), 0, 'Calcolo neonato non corretto');
            System.assertEquals(HDT_UTL_CalculateFiscalCode.getAgeFromFiscalCode(dateForFiscalCode(d,0, true, false)), 99, 'Calcolo stesso anno compiuto non corretto');
        Test.stopTest();
    }

    private static String dateForFiscalCode(Date d,Integer y, Boolean future, Boolean female){
        Date start = d.addYears(-y).addDays(future? 1 : -1);
        Map<Integer,String> mapMonth = new Map<Integer,String>{
            1 => 'A',
            2 => 'B',
            3 => 'C',
            4 => 'D',
            5 => 'E',
            6 => 'H',
            7 => 'L',
            8 => 'M',
            9 => 'P',
            10 => 'R',
            11 => 'S',
            12 => 'T'
        };
        return 'XXXXXX'+String.valueOf(start.year()).substring(2,4)+mapMonth.get(start.month())+String.valueOf(female? start.day()+40 : start.day())+'X000X';

    }

}