@isTest
public class HDT_WRP_ZonizzazioneTst {

    @isTest
    static void testNestedClassConstructors() {
        
        HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneRequest zonizzazioneRequest = new HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneRequest();
        
        
        HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneResponseData zonizzazioneResponseData = new HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneResponseData();
        
        
        HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneResponse zonizzazioneResponse = new HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneResponse();
        System.assertEquals(new List<HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneDotazione>(), zonizzazioneResponse.dotazioni, 'ZonizzazioneResponse constructor should initialize dotazioni');
        
        
        HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneDotazione zonizzazioneDotazione = new HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneDotazione();
        System.assertEquals(true, zonizzazioneDotazione.editable, 'ZonizzazioneDotazione constructor should set editable to true');
        System.assertEquals(new Set<String>(), zonizzazioneDotazione.alternative, 'ZonizzazioneDotazione constructor should initialize alternative');

        
        HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneDotazione zonizzazioneDotazione2 = new HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneDotazione(zonizzazioneDotazione);
        System.assertEquals('1', zonizzazioneDotazione2.quantita, 'ZonizzazioneDotazione constructor with parameter should set quantita to 1');

        
        zonizzazioneDotazione.quantita = '3';
        List<HDT_WRP_Zonizzazione.HDT_WRP_ZonizzazioneDotazione> newEquipments = zonizzazioneDotazione.newEquipment(zonizzazioneDotazione);
        System.assertEquals(3, newEquipments.size(), 'newEquipment method should return a list with the size equal to the quantita value');
    }
}