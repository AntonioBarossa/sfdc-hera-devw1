@isTest
public class HDT_UTL_AccentsTst {

    @isTest
    static void testRemoveDiacritics(){

        Test.startTest();

        String result = HDT_UTL_Accents.removeDiacritics('Ḧéļḻṏ');
        System.assertEquals('Hello', result, 'Errore in removeDiacritics');

        result = HDT_UTL_Accents.removeDiacritics('Ammissibilità');
        System.assertEquals('Ammissibilita', result, 'Errore in removeDiacritics');

        result = HDT_UTL_Accents.removeDiacritics('non nella titolaritÃ');
        System.assertEquals('non nella titolaritA', result, 'Errore in removeDiacritics');

        // verifica che gli spazi finali siano preservati
        result = HDT_UTL_Accents.removeDiacritics('non nella  ');
        System.assertEquals('non nella  ', result, 'Errore in removeDiacritics');

        Test.stopTest();

    }

}