@isTest public class HDT_UTL_GenerateMultilevelJsonTest {
    @isTest static void testMultiLevelJson(){
        HDT_UTL_GenerateMultilevelJson gen = new HDT_UTL_GenerateMultilevelJson();
        try{
            new HDT_UTL_GenerateMultilevelJson(new Map<String, String>{'k'=>'v', 'k.0.k2'=>'v'}).generateJson();
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        Map<String, String> m = new Map<String, String>{'k.1.k2'=>'v', 'k.0.k2'=>'v', 'k0.k1'=>'vv', 'k0.k2.k4.k5'=>'vv2'};
        gen = new HDT_UTL_GenerateMultilevelJson(m);
        gen.generateMap();
        system.assert(String.isNotBlank(gen.generateJson()), 'JSON Generator Failed Working on Map');
    }
}