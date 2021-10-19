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
        HDT_UTL_DataFactoryTst.createCity(5,true);
    }

    @isTest 
    static void calculateFiscalCodeTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addDays(-100)));
        infoDtata.put('lastName', 'LastNameTest');
        infoDtata.put('firstName', 'FirtNameTest');
        infoDtata.put('gender', 'Maschio');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('LSTFTN21L06Bt0Q', ResulFilscalCode, 'Calculate FiscalCode Test');
    }
    @isTest 
    static void calculateFiscalCodeBirthPlaceNotFoundTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Milan');
        infoDtata.put('birthDate', String.valueOf(Date.today()));
        infoDtata.put('lastName', 'LastNameTest');
        infoDtata.put('firstName', 'FirtNameTest');
        infoDtata.put('gender', 'f');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals(null, ResulFilscalCode, 'Calculate FiscalCode Birth Place Not Found Test');
    }
    @isTest 
    static void calculateFiscalCodeOtherGenderTest(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(3)));
        infoDtata.put('lastName', 'LNT');
        infoDtata.put('firstName', 'FNT');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('LNTFNT22A54Bt0U', ResulFilscalCode, 'Calculate FiscalCode Other Gender Test');
    }
    @isTest 
    static void calculateFiscalCodeLastAndFirtNameEqual2(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(4)));
        infoDtata.put('lastName', 'waN');
        infoDtata.put('firstName', 'zoD');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('WNAZDO22B54Bt0A', ResulFilscalCode,'Calculate FiscalCode Last And FirtName Equal');
    }
    @isTest 
    static void calculateFiscalCodeLastAndFirtNameEqual1(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(5)));
        infoDtata.put('lastName', 'Le');
        infoDtata.put('firstName', 'Qu');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('LEXQUX22C54Bt0L', ResulFilscalCode, 'Calculate FiscalCode Last And FirtName Equal');
    }
    @isTest 
    static void calculateFiscalCodeLastAndFirtNameEqual1manyVowel(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(6)));
        infoDtata.put('lastName', 'pao');
        infoDtata.put('firstName', 'joa');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('PAOJOA22D54Bt0L', ResulFilscalCode, 'Calculate FiscalCode Last And FirtName Equal1 many Vowel');
    }
    @isTest 
    static void calculateFiscalCodeMonthsplusSeven(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(7)));
        infoDtata.put('lastName', 'bi123456789');
        infoDtata.put('firstName', 'ovhi');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('B12VHO22E54Bt0L', ResulFilscalCode, 'Calculate FiscalCode Months plus Seven');
    }
    @isTest 
    static void calculateFiscalCodeMonthsplusone(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(1)));
        infoDtata.put('lastName', 'tyi');
        infoDtata.put('firstName', 'reg');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TYIRGE21S54Bt0W', ResulFilscalCode, 'Calculate FiscalCode Months plus one');
    }
    @isTest 
    static void calculateFiscalCodeMonthsplutwo(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(2)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TPLCCO21T54Bt0L', ResulFilscalCode, 'Calculate FiscalCode Months plus two');
    }
    @isTest 
    static void calculateFiscalCodeMonthsplusheigth(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(8)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TPLCCO22H54Bt0P', ResulFilscalCode, 'Calculate FiscalCode Months plus two');
    }
    @isTest 
    static void calculateFiscalCodeMonthsminous1(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(-1)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TPLCCO21P54Bt0A', ResulFilscalCode, 'Calculate FiscalCode Months minous 1');
    }
    @isTest 
    static void calculateFiscalCodeMonthsminous2(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today().addMonths(-2)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TPLCCO21M54Bt0P', ResulFilscalCode, 'Calculate FiscalCode Months minous 1');
    }
    @isTest 
    static void calculateFiscalCodeCyrrentMonth(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.today()));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TPLCCO21R54Bt0F', ResulFilscalCode, 'Calculate FiscalCode CyrrentMonth');
    }
    @isTest 
    static void calculateFiscalCodeInvalidMonth(){
        Map<String,String> infoDtata = new Map<String,String>();
        infoDtata.put('birthPlace', 'Roma');
        infoDtata.put('birthDate', String.valueOf(Date.newInstance(1960, 0, 17)));
        infoDtata.put('lastName', 'tipolo');
        infoDtata.put('firstName', 'coca');
        infoDtata.put('gender', 'M');
        String ResulFilscalCode =HDT_UTL_CalculateFiscalCode.calculateFiscalCode(infoDtata);
        System.debug('test:'+ ResulFilscalCode);
        System.assertEquals('TPLCCO59T57Bt0J', ResulFilscalCode, 'Calculate FiscalCode Invalid Month');
    }

}