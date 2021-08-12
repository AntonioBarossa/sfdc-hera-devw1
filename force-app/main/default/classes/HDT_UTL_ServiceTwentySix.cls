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


public with sharing class HDT_UTL_ServiceTwentySix {
   
    private inherited sharing class HDT_QR_Sobject extends HDT_UTL_FormatTextScript{
        //this method get list of id and fields and rreturn map id Product
        public Map<id, Product2> getProduct(Set<Id> productIds, List<String> fieldsToQuery){
            String query = makeSelectStatement(fieldsToQuery);
            Map<id, Product2> mapProducts;
            if(STRING.isNotBlank(query)){
                query+=
                    ' FROM Product2 where Id IN :productIds';
                system.debug(query);
                mapProducts = new Map<id, Product2>( (List<Product2>) Database.query(query));
            }
            system.debug(mapProducts.keyset());
            return mapProducts;
        }
    }
    
    private class HDT_WRP_Position {
        //wrapper object to integrate in the callout
        String name;
        String value;
        String flag;
        public HDT_WRP_Position(String Name, String Value){
            this.Name=Name;
            this.Value=Value;
        }
    }

    public class HDT_WRP_DtoServiceTwentySix extends HDT_WS_Request{
        public String rdsRdo;
        public String pod;
        public String documentKey;
        public String tipoOperazione;
        public String tipoFornitura;
        public List<HDT_WRP_Position> elements;
        public HDT_WRP_DtoServiceTwentySix(Order order){
            this.rdsRdo=Order.OrderNumber;
            this.pod=Order.ServicePointCode__c;
            this.documentKey=Order.HerokuPracticeCode__c;
            this.tipoOperazione=order.ActivationMode__c;
            this.tipoFornitura=order.SupplyType__c;
        }
        public HDT_WRP_DtoServiceTwentySix(){}
    }


    private static List<Service26Config__c> getConfigs(String serviceType, Set<String> productFamilies){
        //This method get a service type (gas/Elettrico) and a list of product families, 
        //return a list of 'operando' ordered by  Occurrence__c
        return [ select SapCode__c, Field__c, Occurrence__c, ProductFamily__c, (SELECT SapCode__c, Field__c FROM Service26Configs__r )
                    FROM Service26Config__c WHERE 
                    Type__c='Operando' AND ProductFamily__c IN :productFamilies AND Type__c =:serviceType 
                    WITH SECURITY_ENFORCED ORDER BY Occurrence__c ASC
            ];
    }



    public HDT_WRP_DtoServiceTwentySix startProcess(Id OrderId){
        //this method starts the process, it gets an OrderId and he queries related OrderItems
        //If there's already a query on order items (or on Order), modify this method to get that list
        
        Order order = [SELECT (SELECT Product2.Family FROM OrderItems), CommodityFormula__c,
                         OrderNumber, ServicePointCode__c, ActivationMode__c,
                        HerokuPracticeCode__c, SupplyType__c, SupplyTypeTechnical__c
                        FROM Order WHERE Id=:OrderId WITH SECURITY_ENFORCED];

        HDT_WRP_DtoServiceTwentySix dto = new HDT_WRP_DtoServiceTwentySix(order);

        List<OrderItem> items = order.OrderItems;
        if(items.isEmpty()){
            return dto;
        }
            /* [SELECT Order.CommodityFormula__c, Product2.Family, Order.OrderNumber, Order.ServiePointCode__c, 
                Order.HerokuPracticeCode__c, Order.SupplyType__c, Order.SupplyTypeTechnical__c, Order.ActivationMode__c
            FROM OrderItem WHERE OrderId=:OrderId WITH SECURITY_ENFORCED]; */

        Map<String, List<OrderItem>> familyToOccurrencies = new Map<String, List<OrderItem>>();
        //this map is used to connect a family to a list of items. 
        //This map is not clean because we cannot know at this point 
        //which of these items are bonuses
        //the size of each list is the number of occurence that family has
        for(OrderItem item : items){
            if(!familyToOccurrencies.containsKey(item.Product2.Family)){
                familyToOccurrencies.put(item.Product2.Family, new List<OrderItem>());
            }
            familyToOccurrencies.get(item.Product2.Family).add(item);
        }
        List<Service26Config__c> configs = getConfigs(order.CommodityFormula__c, familyToOccurrencies.keyset());
        //getting list of configurationObjects, they contains only the families we are interested but 
        //They may have more occurrence than we need
        if(!configs.isEmpty()){
            dto.elements=getPositions(configs, familyToOccurrencies);
        }
        return dto;
    }




    private List<HDT_WRP_Position> getPositions(List<Service26Config__c> configs, Map<String, List<OrderItem>> familyToOccurrencies){
        Set<String> prodFields = ((SObject)Type.forName('Schema','Product2').newInstance())
                                    .getSObjectType().getDescribe().fields.getMap().keySet();//Set of all order api name fields
        List<String> fieldsToQuery = new List<String>();
        Set<Id> productIds = new Set<Id>();
        Map<String, List<Service26Config__c>> familyToOperando = new Map<String, List<Service26Config__c>>(); 
        //this map key gonna be a clean set of families to the corresponding operandos, ordered by occurrency asc 
        //The for loop below populate familyOperando Map, list of all products id to query and all fields to query
        for(Service26Config__c operando : configs){
            if(!familyToOperando.containsKey(operando.ProductFamily__c)){
                familyToOperando.put(operando.ProductFamily__c, new List<Service26Config__c>());
            }
            familyToOperando.get(operando.ProductFamily__c).add(operando);
            if(operando.Occurrence__c==1){
                for(orderItem item : familyToOccurrencies.get(operando.ProductFamily__c)){
                    productIds.add(item.Product2Id);
                }
                for(Service26Config__c position : Operando.Service26Configs__r){
                    if(prodFields.contains(Position.Field__c.toLowerCase())){
                        fieldsToQuery.add(Position.Field__c);
                    }
                }
            }
        }

        Map<id, Product2> prods = new HDT_QR_Sobject().getProduct(productIds, fieldsToQuery);

        List<HDT_WRP_Position> positionsToReturn = new List<HDT_WRP_Position>();

        //Now we have 3 maps, map id-> product
        //Map family -> List OrderItem (OrderItem Contains Prod id), the index of the list is "Occurrency" Information
        //this map contain some key-values we don't need
        //
        //Map family -> Operando, Operando has child relationship with "positions", 
        //this map contains only the key needed

        //this for loop builds the list of Object for the callout
        for(String family : familyToOperando.keySet()){
            List<OrderItem> discountItems = familyToOccurrencies.get(family);
            for(Integer index = 0; index<discountItems.size();index++){
                Product2 relatedProduct = prods.get(discountItems[index].Product2Id);//product to get values
                
                if(familyToOperando.get(family).size()<=index){
                    //there are more discounts than occurrencies
                    break;
                } 
                Service26Config__c operando = familyToOperando.get(family)[index];//operando

                positionsToReturn.add( 
                    new HDT_WRP_Position(operando.SapCode__c, operando.Field__c)//operando field is just a string
                );
                for(Service26Config__c position : Operando.Service26Configs__r){//Operando has childs
                    String value;
                    if(STRING.isBlank(position.Field__c)){
                        value='';
                    }else if(prodFields.contains(position.Field__c.toLowerCase())){
                        value=STRING.valueOf(relatedProduct.get(position.Field__c));
                    }else{
                        value=position.Field__c;
                    }
                    //String value = STRING.isBlank(position.Field__c) ? '' : STRING.valueOf(relatedProduct.get(position.Field__c));
                    positionsToReturn.add( 
                        new HDT_WRP_Position(position.SapCode__c, value)
                        //child field is the api name of Product field to get value
                    );            
                }

            }

        }
        return positionsToReturn;
    }




}
