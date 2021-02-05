/*
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date 5-2-2021
* @description Another Controller for the LWC Available Products 
* @testClass Not created due to time limitation
* @Coverage 
*/

public class ActivateProductController { 
    /* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : Activates Order
* @param string  id OrderId
* @return Void	Changes status of Order to Active - OrderItems have no status active
* @history
*/
    @AuraEnabled
   public static void activateOrder (id orderId) {
      
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndPoint('https://assignment.requestcatcher.com/test');
    OrderWrapper wrapp = mapOrderToWrapper(orderId);
    String jsonString = JSON.serialize(wrapp);
    system.debug(jsonString);
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
    request.setBody(jsonString);

    HttpResponse response = http.send(request);

    if(response.getStatusCode()==200){
     List<Order> ord = [Select id, status from order where id =: orderId];
     ord[0].Status = 'Activated';
 	 Update ord;
    }

     if(response.getStatusCode()==404){
        
    }
     if(response.getStatusCode()==401){
        
    }
       //etc..

   }
    
 public class OrderWrapper{
       @auraEnabled public String   accountNumber;
       @auraEnabled public String   orderNumber;   
       @auraEnabled public String   type;
       @auraEnabled public String   status;
       public List<orderItemsWrapper> orderProducts;
    }
    
     public class orderItemsWrapper{
       @auraEnabled public String   name;
       @auraEnabled public String   code;   
       @auraEnabled public decimal   unitPrice;
       @auraEnabled public decimal   quantity;

    }
      /* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : Maps the order to a Wrapper to send the Request
* @param string  id OrderId
* @return OrderWrapper
* @history
*/  
    public static OrderWrapper mapOrderToWrapper(id orderId)
    {	
        
        list<orderItemsWrapper> orderItemswrp = new List<orderItemsWrapper>();
        List<Order> orderList = [select id, orderNumber,account.Name, type, status from Order where id =: orderId];
        List<OrderItem> orderItemsList = [select id, unitprice, product2.Name ,orderId, product2.productcode, quantity from OrderItem where orderId =: orderId];
        OrderWrapper orderwrap = new OrderWrapper();
        // Map Order
        orderwrap.accountNumber =orderList[0].account.Name;
        orderwrap.OrderNumber= orderList[0].orderNumber;
        orderwrap.type= orderList[0].type;
        // Map Order Items
        for(OrderItem orderProduct : orderItemsList)
        {
            orderItemsWrapper orderItemwrap = new orderItemsWrapper();
            orderItemwrap.name = orderProduct.Product2.name;
            orderItemwrap.Code = orderProduct.Product2.ProductCode;
            orderItemwrap.unitPrice = orderProduct.unitPrice;
            orderItemwrap.quantity = orderProduct.quantity;
            orderItemswrp.add(orderItemwrap);
        }
        orderwrap.orderProducts = orderItemswrp;
        return orderwrap;
    }
    
      /* 
* @company name EI Technologies Lebanon
* @author Nour Absi
* @date : 5-2-2021
* @description : Gets the Order Status
* @param string  id OrderId
* @return Order Status
* @history
*/     
     @AuraEnabled
   public static string getOrderStatus (id orderId) {
        List<Order> orderList = [select id, status from Order where id =: orderId];
        return orderList[0].Status;
   }
      
}