/*
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date 5-2-2021
* @description Controller for the LWC availableProducts
* @testClass AvailableProductsController_Test
* @Coverage 82%
*/

public without sharing class AvailableProductsController {
/* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : get all the available pricebook entries that are active and belonging to the Standard Pricebook
* @param string searchKey, String sortBy, string sortDirection
* @return List<pricebookentry> 
* @history
*/
    @AuraEnabled(cacheable=true)
    public static List<pricebookentry> getProducts( String searchKey, String sortBy, String sortDirection) {
        //get standard Pricebook for this assignment
        Pricebook2 standardPricebook = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1];
        String query = 'SELECT Id, Name, isActive , UnitPrice, pricebook2Id, pricebook2.Name, product2Id  FROM pricebookentry';
        
        //There is a search key
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' WHERE Name LIKE :key and isActive = true and pricebook2Id = \'' + standardPricebook.Id +'\'';
        }
        
        //There is sorting but no search key
        if ( sortBy != null && sortDirection != null && !(searchKey != null && searchKey != '' ) ) {
            query += ' WHERE  isActive = true and pricebook2Id = \'' + standardPricebook.Id +'\' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        
        //There is sorting and search key
        if ( sortBy != null && sortDirection != null && (searchKey != null && searchKey != '' ) ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        system.debug('query' + query);
        return Database.query( query );
    }   
    
/* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : Upsert Order Products
* @param string orderProductJSON , id OrderId
* @return Void
* @history
*/
    @AuraEnabled
    public static void insertUpdateOrderProducts(string orderProductListJson, id orderId) {
        List<OrderItem> orderItemList = new List<OrderItem>();
        List<pricebookentry> pricebookEntryList = (List<pricebookentry>)System.JSON.deserialize(orderProductListJson,List<pricebookentry>.class);
        List<OrderItem> currentOrderProducts = [Select id, Product2Id , quantity, orderId from orderItem where orderId = : orderId  ];
        Map<Id,OrderItem> mapProductOrderItem = new Map<Id,OrderItem>();
        List<Order> currentOrder = [Select id, pricebook2Id  from order where Id = : orderId  ];
        Pricebook2 standardPricebook = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1];
        if (currentOrder[0].Pricebook2Id == null)
        {
            currentOrder[0].Pricebook2Id = standardPricebook.Id;
            try{
                Update currentOrder[0];
                
                }
              
                catch( exception ex)
                {  ex.setMessage(Label.AvailableProductsController_errPricebookOrder + ex.getMessage());
                   throw ex;
                }
        }
        if (!currentOrderProducts.isEmpty() ) {
        for (orderItem orderProduct : currentOrderProducts )
        {
            mapProductOrderItem.put( orderProduct.Product2Id , orderProduct);
        }
    }
        
        if(orderProductListJson != null)
        {
            
            for(pricebookentry pbe: pricebookEntryList){
                //If Product already existing, then add the quantity by 1
                if(mapProductOrderItem.containsKey(pbe.Product2Id))
                {
                    mapProductOrderItem.get(pbe.Product2Id).Quantity = mapProductOrderItem.get(pbe.Product2Id).Quantity +1 ;
                    orderItemList.add(mapProductOrderItem.get(pbe.Product2Id));
                }
                //create new order item if not existing
                else{
                    orderItem orderLine = new OrderItem();
                    orderLine.UnitPrice = pbe.UnitPrice;
                    orderLine.PricebookEntryId = pbe.id;
                    orderLine.OrderId = orderId;
                    orderLine.Quantity = 1;
                    orderLine.product2Id = pbe.product2Id;
                    orderItemList.add(orderLine);
                }
            }
            if (!orderItemList.isEmpty() ){
                try{
                Upsert orderItemList;
                }
                catch( exception ex)
                { 
                   
                   ex.setMessage(Label.AvailableProductsController_errOrderItemCreation + ex.getMessage());
                   throw ex;
                }
            }
            
        }
        
    }
}