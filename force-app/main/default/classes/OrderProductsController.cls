/*
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date 5-2-2021
* @description Controller for the LWC orderProducts
* @testClass OrderProductsController_Test
* @Coverage 100%
*/

public without sharing class OrderProductsController {
/* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : Created to display order items on page rendering
* @param id OrderId
* @return List<OrderItem> 
* @history
*/
     
        @AuraEnabled(cacheable=true)
        public static List<OrderItem> getOrderProductsInit( id orderId) {
           
           List<OrderItem> orderItemList = [Select id, product2.Name, unitPrice, Quantity, TotalPrice from orderItem where orderId =: orderId];
           system.debug(orderItemList);
          
     
           return orderItemList;
        }
    /* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : Created to redisplay the order items record on change
* @param id OrderId
* @return List<OrderItem> 
* @history
*/ 
         @AuraEnabled
        public static List<OrderItem> getOrderProductOnChange( id orderId) {
           
           List<OrderItem> orderItemList = [Select id, product2.Name, unitPrice, Quantity, TotalPrice from orderItem where orderId =: orderId];
           system.debug(orderItemList);
          
     
           return orderItemList;
        }

    }