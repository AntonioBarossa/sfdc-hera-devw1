/*
 * File: HDT_UTL_ServiceTwentySix.cls
 * Project: HERA
 * File Created: Tuesday, 29th June 2021 10:38:58 am
 * Author: fdefelice
 * DESCRIPTION: 
 * -----
 * HISTORY:
 * Last Modified: Wednesday, 30th June 2021 4:31:50 pm
 * Modified By: fdefelice
 * Changes: 
 * --END--
 */

 //Creare Campo productDescFormula__c v
 //ActivationMode non popolato
 //Domestico;Non Domestico
 //Recuperare alcuni campi da OrderItem

@SuppressWarnings('PMD.AvoidDebugStatements')
public with sharing class HDT_UTL_ServiceTwentySix {

    private static Set<String> prodFields;
    private static HDT_QR_Sobject utl = new HDT_QR_Sobject();
    private static Id ordId;

    private static List<String> ordItemFields = new List<String>{'product2.family', 'product2.name', 'product2.constraintdiscountpercentage__c', 'product2.constraintdiscounteurgiorno__c', 'product2.constraintexemption__c', 'description', 'product2.description'};

    private inherited sharing class HDT_QR_Sobject extends HDT_UTL_FormatTextScript{

        private List<SObject> getSObj(Set<Id> listIds, List<String> fieldsToQuery, String fromCondition){
            String query = makeSelectStatement(fieldsToQuery);
            List<SObject> lSobjs;
            if(STRING.isNotBlank(query)){
                query+=
                fromCondition;
                //System.debug(LoggingLevel.DEBUG, query);
                //mapSobjs = new Map<id, SObject>( (List<SObject>) Database.query(query));
                lSobjs= (List<SObject>) Database.query(String.escapeSingleQuotes(query));
            }
            return lSobjs;
        }

        private Map<id, Product2> getProducts(Set<Id> listIds, List<String> fieldsToQuery){
            Map<id, Product2> mapProducts = new Map<id, Product2>((List<Product2>) getSObj(listIds, fieldsToQuery, ' FROM Product2 where Id IN :listIds'));
            //system.debug(mapProducts.keyset());
            return mapProducts;
        }

        private Map<id, OrderItem> getOrdItemsByOrdId(Set<Id> listIds, List<String> fieldsToQuery){
            Map<id, OrderItem> mapOrdItems = new Map<id, OrderItem>((List<OrderItem>) getSObj(listIds, fieldsToQuery, ' FROM OrderItem where OrderId IN :listIds'));
            //system.debug(mapOrdItems.keyset());
            return mapOrdItems;
        }



        private String dinamicFieldValue(String fieldPath, SObject relation){
            String retValue = getFieldValue(fieldPath, relation);
            //retValue = fieldPath.equalsIgnoreCase('DurationVAS__c')? '999999' : retValue;
            return retValue=='null'? '' : retValue;
        }
    }
    
    public class HDT_WRP_Position {
        //wrapper object to integrate in the callout
        public String field;
        public String value;
        public String flag;
        public HDT_WRP_Position(String name, String value){
            this.field=name;
            this.value=value;
        }
    }

    public class HDT_WRP_DtoServiceTwentySix extends HDT_WS_Request{
        public String rdsRdo;
        public String pod;
        public String documentKey;
        public String tipoOperazione;//ActivationMode non popolato
        public String tipoFornitura;//Domestico;Non Domestico
        public List<HDT_WRP_Position> elements;
        public HDT_WRP_DtoServiceTwentySix(Order order){
            this.rdsRdo=Order.OrderNumber;
            this.pod=Order.ServicePointCode__c;
            this.documentKey=Order.HerokuPracticeCode__c;
            this.tipoOperazione='ATT';//order.ActivationMode__c;
            this.tipoFornitura=(new Set<String>{'Domestico', 'A-Domestico'}.contains(order.SupplyType__c)) ? 'Domestico' : 'Non Domestico';
        }
        public HDT_WRP_DtoServiceTwentySix(){
            return;
        }
    }


    private static List<Service26Config__c> getConfigs(String serviceType, Set<String> productFamilies){
        //This method get a service type (gas/Elettrico) and a list of product families, 
        //return a list of 'operando' ordered by  Occurrence__c
        return [ select SapCode__c, Field__c, Occurrence__c, ProductFamily__c, (SELECT SapCode__c, Field__c FROM Service26Configs__r )
                    FROM Service26Config__c WHERE 
                    Type__c='Operando' AND ProductFamily__c IN :productFamilies AND Servizio__c =:serviceType 
                    WITH SECURITY_ENFORCED ORDER BY Occurrence__c ASC
            ];
    }




    public HDT_WRP_DtoServiceTwentySix startProcess(Id orderId){
        //this method starts the process, it gets an OrderId and he queries related OrderItems
        //If there's already a query on order items (or on Order), modify this method to get that list
        ordId=orderId;
        Order order = [SELECT 
                        (SELECT Product2.Family, Product2.Name, Product2.ConstraintDiscountPercentage__c, Product2.ConstraintDiscountEurGiorno__c, Product2.ConstraintExemption__c, Description, Product2.Description FROM OrderItems), 
                        CommodityFormula__c, OrderNumber, ServicePointCode__c, ActivationMode__c,
                        HerokuPracticeCode__c, SupplyType__c, SupplyTypeTechnical__c,
                        SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c
                        FROM Order WHERE Id=:orderId WITH SECURITY_ENFORCED];

        HDT_WRP_DtoServiceTwentySix dto = new HDT_WRP_DtoServiceTwentySix(order);

        //system.debug('1 '+order.OrderItems.size());


        List<OrderItem> items = order.OrderItems;
        if(items.isEmpty()){
            return dto;
        }
            /* [SELECT Order.CommodityFormula__c, Product2.Family, Order.OrderNumber, Order.ServiePointCode__c, 
                Order.HerokuPracticeCode__c, Order.SupplyType__c, Order.SupplyTypeTechnical__c, Order.ActivationMode__c
            FROM OrderItem WHERE OrderId=:OrderId WITH SECURITY_ENFORCED]; */
        //system.debug('2');

        Map<String, List<OrderItem>> familyToOccurrencies = new Map<String, List<OrderItem>>();
        //this map is used to connect a family to a list of items. 
        //This map is not clean because we cannot know at this point 
        //which of these items are bonuses
        //the size of each list is the number of occurence that family has
        for(OrderItem item : items){
            if(!familyToOccurrencies.containsKey(item.Product2.Family)){
                //system.debug('3');
                familyToOccurrencies.put(item.Product2.Family, new List<OrderItem>());
            }
            familyToOccurrencies.get(item.Product2.Family).add(item);
        }
        //system.debug(order.CommodityFormula__c);
        //system.debug(familyToOccurrencies.keyset());

        List<Service26Config__c> configs = getConfigs(order.CommodityFormula__c, familyToOccurrencies.keyset());
        //getting list of configurationObjects, they contains only the families we are interested but 
        //They may have more occurrence than we need
        if(!configs.isEmpty()){
            //system.debug('4');
            dto.elements=getPositions(configs, familyToOccurrencies, order);
        }
        return dto;
    }



    @SuppressWarnings('PMD.CyclomaticComplexity')
    private List<HDT_WRP_Position> getPositions(List<Service26Config__c> configs, Map<String, List<OrderItem>> familyToOccurrencies, Order ord){
        prodFields = ((SObject)Type.forName('Schema','Product2').newInstance())
                                    .getSObjectType().getDescribe().fields.getMap().keySet();//Set of all order api name fields
        List<String> fieldsToQuery = new List<String>();


        Set<Id> productIds = new Set<Id>();
        Map<String, List<Service26Config__c>> familyToOperando = new Map<String, List<Service26Config__c>>(); 
        //this map key gonna be a clean set of families to the corresponding operandos, ordered by occurrency asc 
        //The for loop below populate familyOperando Map, list of all products id to query and all fields to query
        //system.debug('5a');
        for(Service26Config__c operando : configs){
            if(!familyToOperando.containsKey(operando.ProductFamily__c)){
                familyToOperando.put(operando.ProductFamily__c, new List<Service26Config__c>());
            }
            familyToOperando.get(operando.ProductFamily__c).add(operando);
            if(operando.Occurrence__c==1){
                //system.debug('5b');
                for(orderItem item : familyToOccurrencies.get(operando.ProductFamily__c)){
                    productIds.add(item.Product2Id);
                }
                for(Service26Config__c position : Operando.Service26Configs__r){
                    //system.debug('ivaste '+json.serialize(position));
                    if(prodFields.contains(Position.Field__c?.toLowerCase())){
                        fieldsToQuery.add(Position.Field__c?.toLowerCase());
                    }else if(STring.isNotBlank(Position.Field__c) && Position.Field__c.startsWith('OrderItem.')){
                        ordItemFields.add(Position.Field__c.split('OrderItem\\.')[1].toLowerCase());
                    }
                }
            }
        }

        /**@frpanico 2022-05-05
         * Add Percentage to product2
         */
        fieldsToQuery.add('Percentage__c');
        //Map<id, Product2> prods = utl.getProduct(productIds, fieldsToQuery);
        //System.debug('productIds: '+productIds);
        //System.debug('fieldsToQuery: '+fieldsToQuery);
        Map<id, Product2> prods = utl.getProducts(productIds, fieldsToQuery);
        Map<id, OrderItem> mapOrdItems = utl.getOrdItemsByOrdId(new Set<Id>{ordId}, ordItemFields);

        List<HDT_WRP_Position> positionsToReturn = new List<HDT_WRP_Position>();

        //Now we have 3 maps, map id-> product
        //Map family -> List OrderItem (OrderItem Contains Prod id), the index of the list is "Occurrency" Information
        //this map contain some key-values we don't need
        //
        //Map family -> Operando, Operando has child relationship with "positions", 
        //this map contains only the key needed

         //Gestione Posizioni esistenti
         Map<String,List<Integer>> freePositionForFamily = new Map<String,List<Integer>>();
         if (ord.SBQQ__Quote__c != null && 'Amendment'.equalsIgnoreCase(ord.SBQQ__Quote__r.SBQQ__Type__c)){
            freePositionForFamily = this.getFreePositions(familyToOperando,ord.SBQQ__Quote__c);
         }

        //this for loop builds the list of Object for the callout
        for(String family : familyToOperando.keySet()){
            List<OrderItem> discountItems = familyToOccurrencies.get(family);
            for(Integer index = 0; index<discountItems.size();index++){
                Product2 relatedProduct = prods.get(discountItems[index].Product2Id);//product to get values
                /* se non entro nell'if successivo operatingIndex resta index e operatingNumber resta quello che è attualmente e funziona come prima */
                Integer operatingIndex = index;
                Integer operatingNumber = familyToOperando.get(family).size();
                /**Questo if ci entro se sono nella casistica degli Amendment e non tutti gli slot sono disponibili */
                if (freePositionForFamily.get(family) != null && freePositionForFamily.get(family).size() < operatingNumber){
                    operatingNumber = freePositionForFamily.get(family).size();
                    operatingIndex = freePositionForFamily.get(family).size() > index ? freePositionForFamily.get(family)[index] -1 : 0;
                }
                if(operatingNumber<=index){
                    //there are more discounts than occurrencies
                    break;
                } 
                Service26Config__c operando = familyToOperando.get(family)[operatingIndex];//operando
                /**@frpanico 2022-05-05
                 * The GF_BON_* operando
                 * Need the value of the field Product2.Percentage__c
                 * It is not just a string
                 */
                if(operando.Field__c.equalsIgnoreCase('Percentage__c'))
                {
                    positionsToReturn.add(
                        new HDT_WRP_Position(operando.SapCode__c, utl.dinamicFieldValue(operando.Field__c, relatedProduct))
                    );
                }
                else
                {
                    positionsToReturn.add( 
                        new HDT_WRP_Position(operando.SapCode__c, operando.Field__c)//operando field is just a string
                    );
                }
                for(Service26Config__c position : Operando.Service26Configs__r){//Operando has childs
                    String value = getFieldValue(position.Field__c, relatedProduct, mapOrdItems.get(discountItems[index].Id));

                    positionsToReturn.add( 
                        new HDT_WRP_Position(position.SapCode__c, value)
                        //child field is the api name of Product field to get value
                    );            
                }
            }
        }
        return positionsToReturn;
    }

    @TestVisible
    private String getFieldValue(String posField, SObject relatedProduct, SObject ordItem){
        if(STRING.isBlank(posField)){
            return '';
        }        
        if(posField?.startsWith('CustomCheck.')){
            return getCustomChecks(posField, ordItem);
        }
        if(posField?.startsWith('OrderItem.')){
            //Fatti Mappa Product->OrderItem e accattati il campo, splitta per 'OrderItem.''
            return utl.dinamicFieldValue(posField?.split('OrderItem\\.')[1], ordItem);
        }
        if(prodFields.contains(posField.toLowerCase())){
            //return STRING.valueOf(relatedProduct.get(posField));
            return utl.dinamicFieldValue(posField, relatedProduct);
        }
        return posField;
    }

    private String getCustomChecks(String posField, SObject ordItem){
        switch on posField.split('\\.')[1]{
            when 'isAnalisiConsumi'{
                return utl.dinamicFieldValue('Product2.Description', ordItem).containsIgnoreCase('analisi consumi') ? 'X' : '';
            }
            when 'isConstraint'{
                Boolean check = String.isBlank( utl.dinamicFieldValue('Product2.ConstraintExemption__c', ordItem) );
                check=check && String.isBlank( utl.dinamicFieldValue('Product2.ConstraintDiscountEurGiorno__c', ordItem) );
                check=check && String.isBlank( utl.dinamicFieldValue('Product2.ConstraintDiscountPercentage__c', ordItem) );
                return check? '' : 'x';
            }
        }
        return '';

    }

    @TestVisible
    private Map<String,List<Integer>> getFreePositions(Map<String, List<Service26Config__c>> familyToOperando, Id quoteId){
        Map<String,List<Integer>> freePositionForFamily = new Map<String,List<Integer>>();
        for(SBQQ__QuoteLine__c qLine : [
            SELECT SBQQ__Product__r.Name, SBQQ__Product__r.Family, SBQQ__Product__r.Old__c,SBQQ__Existing__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c = :quoteId  AND SBQQ__Existing__c = true
            WITH SECURITY_ENFORCED
            ORDER BY SBQQ__Product__r.OLD__c DESC
        ]){
            if (familyToOperando.keySet().contains(qLine.SBQQ__Product__r.Family) && !freePositionForFamily.keySet().contains(qLine.SBQQ__Product__r.Family)){
                freePositionForFamily.put(qLine.SBQQ__Product__r.Family, this.getAllPositions(familyToOperando.get(qLine.SBQQ__Product__r.Family).size()));
            }
            if (familyToOperando.keySet().contains(qLine.SBQQ__Product__r.Family) && freePositionForFamily.keySet().contains(qLine.SBQQ__Product__r.Family)){
                removePosition(freePositionForFamily.get(qLine.SBQQ__Product__r.Family),qLine);
            }
        }

        System.debug(LoggingLevel.DEBUG, '@@@@freePositionForFamily ' + JSON.serialize(freePositionForFamily));
        
        return freePositionForFamily;
    }

    private List<Integer> getAllPositions(Integer size){
        List<Integer> getPositions = new List<Integer>();
        for (Integer i = 0; i < size; i++){
            getPositions.add(i+1);
        }
        return getPositions;
    }

    private void removePosition(List<Integer> actualPositions, SBQQ__QuoteLine__c qLine){
        try{
            Integer position = null;
            if ('Y'.equalsIgnoreCase(qLine.SBQQ__Product__r.Old__c)){
                //rimuovo prima tutti i prodotti vecchi (garantito dall'order By della query) che sono stati mandati su occorrenze non necessariamente casuali
                List<String> splittedName = qLine.SBQQ__Product__r.Name.split(' ');
                if (splittedName[splittedName.size()-1].isNumeric()){
                    position = actualPositions.indexOf(Integer.valueOf(splittedName[splittedName.size()-1]));
                }
            }
            if ('N'.equalsIgnoreCase(qLine.SBQQ__Product__r.Old__c)){
                //Rimuovo la prima occorrenza libera, perchè quelli di SFDC li abbiamo inviati in modo sequenziale
                position = 0;
            }
            if (position != null){
                actualPositions.remove(position);
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
    }

}